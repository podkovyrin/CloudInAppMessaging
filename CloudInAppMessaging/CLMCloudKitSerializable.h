//
//  CLMCloudKitSerializable.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import <CloudKit/CloudKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CLMCloudKitSerializable <NSObject>

- (instancetype)initWithRecord:(CKRecord *)record;

- (CKRecordID *)recordID;
- (CKRecord *)record;

@end

NS_ASSUME_NONNULL_END
