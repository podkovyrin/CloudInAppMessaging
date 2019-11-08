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

NS_ASSUME_NONNULL_BEGIN

/**
* To avoid the risk of hijacking the app's existing view transition flow, we render in-app message
* views in a top level UI Window instead of presenting from app's existing UIWindow. The caller is
* supposed to set the rootViewController to be the appropriate view controller for the in-app
* message and call setHidden:NO to make it really visible.
*/
@interface CLMPresentingWindowHelper : NSObject

/// Return the singleton UIWindow that can be used for presenting alerts
+ (UIWindow *)UIWindowForPresenting;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
