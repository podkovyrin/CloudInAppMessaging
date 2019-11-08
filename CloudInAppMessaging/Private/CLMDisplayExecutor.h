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

@class CLMSettings;
@class CLMAlertsMemoryCache;
@class CLMStateKeeper;

@interface CLMDisplayExecutor : NSObject

- (instancetype)initWithSettings:(CLMSettings *)settings
                     memoryCache:(CLMAlertsMemoryCache *)memoryCache
                     stateKeeper:(CLMStateKeeper *)stateKeeper;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)setMessageDisplaySuppressed:(BOOL)messageDisplaySuppressed;

// Check and display next in-app alert eligible for app launch trigger
- (void)checkAndDisplayNextAppLaunchAlert;
// Check and display next in-app alert eligible for app open trigger
- (void)checkAndDisplayNextAppForegroundAlert;


@end

NS_ASSUME_NONNULL_END
