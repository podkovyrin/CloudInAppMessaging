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

#import "CLMManager.h"

#import "CLMAlertActionDefaultExecutor.h"
#import "CLMAlertMemoryCache.h"
#import "CLMCKService.h"
#import "CLMClientInfo.h"
#import "CLMDisplayExecutor.h"
#import "CLMDisplayOnAppForegroundFlow.h"
#import "CLMFetchOnAppForegroundFlow.h"
#import "CLMPresentingWindowHelper.h"
#import "CLMSettings.h"
#import "CLMStateKeeper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMManager () <CLMFetchFlowDelegate> {
    BOOL _running;
}

@property (readonly, nonatomic, strong) CLMSettings *settings;

@property (readonly, nonatomic, strong) CLMClientInfo *clientInfo;
@property (readonly, nonatomic, strong) CLMStateKeeper *stateKeeper;
@property (readonly, nonatomic, strong) CLMCKService *cloudKitService;
@property (readonly, nonatomic, strong) CLMAlertMemoryCache *memoryCache;
@property (readonly, nonatomic, strong) CLMFetchOnAppForegroundFlow *fetchFlow;
@property (readonly, nonatomic, strong) CLMAlertActionDefaultExecutor *defaultActionExecutor;
@property (readonly, nonatomic, strong) CLMDisplayExecutor *displayExecutor;
@property (readonly, nonatomic, strong) CLMDisplayOnAppForegroundFlow *displayOnAppForegroundFlow;

@end

@implementation CLMManager

- (instancetype)initWithCloudKitContainerIdentifier:(nullable NSString *)containerIdentifier
                                           settings:(CLMSettings *)settings {
    NSAssert([NSThread isMainThread], @"Should be initialized on the Main Thread");

    self = [super init];
    if (self) {
        _settings = settings;

        _clientInfo = [[CLMClientInfo alloc] init];
        _stateKeeper = [[CLMStateKeeper alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
        _cloudKitService = [[CLMCKService alloc] initWithContainerIdentifier:containerIdentifier];
        _memoryCache = [[CLMAlertMemoryCache alloc] initWithStateKeeper:_stateKeeper];
        _fetchFlow = [[CLMFetchOnAppForegroundFlow alloc] initWithSettings:_settings
                                                           cloudKitService:_cloudKitService
                                                                clientInfo:_clientInfo
                                                               memoryCache:_memoryCache
                                                               stateKeeper:_stateKeeper
                                                                  delegate:self];

        _defaultActionExecutor = [[CLMAlertActionDefaultExecutor alloc] init];
        _displayExecutor = [[CLMDisplayExecutor alloc] initWithSettings:_settings
                                                             clientInfo:_clientInfo
                                                            memoryCache:_memoryCache
                                                            stateKeeper:_stateKeeper];
        _displayExecutor.alertPresenter = [self defaultAlertPresenter];

        _displayOnAppForegroundFlow = [[CLMDisplayOnAppForegroundFlow alloc]
            initWithDisplayExecutor:_displayExecutor];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self start];
        });
    }
    return self;
}

- (void)resume {
    @synchronized(self) {
        if (!_running) {
            [self.fetchFlow start];
            [self.displayOnAppForegroundFlow start];

            _running = YES;
        }
    }
}

- (void)pause {
    @synchronized(self) {
        if (_running) {
            [self.fetchFlow stop];
            [self.displayOnAppForegroundFlow stop];

            _running = NO;
        }
    }
}

- (void)setMessageDisplaySuppressed:(BOOL)messageDisplaySuppressed {
    [self.displayExecutor setMessageDisplaySuppressed:messageDisplaySuppressed];
}

- (void)setAlertPresenter:(nullable id<CLMAlertPresenter>)alertPresenter {
    _alertPresenter = alertPresenter;

    self.displayExecutor.alertPresenter = alertPresenter ?: [self defaultAlertPresenter];
}

#pragma mark - Private

- (void)start {
    if (_running) {
        [self.fetchFlow stop];
        [self.displayOnAppForegroundFlow stop];
    }

    [self.fetchFlow checkAndFetchForInitialAppLaunch:YES];
}

- (id<CLMAlertPresenter>)defaultAlertPresenter {
    NSParameterAssert(self.defaultActionExecutor);

    id<CLMAlertPresenter> alertPresenter = [[CLMDefaultAlertPresenter alloc] init];
    alertPresenter.actionExecutor = self.defaultActionExecutor;

    return alertPresenter;
}

#pragma mark - CLMFetchFlowDelegate

- (void)fetchFlowDidFinish:(CLMFetchFlow *)fetchFlow initialAppLaunch:(BOOL)initialAppLaunch {
    if (initialAppLaunch) {
        [self.fetchFlow start];
        [self.displayOnAppForegroundFlow start];

        @synchronized(self) {
            _running = YES;
        }

        [self.displayExecutor checkAndDisplayNextAppLaunchAlert];

        // Simulate app going into foreground on startup
        [self.displayExecutor checkAndDisplayNextAppForegroundAlert];
    }
    else {
        [self.displayExecutor checkAndDisplayNextAppForegroundAlert];
    }
}

@end

NS_ASSUME_NONNULL_END
