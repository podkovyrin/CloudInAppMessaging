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

@interface CLMAlertPresenter ()

@property (readonly, nonatomic, copy) NSArray<NSString *> *preferredLanguages;

@end

@implementation CLMAlertPresenter

- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign {
    return [self initWithAlertCampaign:alertCampaign preferredLanguages:nil];
}

- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign
                   preferredLanguages:(nullable NSArray<NSString *> *)preferredLanguages {
    self = [super init];
    if (self) {
        if (!preferredLanguages) {
            preferredLanguages = [NSLocale preferredLanguages];
        }
        
        NSAssert(preferredLanguages.count > 0, @"Preferred Languages must not be empty");
        
        _alertCampaign = alertCampaign;
        _preferredLanguages = [preferredLanguages copy];
    }
    return self;
}

- (void)presentInViewController:(UIViewController *)controller {
    NSParameterAssert(controller);
    NSAssert(self.actionExecutor, @"The actionExecutor must be set before calling present");
    
    id<CLMAlertDataSource> dataSource = [self alertDataSourceForPreferredLanguage];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:dataSource.title
                                                                   message:dataSource.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSArray<NSString *> *buttonActionURLs = self.alertCampaign.buttonActionURLs;
    for (NSUInteger i = 0; i < buttonActionURLs.count; i++) {
        NSString *buttonTitle = dataSource.buttonTitles[i];
        NSString *buttonAction = buttonActionURLs[i];
        
        const BOOL hasAction = ![buttonAction isEqualToString:CLMAlertCampaignButtonURLNoAction];
        const UIAlertActionStyle style = hasAction ? UIAlertActionStyleDefault : UIAlertActionStyleCancel;
        
        void (^handler)(UIAlertAction *action) = nil;
        if (hasAction) {
            handler = ^(UIAlertAction *action) {
                [self.actionExecutor performAlertButtonAction:buttonAction inContext:controller];
            };
        }
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle style:style handler:handler];
        [alert addAction:action];
    }
    
    if (alert.actions.count == 1) {
        alert.preferredAction = alert.actions.firstObject;
    }
    
    [controller presentViewController:alert animated:YES completion:nil];
}

- (id<CLMAlertDataSource>)alertDataSourceForPreferredLanguage {
    CLMAlertCampaign *alertCampaign = self.alertCampaign;
    
    for (NSString *language in self.preferredLanguages) {
        NSString *langCode = language;
        if ([language rangeOfString:@"_"].location != NSNotFound) {
            NSArray<NSString *> *components = [language componentsSeparatedByString:@"_"];
            langCode = components.firstObject;
        }
        
        if ([alertCampaign.defaultLangCode isEqualToString:langCode]) {
            return alertCampaign;
        }
        
        for (CLMAlertTranslation *translation in alertCampaign.translations) {
            if ([translation.langCode isEqualToString:langCode]) {
                // Create new CLMAlertTranslation and fallback to defaults if any entity wasn't translated
                // This `resultTranslation` can't be used other than for displaying because it has different identifier
                // (and it's impossible to mis-use it because we return it as protocol CLMAlertDataSource)
                CLMAlertTranslation *resultTranslation = [[CLMAlertTranslation alloc] init];
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
    
    return self.alertCampaign;
}

@end

NS_ASSUME_NONNULL_END
