//
//  CLMAlertCampaignObject.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMCloudKitSerializable.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CLMAlertCampaignButtonURLNoAction NS_SWIFT_NAME(CLMAlertCampaign.buttonURLNoAction);

typedef NSString * CLMAlertCampaignTrigger NS_TYPED_EXTENSIBLE_ENUM;
CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnForeground;
CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnAppLaunch;

@class CLMAlertTranslation;

@interface CLMAlertCampaign : NSObject <CLMCloudKitSerializable>

@property (readonly, nonatomic, copy) NSString *identifier;

// Alert
@property (nullable, nonatomic, copy) NSString *alertTitle;
@property (nullable, nonatomic, copy) NSString *alertMessage;

// Buttons

/// Empty string as URL means "no action"
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
