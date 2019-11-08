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

#import "../CLMAlertPresenter.h"
#import "CLMAlertActionDefaultExecutor.h"
#import "CLMAlertsMemoryCache.h"
#import "CLMPresentingWindowHelper.h"
#import "CLMSettings.h"
#import "CLMStateKeeper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMDisplayExecutor ()

@property (readonly, nonatomic, strong) CLMSettings *settings;
@property (readonly, nonatomic, strong) CLMAlertsMemoryCache *memoryCache;
@property (readonly, nonatomic, strong) CLMStateKeeper *stateKeeper;

@property (nonatomic, assign) BOOL messageDisplaySuppressed;
@property (nonatomic, assign, getter=isAlertBeingDisplayed) BOOL alertBeingDisplayed;

@end

@implementation CLMDisplayExecutor

- (instancetype)initWithSettings:(CLMSettings *)settings
                     memoryCache:(CLMAlertsMemoryCache *)memoryCache
                     stateKeeper:(CLMStateKeeper *)stateKeeper {
    self = [super init];
    if (self) {
        _settings = settings;
        _memoryCache = memoryCache;
        _stateKeeper = stateKeeper;
    }
    return self;
}

- (void)checkAndDisplayNextAppLaunchAlert {
    @synchronized(self) {
        if (self.messageDisplaySuppressed) {
            return;
        }

        if (self.isAlertBeingDisplayed) {
            return;
        }

        // TODO: if ([self enoughIntervalFromLastDisplay]) {

        CLMAlertCampaign *alert = [self.memoryCache nextAlertForTrigger:CLMAlertCampaignTriggerOnAppLaunch];
        if (alert) {
            [self displayAlert:alert];
        }
    }
}

- (void)checkAndDisplayNextAppForegroundAlert {
    @synchronized(self) {
        if (self.messageDisplaySuppressed) {
            return;
        }

        if (self.isAlertBeingDisplayed) {
            return;
        }

        // TODO: if ([self enoughIntervalFromLastDisplay]) {

        CLMAlertCampaign *alert = [self.memoryCache nextAlertForTrigger:CLMAlertCampaignTriggerOnForeground];
        if (alert) {
            [self displayAlert:alert];
        }
    }
}

#pragma mark - Private

- (void)displayAlert:(CLMAlertCampaign *)alert {
    [self.stateKeeper recordAlertImpression:alert];

    UIWindow *window = [CLMPresentingWindowHelper UIWindowForPresenting];
    UIViewController *rootController = [[UIViewController alloc] init];
    window.rootViewController = rootController;
    [window setHidden:NO];

    // TODO: pass lang from ClientInfo
    // TODO: delegate for completion
    CLMAlertPresenter *presenter = [[CLMAlertPresenter alloc] initWithAlertCampaign:alert];
    presenter.actionExecutor = [[CLMAlertActionDefaultExecutor alloc] init];

    [presenter presentInViewController:rootController];
}

@end

NS_ASSUME_NONNULL_END
