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

#import <UIKit/UIKit.h>

#import "CLMAlertActionExecutor.h"

NS_ASSUME_NONNULL_BEGIN

@class CLMAlertCampaign;

@interface CLMAlertPresenter : NSObject

@property (readonly, nonatomic, strong) CLMAlertCampaign *alertCampaign;

@property (nullable, nonatomic, strong) id<CLMAlertActionExecutor> actionExecutor;

- (void)presentInViewController:(UIViewController *)controller NS_SWIFT_NAME(present(in:));

- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign;

/// If `preferredLanguages` is nil `[NSLocale preferredLanguages]` will be used
- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign
                   preferredLanguages:(nullable NSArray<NSString *> *)preferredLanguages NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
