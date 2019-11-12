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

// This class is heavily inspired by FIRIAMActionURLFollower from the FirebaseInAppMessaging SDK.
// https://github.com/firebase/firebase-ios-sdk/

/*
* Copyright 2018 Google
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

#import <UIKit/UIKit.h>

#import "CLMAlertActionDefaultExecutor.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMAlertActionDefaultExecutor ()

@property (readonly, nonatomic, copy) NSSet<NSString *> *appCustomURLSchemesSet;
@property (readonly, nonatomic, assign) BOOL isNewAppDelegateOpenURLDefined;
@property (readonly, nonatomic, assign) BOOL isContinueUserActivityMethodDefined;

@property (nullable, readonly, nonatomic, strong) id<UIApplicationDelegate> appDelegate;
@property (readonly, nonatomic, strong) UIApplication *mainApplication;

@end

@implementation CLMAlertActionDefaultExecutor

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray<NSString *> *customSchemeURLs = [[NSMutableArray alloc] init];

        // Reading the custom url list from the environment.
        NSBundle *appBundle = [NSBundle mainBundle];
        if (appBundle) {
            id URLTypesID = [appBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];
            if ([URLTypesID isKindOfClass:[NSArray class]]) {
                NSArray *urlTypesArray = (NSArray *)URLTypesID;

                for (id nextURLType in urlTypesArray) {
                    if ([nextURLType isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *nextURLTypeDict = (NSDictionary *)nextURLType;
                        id nextSchemeArray = nextURLTypeDict[@"CFBundleURLSchemes"];
                        if (nextSchemeArray && [nextSchemeArray isKindOfClass:[NSArray class]]) {
                            [customSchemeURLs addObjectsFromArray:nextSchemeArray];
                        }
                    }
                }
            }
        }

        UIApplication *application = UIApplication.sharedApplication;
        _appCustomURLSchemesSet = [NSSet setWithArray:customSchemeURLs];
        _mainApplication = application;
        _appDelegate = application.delegate;

        if (_appDelegate) {
            _isNewAppDelegateOpenURLDefined =
                [_appDelegate respondsToSelector:@selector(application:openURL:options:)];

            _isContinueUserActivityMethodDefined = [_appDelegate
                respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)];
        }
    }
    return self;
}

#pragma mark - CLMAlertActionExecutor

- (void)performAlertButtonAction:(NSString *)action inContext:(UIViewController *)context {
    NSURL *url = [NSURL URLWithString:action];
    if (!url) {
        return;
    }

    [self followActionURL:url
        withCompletionBlock:^(BOOL success){
        }];
}

#pragma mark - Private

- (void)followActionURL:(NSURL *)actionURL withCompletionBlock:(void (^)(BOOL success))completion {
    // So this is the logic of the url following flow
    //  1 If it's a http or https link
    //     1.1 If delegate implements application:continueUserActivity:restorationHandler: and calling
    //       it returns YES: the flow stops here: we have finished the url-following action
    //     1.2 In other cases: fall through to step 3
    //  2 If the URL scheme matches any element in appCustomURLSchemes
    //     2.1 Triggers application:openURL:options: or
    //     application:openURL:sourceApplication:annotation:
    //          depending on their availability.
    //  3 Use UIApplication openURL: or openURL:options:completionHandler: to have iOS system to deal
    //     with the url following.
    //
    //  The rationale for doing step 1 and 2 instead of simply doing step 3 for all cases are:
    //     I)  calling UIApplication openURL with the universal link targeted for current app would
    //         not cause the link being treated as a universal link. See apple doc at
    // https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/UniversalLinks.html
    //         So step 1 is trying to handle this gracefully
    //     II) If there are other apps on the same device declaring the same custom url scheme as for
    //         the current app, doing step 3 directly have the risk of triggering another app for
    //         handling the custom scheme url: See the note about "If more than one third-party" from
    // https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html
    //         So step 2 is to optimize user experience by short-circuiting the engagement with iOS
    //         system

    if ([self.class isHttpOrHttpsScheme:actionURL]) {
        if ([self followURLWithContinueUserActivity:actionURL]) {
            completion(YES);
            return; // following the url has been fully handled by App Delegate's
                    // continueUserActivity method
        }
    }
    else if ([self isCustomSchemeForCurrentApp:actionURL]) {
        if ([self followURLWithAppDelegateOpenURLActivity:actionURL]) {
            completion(YES);
            return; // following the url has been fully handled by App Delegate's openURL method
        }
    }

    [self followURLViaIOS:actionURL withCompletionBlock:completion];
}

// Try to handle the url as a custom scheme url link by triggering
// application:openURL:options: on App's delegate object directly.
// @returns YES if that delegate method is defined and returns YES.
- (BOOL)followURLWithAppDelegateOpenURLActivity:(NSURL *)url {
    if (self.isNewAppDelegateOpenURLDefined) {
        return [self.appDelegate application:self.mainApplication openURL:url options:@{}];
    }

    return NO;
}

// Try to handle the url as a universal link by triggering
// application:continueUserActivity:restorationHandler: on App's delegate object directly.
// @returns YES if that delegate method is defined and seeing a YES being returned from
// trigging it
- (BOOL)followURLWithContinueUserActivity:(NSURL *)url {
    if (self.isContinueUserActivityMethodDefined) {
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSUserActivityTypeBrowsingWeb];
        userActivity.webpageURL = url;
        BOOL handled = [self.appDelegate application:self.mainApplication
                                continueUserActivity:userActivity
                                  restorationHandler:^(NSArray *restorableObjects) {
                                      // mimic system behavior of triggering restoreUserActivityState:
                                      // method on each element of restorableObjects
                                      for (id nextRestoreObject in restorableObjects) {
                                          if ([nextRestoreObject isKindOfClass:[UIResponder class]]) {
                                              UIResponder *responder = (UIResponder *)nextRestoreObject;
                                              [responder restoreUserActivityState:userActivity];
                                          }
                                      }
                                  }];
        return handled;
    }
    else {
        return NO;
    }
}

- (void)followURLViaIOS:(NSURL *)url withCompletionBlock:(void (^)(BOOL success))completion {
    [self.mainApplication openURL:url
                          options:@{}
                completionHandler:^(BOOL success) {
                    completion(success);
                }];
}

- (BOOL)isCustomSchemeForCurrentApp:(NSURL *)url {
    NSString *schemeInLowerCase = [url.scheme lowercaseString];
    return [self.appCustomURLSchemesSet containsObject:schemeInLowerCase];
}

+ (BOOL)isHttpOrHttpsScheme:(NSURL *)url {
    NSString *schemeInLowerCase = [url.scheme lowercaseString];
    return [schemeInLowerCase isEqualToString:@"https"] || [schemeInLowerCase isEqualToString:@"http"];
}

@end

NS_ASSUME_NONNULL_END
