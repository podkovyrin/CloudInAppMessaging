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

#import <CloudKit/CloudKit.h>

#import "CLMAlertCampaignFetcher.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CLMClientInfo;

/// A service for fetching data from CloudKit.
@interface CLMCKService : NSObject <CLMAlertCampaignFetcher>

/// The specified identifier must correspond to one of the ubiquity containers listed in
/// the iCloud capabilities section of your Xcode project. Including the identifier
/// with your app’s capabilities adds the corresponding entitlements to your app.
/// If nil is specified default container will be used
- (instancetype)initWithContainerIdentifier:(nullable NSString *)identifier
                                 clientInfo:(id<CLMClientInfo>)clientInfo;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
