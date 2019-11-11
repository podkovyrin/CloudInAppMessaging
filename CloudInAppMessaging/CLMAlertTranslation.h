//
//  CLMAlertTranslation.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
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
@interface CLMAlertTranslation : NSObject <CLMCloudKitSerializable, CLMAlertDataSource>

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
