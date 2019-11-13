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

// This class is heavily inspired by FIRIAMActionUrlFollowerTests from the FirebaseInAppMessaging SDK.
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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "CLMAlertActionDefaultExecutor.h"

@interface CLMAlertActionDefaultExecutor (Testable)

- (instancetype)initWithCustomSchemeURLs:(NSArray<NSString *> *)customSchemeURLs
                             application:(UIApplication *)application;

- (void)followActionURL:(NSURL *)actionURL withCompletionBlock:(void (^)(BOOL success))completion;

@end

// since OCMock does support mocking respondsToSelector on mock object, we have to define
// different delegate classes with different coverages of certain delegate methods:
// CLMAlertActionDefaultExecutor behavior depend on these method implementation coverages on the
// delegate

// this delegate only implements application:continueUserActivity:restorationHandler
@interface AppDelegate1 : NSObject <UIApplicationDelegate>

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *))restorationHandler;

@end

@implementation AppDelegate1

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *))restorationHandler {
    return YES;
}

@end

// this delegate only implements application:openURL:options which is suitable for custom url scheme
// link handling
@interface AppDelegate2 : NSObject <UIApplicationDelegate>

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options;

@end

@implementation AppDelegate2

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    return YES;
}

@end

#pragma mark - Tests

@interface CLMAlertActionDefaultExecutorTests : XCTestCase

@property (nonatomic, strong) UIApplication *mockApplication;
@property (nonatomic, strong) id<UIApplicationDelegate> mockAppDelegate;

@end

@implementation CLMAlertActionDefaultExecutorTests

- (void)setUp {
    [super setUp];

    self.mockApplication = OCMClassMock([UIApplication class]);
}

