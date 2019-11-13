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

#import "CLMDisplayExecutor.h"

#import "CLMAlertActionDefaultExecutor.h"
#import "CLMAlertMemoryCache.h"
#import "CLMClientInfo.h"
#import "CLMPresentingWindowHelper.h"
#import "CLMSettings.h"
#import "CLMStateKeeper.h"
#import "CLMTimeFetcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMDisplayExecutor () <CLMAlertPresenterDelegate>

@property (readonly, nonatomic, strong) CLMSettings *settings;
@property (readonly, nonatomic, strong) id<CLMTimeFetcher> timeFetcher;
@property (readonly, nonatomic, strong) id<CLMClientInfo> clientInfo;
@property (readonly, nonatomic, strong) CLMAlertMemoryCache *memoryCache;
@property (readonly, nonatomic, strong) id<CLMStateKeeper> stateKeeper;

@property (nonatomic, assign) BOOL messageDisplaySuppressed;
@property (nonatomic, assign) BOOL alertBeingDisplayed;

@end

@implementation CLMDisplayExecutor

- (instancetype)initWithSettings:(CLMSettings *)settings
                     timeFetcher:(id<CLMTimeFetcher>)timeFetcher
                      clientInfo:(id<CLMClientInfo>)clientInfo
                     memoryCache:(CLMAlertMemoryCache *)memoryCache
                     stateKeeper:(id<CLMStateKeeper>)stateKeeper {
    self = [super init];
    if (self) {
        _settings = settings;
        _timeFetcher = timeFetcher;
        _clientInfo = clientInfo;
        _memoryCache = memoryCache;
        _stateKeeper = stateKeeper;
    }
    return self;
}

- (void)checkAndDisplayNextAppLaunchAlert {
    [self checkAndDisplayNextForTrigger:CLMAlertCampaignTriggerOnAppLaunch];
}

- (void)checkAndDisplayNextAppForegroundAlert {
    [self checkAndDisplayNextForTrigger:CLMAlertCampaignTriggerOnForeground];
}

#pragma mark - CLMAlertPresenterDelegate

- (void)alertPresenter:(id<CLMAlertPresenter>)alertPresenter didFinishPresentingAlert:(CLMAlertCampaign *)alertCampaign {
    NSAssert([NSThread isMainThread], @"Main thread is assumed here");

    UIWindow *window = [CLMPresentingWindowHelper UIWindowForPresenting];
    window.hidden = YES;
    window.rootViewController = nil;

    @synchronized(self) {
        self.alertBeingDisplayed = NO;
    }
}

#pragma mark - Private

- (void)checkAndDisplayNextForTrigger:(CLMAlertCampaignTrigger)trigger {
    @synchronized(self) {
        if (self.messageDisplaySuppressed) {
            return;
        }

        if (self.alertBeingDisplayed) {
            return;
        }

        const NSTimeInterval currentTimestamp = [self.timeFetcher currentTimestamp];
        const NSTimeInterval lastDisplayTimeInterval = self.stateKeeper.lastDisplayTimeInterval;
        const NSTimeInterval intervalFromLastDisplay = currentTimestamp - lastDisplayTimeInterval;
        const BOOL isDisplayAllowed = intervalFromLastDisplay > self.settings.fetchMinInterval;
        if (!isDisplayAllowed) {
            return;
        }

        CLMAlertCampaign *alert = [self.memoryCache nextAlertForTrigger:trigger];
        if (alert) {
            self.alertBeingDisplayed = YES;
            [self.stateKeeper recordAlertImpression:alert];
            [self.memoryCache removeAlert:alert];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayAlert:alert];
            });
        }
    }
}

- (void)displayAlert:(CLMAlertCampaign *)alertCampaign {
    NSAssert([NSThread isMainThread], @"Main thread is assumed here");
    NSParameterAssert(self.alertPresenter);
    NSAssert(self.alertPresenter.delegate == self || self.alertPresenter.delegate == nil,
             @"Setting `delegate` property of CLMAlertPresenter object is prohibited");

    UIWindow *window = [CLMPresentingWindowHelper UIWindowForPresenting];
    UIViewController *rootController = [[UIViewController alloc] init];
    window.rootViewController = rootController;
    [window setHidden:NO];

    self.alertPresenter.delegate = self;

    NSArray<NSString *> *preferredLanguages = self.clientInfo.preferredLanguages;
    [self.alertPresenter presentAlert:alertCampaign
                   preferredLanguages:preferredLanguages
                     inViewController:rootController];
}

@end

NS_ASSUME_NONNULL_END
