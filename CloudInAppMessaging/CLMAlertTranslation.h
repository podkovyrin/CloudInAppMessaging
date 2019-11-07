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

extern NSString *const CLMAlertTranslationRecordType NS_SWIFT_NAME(CLMAlertTranslation.RecordType);
extern NSString *const CLMAlertCampaignReferenceKey NS_SWIFT_NAME(CLMAlertCampaign.ReferenceKey);

@interface CLMAlertTranslation : NSObject <CLMCloudKitSerializable, CLMAlertDataSource>

@property (readonly, nonatomic, copy) NSString *identifier;

@property (nullable, nonatomic, copy) NSString *langCode;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSArray<NSString *> *buttonTitles;

- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