- (void)testUniversalLinkHandlingReturnYES {
    self.mockAppDelegate = OCMClassMock([AppDelegate1 class]);
    OCMStub([self.mockApplication delegate]).andReturn(self.mockAppDelegate);

    // In this test case, app delegate's application:continueUserActivity:restorationHandler
    // handles the url and returns YES

    NSURL *url = [NSURL URLWithString:@"http://test.com"];
    OCMExpect([self.mockAppDelegate application:[OCMArg isKindOfClass:[UIApplication class]]
                           continueUserActivity:[OCMArg checkWithBlock:^BOOL(id userActivity) {
                               // verifying the type and url field for the userActivity object
                               NSUserActivity *activity = (NSUserActivity *)userActivity;
                               return [activity.activityType
                                          isEqualToString:NSUserActivityTypeBrowsingWeb] &&
                                      [activity.webpageURL isEqual:url];
                           }]
                             restorationHandler:[OCMArg any]])
        .andReturn(YES);

    CLMAlertActionDefaultExecutor *executor =
        [[CLMAlertActionDefaultExecutor alloc] initWithCustomSchemeURLs:@[]
                                                            application:self.mockApplication];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion Callback Triggered"];
    [executor followActionURL:url
          withCompletionBlock:^(BOOL success) {
              XCTAssertTrue(success);
              [expectation fulfill];
          }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    OCMVerifyAll((id)self.mockAppDelegate);
}

- (void)setupOpenURLViaIOSForUIApplicationWithReturnValue:(BOOL)returnValue {
    // it would fallback to either openURL:options:completionHandler:
    //   or openURL: on the UIApplication object to follow the url
    if ([self.mockApplication respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        // id types is needed for calling invokeBlockWithArgs
        id yesOrNo = returnValue ? @YES : @NO;
        OCMStub([self.mockApplication openURL:[OCMArg any]
                                      options:[OCMArg any]
                            completionHandler:([OCMArg invokeBlockWithArgs:yesOrNo, nil])]);
    }
}

- (void)testUniversalLinkHandlingReturnNo {
    self.mockAppDelegate = OCMClassMock([AppDelegate1 class]);
    OCMStub([self.mockApplication delegate]).andReturn(self.mockAppDelegate);

    // In this test case, app delegate's application:continueUserActivity:restorationHandler
    // tries to handle the url but returns NO. We should fallback to the do iOS OpenURL for
    // this case
    NSURL *url = [NSURL URLWithString:@"http://test.com"];
    OCMExpect([self.mockAppDelegate application:[OCMArg isKindOfClass:[UIApplication class]]
                           continueUserActivity:[OCMArg any]
                             restorationHandler:[OCMArg any]])
        .andReturn(NO);

    [self setupOpenURLViaIOSForUIApplicationWithReturnValue:YES];

    CLMAlertActionDefaultExecutor *executor =
        [[CLMAlertActionDefaultExecutor alloc] initWithCustomSchemeURLs:@[]
                                                            application:self.mockApplication];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion Callback Triggered"];
    [executor followActionURL:url
          withCompletionBlock:^(BOOL success) {
              [expectation fulfill];
          }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    OCMVerifyAll((id)self.mockAppDelegate);
}

- (void)testCustomSchemeHandlingReturnYES {
    self.mockAppDelegate = OCMClassMock([AppDelegate2 class]);
    OCMStub([self.mockApplication delegate]).andReturn(self.mockAppDelegate);

    // we support custom url scheme 'scheme1' and 'scheme2' in this setup
    CLMAlertActionDefaultExecutor *executor =
        [[CLMAlertActionDefaultExecutor alloc] initWithCustomSchemeURLs:@[ @"scheme1", @"scheme2" ]
                                                            application:self.mockApplication];

    NSURL *customURL = [NSURL URLWithString:@"scheme1://test.com"];
    OCMExpect([self.mockAppDelegate application:[OCMArg isKindOfClass:[UIApplication class]]
                                        openURL:[OCMArg checkWithBlock:^BOOL(id urlId) {
                                            // verifying url received by the app delegate is expected
                                            NSURL *url = (NSURL *)urlId;
                                            return [url isEqual:customURL];
                                        }]
                                        options:[OCMArg any]])
        .andReturn(YES);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion Callback Triggered"];
    [executor followActionURL:customURL
          withCompletionBlock:^(BOOL success) {
              XCTAssertTrue(success);
              [expectation fulfill];
          }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    OCMVerifyAll((id)self.mockAppDelegate);
}

- (void)testCustomSchemeHandlingReturnNO {
    self.mockAppDelegate = OCMClassMock([AppDelegate2 class]);
    OCMStub([self.mockApplication delegate]).andReturn(self.mockAppDelegate);

    // we support custom url scheme 'scheme1' and 'scheme2' in this setup
    CLMAlertActionDefaultExecutor *executor =
        [[CLMAlertActionDefaultExecutor alloc] initWithCustomSchemeURLs:@[ @"scheme1", @"scheme2" ]
                                                            application:self.mockApplication];

    NSURL *customURL = [NSURL URLWithString:@"scheme1://test.com"];
    OCMExpect([self.mockAppDelegate application:[OCMArg isKindOfClass:[UIApplication class]]
                                        openURL:[OCMArg checkWithBlock:^BOOL(id urlId) {
                                            // verifying url received by the app delegate is expected
                                            NSURL *url = (NSURL *)urlId;
                                            return [url isEqual:customURL];
                                        }]
                                        options:[OCMArg any]])
        .andReturn(NO);

    // it would fallback to Open URL with iOS System
    [self setupOpenURLViaIOSForUIApplicationWithReturnValue:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion Callback Triggered"];
    [executor followActionURL:customURL
          withCompletionBlock:^(BOOL success) {
              // since both custom scheme url open and fallback iOS url open returns NO, we expect
              // to get a NO here
              XCTAssertFalse(success);
              [expectation fulfill];
          }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    OCMVerifyAll((id)self.mockAppDelegate);
}

- (void)testCustomSchemeNotMatching {
    self.mockAppDelegate = OCMClassMock([AppDelegate2 class]);
    OCMStub([self.mockApplication delegate]).andReturn(self.mockAppDelegate);

    // we support custom url scheme 'scheme1' and 'scheme2' in this setup
    CLMAlertActionDefaultExecutor *executor =
        [[CLMAlertActionDefaultExecutor alloc] initWithCustomSchemeURLs:@[ @"scheme1", @"scheme2" ]
                                                            application:self.mockApplication];

    NSURL *customURL = [NSURL URLWithString:@"unknown-scheme://test.com"];

    // since custom scheme does not match, we should not expect app delegate's open URL method
    // being triggered
    OCMReject([self.mockAppDelegate application:[OCMArg any]
                                        openURL:[OCMArg any]
                                        options:[OCMArg any]]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion Callback Triggered"];
    [self setupOpenURLViaIOSForUIApplicationWithReturnValue:YES];

    [executor followActionURL:customURL
          withCompletionBlock:^(BOOL success) {
              XCTAssertTrue(success);
              [expectation fulfill];
          }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    OCMVerifyAll((id)self.mockAppDelegate);
}

- (void)testUniversalLinkWithoutContinueUserActivityDefined {
    // AppDelegate2 does not define application:continueUserActivity:restorationHandler
    self.mockAppDelegate = OCMClassMock([AppDelegate2 class]);
    OCMStub([self.mockApplication delegate]).andReturn(self.mockAppDelegate);

    CLMAlertActionDefaultExecutor *executor =
        [[CLMAlertActionDefaultExecutor alloc] initWithCustomSchemeURLs:@[]
                                                            application:self.mockApplication];

    // so for this url, even if it's a http or https link, we should fall back to openURL with
    // iOS system
    NSURL *url = [NSURL URLWithString:@"http://test.com"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion Callback Triggered"];
    [self setupOpenURLViaIOSForUIApplicationWithReturnValue:YES];

    [executor followActionURL:url
          withCompletionBlock:^(BOOL success) {
              XCTAssertTrue(success);
              [expectation fulfill];
          }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
