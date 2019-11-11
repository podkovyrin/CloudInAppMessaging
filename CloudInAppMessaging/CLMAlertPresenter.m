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

#import "CLMAlertPresenter.h"

#import "CLMAlertCampaign+CLMPresenting.h"
#import "CLMAlertCampaign.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CLMDefaultAlertPresenter

@synthesize actionExecutor = _actionExecutor;
@synthesize delegate = _delegate;

- (void)presentAlert:(CLMAlertCampaign *)alertCampaign
    preferredLanguages:(NSArray<NSString *> *)preferredLanguages
      inViewController:(UIViewController *)controller {
    NSAssert(self.actionExecutor, @"The actionExecutor must be set before calling present");
    NSAssert(preferredLanguages.count > 0, @"Preferred Languages must not be empty");
    NSParameterAssert(controller);

    id<CLMAlertDataSource> dataSource = [alertCampaign clm_dataSourceForPreferredLanguages:preferredLanguages];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:dataSource.title
                                                                   message:dataSource.message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSArray<NSString *> *buttonActionURLs = alertCampaign.buttonActionURLs;
    BOOL hasCancel = NO;
    for (NSUInteger i = 0; i < buttonActionURLs.count; i++) {
        NSString *buttonTitle = dataSource.buttonTitles[i];
        NSString *buttonAction = buttonActionURLs[i];

        const BOOL hasAction = ![buttonAction isEqualToString:CLMAlertCampaignButtonURLNoAction];
        const UIAlertActionStyle style = hasAction || hasCancel ? UIAlertActionStyleDefault : UIAlertActionStyleCancel;

        if (style == UIAlertActionStyleCancel) {
            hasCancel = YES;
        }

        void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
            [self.delegate alertPresenter:self didFinishPresentingAlert:alertCampaign];

            if (hasAction) {
                [self.actionExecutor performAlertButtonAction:buttonAction inContext:controller];
            }
        };

        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle style:style handler:handler];
        [alert addAction:action];
    }

    if (alert.actions.count == 1) {
        alert.preferredAction = alert.actions.firstObject;
    }

    [controller presentViewController:alert animated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
