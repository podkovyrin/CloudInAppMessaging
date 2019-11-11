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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CLMStateKeeper;
@class CLMCKService;
@class CLMClientInfo;
@class CLMAlertsMemoryCache;
@class CLMSettings;
@class CLMFetchFlow;

@protocol CLMFetchFlowDelegate <NSObject>

- (void)fetchFlowDidFinish:(CLMFetchFlow *)fetchFlow initialAppLaunch:(BOOL)initialAppLaunch;

@end

// Parent class for supporting different fetching flows. Subclass is supposed to trigger
// `checkAndFetchForInitialAppLaunch:` at appropriate moments based on its fetch strategy
@interface CLMFetchFlow : NSObject

- (instancetype)initWithSettings:(CLMSettings *)settings
                 cloudKitService:(CLMCKService *)cloudKitService
                      clientInfo:(CLMClientInfo *)clientInfo
                     memoryCache:(CLMAlertsMemoryCache *)memeoryCache
                     stateKeeper:(CLMStateKeeper *)stateKeeper
                        delegate:(id<CLMFetchFlowDelegate>)delegate;

- (void)checkAndFetchForInitialAppLaunch:(BOOL)initialAppLaunch;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END