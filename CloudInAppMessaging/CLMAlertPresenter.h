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

/// A protocol describing a delegate of the CLMAlertPresenter.
@protocol CLMAlertPresenterDelegate

/// Called when the alert is dismissed. Should be called from main thread.
/// @param alertPresenter A presenter of the alert.
/// @param alertCampaign An alert that was dismissed.
- (void)alertPresenter:(id<CLMAlertPresenter>)alertPresenter didFinishPresentingAlert:(CLMAlertCampaign *)alertCampaign;

@end


/// A protocol describing a component that used to display Alert Campaigns.
@protocol CLMAlertPresenter

/// An executor of the alert action.
@property (nullable, nonatomic, strong) id<CLMAlertActionExecutor> actionExecutor;
/// A delegate to notify about presentation events. CLMAlertPresenter *must* call delegate's method
/// when presentation is finished.
/// This property is used internally and should not be used by clients.
@property (nullable, nonatomic, weak) id<CLMAlertPresenterDelegate> delegate;

/// Presents the given Alert Campaign to the user.
/// @param alertCampaign An Alert Campaign to present.
/// @param preferredLanguages An array of user preferred languages in which Alert Campaign can be dispayed.
/// @param controller A parent controller to present on.
- (void)presentAlert:(CLMAlertCampaign *)alertCampaign
    preferredLanguages:(NSArray<NSString *> *)preferredLanguages
      inViewController:(UIViewController *)controller NS_SWIFT_NAME(present(alert:preferredLanguages:in:));

@end


/// Default implementation of `CLMAlertPresenter` protocol
/// UIAlertController is used as a display component.
@interface CLMDefaultAlertPresenter : NSObject <CLMAlertPresenter>

@end

NS_ASSUME_NONNULL_END
