//
//  CLMAlertCampaignObject.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMAlertDataSource.h"
#import "CLMCloudKitSerializable.h"

NS_ASSUME_NONNULL_BEGIN

@class CLMAlertTranslation;

/// Name of `CKRecord` for an Alert Campaign object on CloudKit
extern NSString *const CLMAlertCampaignRecordType NS_SWIFT_NAME(CLMAlertCampaign.RecordType);

/// Constant that represents dummy button action (alert will be dismissed). Suitable for a 'Cancel' button
/// or an alert with the single 'OK' button.
extern NSString *const CLMAlertCampaignButtonURLNoAction NS_SWIFT_NAME(CLMAlertCampaign.ButtonURLNoAction);

/// Definition of different trigger's type's. When the alert should be shown.
typedef NSString *CLMAlertCampaignTrigger NS_TYPED_EXTENSIBLE_ENUM;
/// Show an alert when `UIApplicationWillEnterForegroundNotification` occurs.
extern CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnForeground;
/// Show an alert when fetching has been completed.
extern CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnAppLaunch;

/// Definition of an Alert Campaign
@interface CLMAlertCampaign : NSObject <CLMCloudKitSerializable, CLMAlertDataSource>

/// Unique identifier of an Alert Campaign
@property (readonly, nonatomic, copy) NSString *identifier;

// Alert

/// A title of an Alert Campaign
@property (nullable, nonatomic, copy) NSString *title;
/// A message of an Alert Campaign
@property (nullable, nonatomic, copy) NSString *message;

// Buttons

/// An alert button actions
@property (nonatomic, copy) NSArray<NSString *> *buttonActionURLs;
/// An alert button titles (corresponds to button actions)
@property (nonatomic, copy) NSArray<NSString *> *buttonTitles;

// Localization

/// A language code of `title`, `message` and `buttonTitles`.
@property (nullable, nonatomic, copy) NSString *defaultLangCode;
/// Available translations for an Alert Campaign
@property (nonatomic, copy) NSArray<CLMAlertTranslation *> *translations;

// Targeting

/// A Bundle Identifier of target App
@property (nullable, nonatomic, copy) NSString *bundleIdentifier;
/// A target device's countries in which an Alert Campaign should be shown
@property (nonatomic, copy) NSArray<NSString *> *countries;
/// A target device's preferred languages to show an Alert Campaign
@property (nonatomic, copy) NSArray<NSString *> *languages;
/// A target device's max App version
@property (nullable, nonatomic, copy) NSString *maxAppVersion;
/// A target device's max OS version
@property (nullable, nonatomic, copy) NSString *maxOSVersion;
/// A target device's min App version
@property (nullable, nonatomic, copy) NSString *minAppVersion;
/// A target device's min OS version
@property (nullable, nonatomic, copy) NSString *minOSVersion;

// Scheduling

/// A start date of Alert Campaign. When `startDate` is not specified Alert Campaign starts immediately.
@property (nullable, nonatomic, strong) NSDate *startDate;
/// An end date of Alert Campaign. When `endDate` is not specified Alert Campaign lasts forever.
@property (nullable, nonatomic, strong) NSDate *endDate;
/// A desired event after which an Alert Campaign should be shown.
@property (nullable, nonatomic, copy) CLMAlertCampaignTrigger trigger;

/// Checks if the current time is earlier than `endDate` or returns `NO` if `endDate` is not specified.
- (BOOL)alertHasExpired;
/// Checks if the current time is later than `startDate` or returns `YES` if `startDate` is not specified.
- (BOOL)alertHasStarted;
/// Checks if Alert Campaign should be shown for a given trigger.
- (BOOL)alertDisplayedOnTrigger:(CLMAlertCampaignTrigger)trigger;

@end

NS_ASSUME_NONNULL_END
