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

#import "CLMAlertPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMCloudInAppMessaging : NSObject

/// A boolean flag that can be used to suppress alert display. Default is false.
@property (nonatomic, assign) BOOL messageDisplaySuppressed;

/// A boolean flag that can be used to disable fetching and displaying alerts. Default is true.
@property (nonatomic, assign) BOOL enabled;

/// This is display component that will be used by CloudInAppMessaging SDK to display alerts.
/// If it's nil the default will be used (display via UIAlertController).
@property (nullable, nonatomic, strong) id<CLMAlertPresenter> alertPresenter;

/// Entry point for starting up CloudInAppMessaging.
///
/// The specified identifier must correspond to one of the ubiquity containers listed in
/// the iCloud capabilities section of your Xcode project. Including the identifier
/// with your app’s capabilities adds the corresponding entitlements to your app.
/// If nil is specified a default container will be used.
+ (instancetype)setupWithCloudKitContainerIdentifier:(nullable NSString *)containerIdentifier NS_SWIFT_NAME(setup(with:));
+ (instancetype)sharedInstance NS_SWIFT_NAME(shared());

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
