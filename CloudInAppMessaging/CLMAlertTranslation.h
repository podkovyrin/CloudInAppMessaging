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

#import "CLMAlertDataSource.h"
#import "CLMCloudKitSerializable.h"

NS_ASSUME_NONNULL_BEGIN

@class CLMAlertCampaign;

/// Name of `CKRecord` for an Alert Translation object on CloudKit
extern NSString *const CLMAlertTranslationRecordType NS_SWIFT_NAME(CLMAlertTranslation.RecordType);
/// Name of the Alert Campaign reference field on CloudKit
extern NSString *const CLMAlertCampaignReferenceKey NS_SWIFT_NAME(CLMAlertCampaign.ReferenceKey);

/// Definition of an Alert Translation object
@interface CLMAlertTranslation : NSObject <NSCopying, CLMCloudKitSerializable, CLMAlertDataSource>

/// Unique identifier of an Alert Translation
@property (readonly, nonatomic, copy) NSString *identifier;

/// A language code of the translation
@property (nullable, nonatomic, copy) NSString *langCode;

/// A translated title of an Alert Campaign
@property (nullable, nonatomic, copy) NSString *title;
/// A translated message of an Alert Campaign
@property (nullable, nonatomic, copy) NSString *message;
/// An alert button translated titles
@property (nonatomic, copy) NSArray<NSString *> *buttonTitles;

/// Returns empty translation object instance for a given Alert Campaign.
- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
