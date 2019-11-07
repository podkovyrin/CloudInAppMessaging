//
//  CLMAlertCampaignObject.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMAlertDataSource.h"
#import "CLMCloudKitSerializable.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const CLMAlertCampaignRecordType NS_SWIFT_NAME(CLMAlertCampaign.RecordType);

extern NSString *const CLMAlertCampaignButtonURLNoAction NS_SWIFT_NAME(CLMAlertCampaign.ButtonURLNoAction);

typedef NSString *CLMAlertCampaignTrigger NS_TYPED_EXTENSIBLE_ENUM;
extern CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnForeground;
extern CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnAppLaunch;

@class CLMAlertTranslation;

@interface CLMAlertCampaign : NSObject <CLMCloudKitSerializable, CLMAlertDataSource>

@property (readonly, nonatomic, copy) NSString *identifier;

// Alert
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;

// Buttons
@property (nonatomic, copy) NSArray<NSString *> *buttonActionURLs;
@property (nonatomic, copy) NSArray<NSString *> *buttonTitles;

// Localization
@property (nullable, nonatomic, copy) NSString *defaultLangCode;
@property (nonatomic, copy) NSArray<CLMAlertTranslation *> *translations;

// Targeting
@property (nonatomic, copy) NSArray<NSString *> *countries;
@property (nonatomic, copy) NSArray<NSString *> *languages;
@property (nullable, nonatomic, copy) NSString *maxAppVersion;
@property (nullable, nonatomic, copy) NSString *maxOSVersion;
@property (nullable, nonatomic, copy) NSString *minAppVersion;
@property (nullable, nonatomic, copy) NSString *minOSVersion;

// Scheduling
@property (nullable, nonatomic, strong) NSDate *startDate;
@property (nullable, nonatomic, strong) NSDate *endDate;
@property (nullable, nonatomic, copy) CLMAlertCampaignTrigger trigger;

@end

NS_ASSUME_NONNULL_END
