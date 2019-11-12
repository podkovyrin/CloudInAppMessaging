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

/// A protocol for wrapping the interactions for retrieving client side info to be used in request
/// parameter for interacting with CloudKit and filtering Alert Campaigns.
@protocol CLMClientInfo

/// App's Bundle Identifier.
@property (readonly, nonatomic, copy) NSString *bundleIdentifier;
/// Languages extracted from `[NSLocale preferredLanguages]`.
@property (readonly, nonatomic, copy) NSArray<NSString *> *preferredLanguages;
/// A country code from the current locale.
@property (nullable, readonly, nonatomic, copy) NSString *countryCode;
/// App's version.
@property (readonly, nonatomic, copy) NSString *appVersion;
/// Current iOS version.
@property (readonly, nonatomic, copy) NSString *osVersion;

@end


/// Default implementation of CLMClientInfo protocol which retrieves data
/// from main NSBundle or current NSLocale
@interface CLMClientInfo : NSObject <CLMClientInfo>

@end

NS_ASSUME_NONNULL_END
