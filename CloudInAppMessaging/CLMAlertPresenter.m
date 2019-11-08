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

#import "CLMAlertCampaign.h"
#import "CLMAlertTranslation.h"

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

    id<CLMAlertDataSource> dataSource = [self dataSourceForAlert:alertCampaign
                                              preferredLanguages:preferredLanguages];

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

#pragma mark - Private

- (id<CLMAlertDataSource>)dataSourceForAlert:(CLMAlertCampaign *)alertCampaign
                          preferredLanguages:(NSArray<NSString *> *)preferredLanguages {
    for (NSString *langCode in preferredLanguages) {
        if ([alertCampaign.defaultLangCode isEqualToString:langCode]) {
            return alertCampaign;
        }

        for (CLMAlertTranslation *translation in alertCampaign.translations) {
            if ([translation.langCode isEqualToString:langCode]) {
                // Create new CLMAlertTranslation and fallback to defaults if any entity wasn't translated
                // This `resultTranslation` can't be used other than for displaying because it has different identifier
                // (and it's impossible to mis-use it because we return it as protocol CLMAlertDataSource)
                CLMAlertTranslation *resultTranslation = [[CLMAlertTranslation alloc] initWithAlertCampaign:alertCampaign];
                resultTranslation.langCode = translation.langCode;
                resultTranslation.title = translation.title.length > 0 ? translation.title : alertCampaign.title;
                resultTranslation.message = translation.message.length > 0 ? translation.message : alertCampaign.message;

                NSMutableArray<NSString *> *buttonTitles = [NSMutableArray array];
                for (NSUInteger i = 0; i < translation.buttonTitles.count; i++) {
                    NSString *buttonTitle = translation.buttonTitles[i];
                    if (buttonTitle.length == 0) {
                        buttonTitle = alertCampaign.buttonTitles[i];
                    }
                    [buttonTitles addObject:buttonTitle];
                }
                resultTranslation.buttonTitles = buttonTitles;

                return resultTranslation;
            }
        }
    }

    return alertCampaign;
}

@end

NS_ASSUME_NONNULL_END
