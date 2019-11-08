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

#import "CLMAlertsMemoryCache.h"
#import "CLMCKService.h"
#import "CLMClientInfo.h"
#import "CLMDisplayExecutor.h"
#import "CLMFetchFlow.h"
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
@property (readonly, nonatomic, strong) CLMAlertsMemoryCache *memoryCache;
@property (readonly, nonatomic, strong) CLMFetchFlow *fetchFlow;
@property (readonly, nonatomic, strong) CLMDisplayExecutor *displayExecutor;

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
        _memoryCache = [[CLMAlertsMemoryCache alloc] initWithStateKeeper:_stateKeeper];
        _fetchFlow = [[CLMFetchFlow alloc] initWithSettings:settings
                                            cloudKitService:_cloudKitService
                                                 clientInfo:_clientInfo
                                                memoryCache:_memoryCache
                                                stateKeeper:_stateKeeper
                                                   delegate:self];
        _displayExecutor = [[CLMDisplayExecutor alloc] initWithSettings:settings
                                                            memoryCache:_memoryCache
                                                            stateKeeper:_stateKeeper];

        [self resume];
    }
    return self;
}

- (void)resume {
    @synchronized(self) {
        if (!_running) {
            [self.fetchFlow checkAndFetchForInitialAppLaunch:YES];

            _running = YES;
        }
    }
}

- (void)pause {
    @synchronized(self) {
        if (_running) {

            _running = NO;
        }
    }
}

- (void)setMessageDisplaySuppressed:(BOOL)messageDisplaySuppressed {
    [self.displayExecutor setMessageDisplaySuppressed:messageDisplaySuppressed];
}

#pragma mark - CLMFetchFlowDelegate

- (void)fetchFlowDidFetchedAlers:(CLMFetchFlow *)fetchFlow initialAppLaunch:(BOOL)initialAppLaunch {
    // TODO: fix me
    [self.displayExecutor checkAndDisplayNextAppForegroundAlert];
}

@end

NS_ASSUME_NONNULL_END
