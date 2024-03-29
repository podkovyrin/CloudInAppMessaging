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

#import "../CLMAlertCampaign.h"
#import "../CLMAlertPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class CLMSettings;

/// A class for managing the objects / dependencies of CloudInAppMessaging SDK
@interface CLMManager : NSObject

@property (nullable, nonatomic, strong) id<CLMAlertPresenter> alertPresenter;

/// The specified identifier must correspond to one of the ubiquity containers listed in
/// the iCloud capabilities section of your Xcode project. Including the identifier
/// with your app’s capabilities adds the corresponding entitlements to your app.
/// If nil is specified default container will be used
- (instancetype)initWithCloudKitContainerIdentifier:(nullable NSString *)containerIdentifier
                                           settings:(CLMSettings *)settings;

- (void)setMessageDisplaySuppressed:(BOOL)messageDisplaySuppressed;

- (void)resume;
- (void)pause;

/// Check and display next in-app alert eligible for a given trigger (such as custom analytics event).
- (void)checkAndDisplayNextAlertForTrigger:(CLMAlertCampaignTrigger)trigger;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
