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
    // TODO: check if fetch is allowed

    [self.cloudKitService fetchAlertCampaignsForClientInfo:self.clientInfo
                                                completion:^(NSArray<CLMAlertCampaign *> *alertCampaigns) {
                                                    [self.stateKeeper recordFetch];
                                                    [self handleAlerts:alertCampaigns initialAppLaunch:initialAppLaunch];
                                                }];
}

#pragma mark - Private

- (void)handleAlerts:(NSArray<CLMAlertCampaign *> *)alertCampaigns initialAppLaunch:(BOOL)initialAppLaunch {
    // TODO: filter alerts by App and OS versions
    [self.memeoryCache setAlertsData:alertCampaigns];

    [self.delegate fetchFlowDidFetchedAlers:self initialAppLaunch:initialAppLaunch];
}

@end

NS_ASSUME_NONNULL_END
