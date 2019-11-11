//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CLMFetchFlow.h"

#import "CLMAlertsMemoryCache.h"
#import "CLMCKService.h"
#import "CLMClientInfo.h"
#import "CLMSettings.h"
#import "CLMStateKeeper.h"

NS_ASSUME_NONNULL_BEGIN


/// Normalize version string to the semver format: MAJOR.MINOR.PATCH
static NSString *CLMNormalizeVersionString(NSString *version) {
    NSMutableArray<NSString *> *separatedVersion = [[version componentsSeparatedByString:@"."] mutableCopy];
    while (separatedVersion.count < 3) {
        [separatedVersion addObject:@"0"];
    }
    return [separatedVersion componentsJoinedByString:@"."];
}

@interface CLMFetchFlow ()

@property (readonly, nonatomic, strong) CLMSettings *settings;
@property (readonly, nonatomic, strong) CLMCKService *cloudKitService;
@property (readonly, nonatomic, strong) CLMClientInfo *clientInfo;
@property (readonly, nonatomic, strong) CLMAlertsMemoryCache *memeoryCache;
@property (readonly, nonatomic, strong) CLMStateKeeper *stateKeeper;
@property (nullable, nonatomic, weak) id<CLMFetchFlowDelegate> delegate;


@end

@implementation CLMFetchFlow

- (instancetype)initWithSettings:(CLMSettings *)settings
                 cloudKitService:(CLMCKService *)cloudKitService
                      clientInfo:(CLMClientInfo *)clientInfo
                     memoryCache:(CLMAlertsMemoryCache *)memeoryCache
                     stateKeeper:(CLMStateKeeper *)stateKeeper
                        delegate:(id<CLMFetchFlowDelegate>)delegate {
    self = [super init];
    if (self) {
        _settings = settings;
        _cloudKitService = cloudKitService;
        _clientInfo = clientInfo;
        _memeoryCache = memeoryCache;
        _stateKeeper = stateKeeper;
        _delegate = delegate;
    }

    return self;
}

- (void)checkAndFetchForInitialAppLaunch:(BOOL)initialAppLaunch {
    NSDate *now = [NSDate date];
    const NSTimeInterval intervalFromLastFetch =
        now.timeIntervalSince1970 - self.stateKeeper.lastFetchDate.timeIntervalSince1970;
    const BOOL isFetchAllowed = intervalFromLastFetch > self.settings.fetchMinInterval;
    if (!isFetchAllowed) {
        [self.delegate fetchFlowDidFinish:self initialAppLaunch:initialAppLaunch];

        return;
    }

    [self.cloudKitService fetchAlertCampaignsForClientInfo:self.clientInfo
                                                completion:^(NSArray<CLMAlertCampaign *> *alertCampaigns) {
                                                    [self.stateKeeper recordFetch];
                                                    [self handleAlerts:alertCampaigns initialAppLaunch:initialAppLaunch];
                                                }];
}

#pragma mark - Private

- (void)handleAlerts:(NSArray<CLMAlertCampaign *> *)alertCampaigns initialAppLaunch:(BOOL)initialAppLaunch {
    NSString *appVersion = CLMNormalizeVersionString(self.clientInfo.appVersion);
    NSString *osVersion = self.clientInfo.osVersion; // already normalized
    NSSet<NSString *> *impressionSet = [NSSet setWithArray:self.stateKeeper.impressionIDs];

    NSMutableArray<CLMAlertCampaign *> *matchedAlertCampaigns = [NSMutableArray array];
    for (CLMAlertCampaign *alertCampaign in alertCampaigns) {
        if (![impressionSet containsObject:alertCampaign.identifier] &&
            ![alertCampaign alertHasExpired] &&
            [self alertMatches:alertCampaign
                    appVersion:appVersion
                     osVersion:osVersion]) {
            [matchedAlertCampaigns addObject:alertCampaign];
        }
    }

    dispatch_group_t dispatchGroup = dispatch_group_create();

    for (CLMAlertCampaign *alertCampaign in matchedAlertCampaigns) {
        dispatch_group_enter(dispatchGroup);
        [self.cloudKitService fetchTranslationsForAlertCampaign:alertCampaign
                                                     completion:^(NSArray<CLMAlertTranslation *> *alertTranslations) {
                                                         alertCampaign.translations = alertTranslations;

                                                         dispatch_group_leave(dispatchGroup);
                                                     }];
    }

    dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.memeoryCache setAlertsData:matchedAlertCampaigns];

        [self.delegate fetchFlowDidFinish:self initialAppLaunch:initialAppLaunch];
    });
}


/// Check if the AlertCampaign can be shown with given appVersion and osVersion
/// @param alertCampaign Alert Campaign to check
/// @param appVersion Normalized App Version
/// @param osVersion Normalized OS Version
- (BOOL)alertMatches:(CLMAlertCampaign *)alertCampaign
          appVersion:(NSString *)appVersion
           osVersion:(NSString *)osVersion {

    NSString *maxAppVersion = alertCampaign.maxAppVersion;
    if (maxAppVersion.length > 0) {
        maxAppVersion = CLMNormalizeVersionString(maxAppVersion);
        if ([appVersion compare:maxAppVersion options:NSNumericSearch] == NSOrderedDescending) {
            return NO; // appVersion > maxAppVersion
        }
    }

    NSString *maxOSVersion = alertCampaign.maxOSVersion;
    if (maxOSVersion.length > 0) {
        maxOSVersion = CLMNormalizeVersionString(maxOSVersion);
        if ([osVersion compare:maxOSVersion options:NSNumericSearch] == NSOrderedDescending) {
            return NO; // osVersion > maxOSVersion
        }
    }

    NSString *minAppVersion = alertCampaign.minAppVersion;
    if (minAppVersion.length > 0) {
        minAppVersion = CLMNormalizeVersionString(minAppVersion);
        if ([appVersion compare:minAppVersion options:NSNumericSearch] == NSOrderedAscending) {
            return NO; // appVersion < minAppVersion
        }
    }

    NSString *minOSVersion = alertCampaign.minOSVersion;
    if (minOSVersion.length > 0) {
        minOSVersion = CLMNormalizeVersionString(minOSVersion);
        if ([osVersion compare:minOSVersion options:NSNumericSearch] == NSOrderedAscending) {
            return NO; // osVersion < minOSVersion
        }
    }

    return YES;
}

@end

NS_ASSUME_NONNULL_END
