//
//  CLMAlertTranslation.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMCloudKitSerializable.h"
#import "CLMAlertDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMAlertTranslation : NSObject <CLMCloudKitSerializable, CLMAlertDataSource>

@property (readonly, nonatomic, copy) NSString *identifier;

@property (nullable, nonatomic, copy) NSString *langCode;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSArray<NSString *> *buttonTitles;

@end

NS_ASSUME_NONNULL_END
