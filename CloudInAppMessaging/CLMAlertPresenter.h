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
@protocol CLMAlertPresenter;

@protocol CLMAlertPresenterDelegate <NSObject>

- (void)alertPresenter:(id<CLMAlertPresenter>)alertPresenter didFinishPresentingAlert:(CLMAlertCampaign *)alertCampaign;

@end

@protocol CLMAlertPresenter <NSObject>

@property (nullable, nonatomic, strong) id<CLMAlertActionExecutor> actionExecutor;
@property (nullable, nonatomic, weak) id<CLMAlertPresenterDelegate> delegate;

- (void)presentAlert:(CLMAlertCampaign *)alertCampaign
    preferredLanguages:(NSArray<NSString *> *)preferredLanguages
      inViewController:(UIViewController *)controller NS_SWIFT_NAME(present(alert:preferredLanguages:in:));

@end

@interface CLMDefaultAlertPresenter : NSObject <CLMAlertPresenter>

@end

NS_ASSUME_NONNULL_END
