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

#import "../CLMAlertPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CLMClientInfo;
@protocol CLMStateKeeper;
@protocol CLMTimeFetcher;
@class CLMSettings;
@class CLMAlertMemoryCache;

/// The class for checking if there are appropriate alerts to be displayed and if so, show it.
/// There are other flows that would determine the timing for the checking and then use this class
/// instance for the actual check/display.
@interface CLMDisplayExecutor : NSObject

@property (nullable, nonatomic, strong) id<CLMAlertPresenter> alertPresenter;

- (instancetype)initWithSettings:(CLMSettings *)settings
                     timeFetcher:(id<CLMTimeFetcher>)timeFetcher
                      clientInfo:(id<CLMClientInfo>)clientInfo
                     memoryCache:(CLMAlertMemoryCache *)memoryCache
                     stateKeeper:(id<CLMStateKeeper>)stateKeeper;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)setMessageDisplaySuppressed:(BOOL)messageDisplaySuppressed;

// Check and display next in-app alert eligible for app launch trigger
- (void)checkAndDisplayNextAppLaunchAlert;
// Check and display next in-app alert eligible for app open trigger
- (void)checkAndDisplayNextAppForegroundAlert;

@end

NS_ASSUME_NONNULL_END
