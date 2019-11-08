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

#import "CLMPresentingWindowHelper.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CLMPresentingWindowHelper

+ (UIWindow *)UIWindowForPresenting {
    static UIWindow *UIWindowForPresenting;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
#if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            UIWindowScene *foregroundedScene = [[self class] foregroundedScene];
            UIWindowForPresenting = [[UIWindow alloc] initWithWindowScene:foregroundedScene];
        }
        else {
#endif // defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
            UIWindowForPresenting = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif // defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        UIWindowForPresenting.windowLevel = UIWindowLevelNormal;
    });

    return UIWindowForPresenting;
}

#pragma mark - Private

#if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
+ (UIWindowScene *)foregroundedScene API_AVAILABLE(ios(13.0)) {
    for (UIWindowScene *connectedScene in [UIApplication sharedApplication].connectedScenes) {
        if (connectedScene.activationState == UISceneActivationStateForegroundActive) {
            return connectedScene;
        }
    }

    return nil;
}
#endif

@end

NS_ASSUME_NONNULL_END
