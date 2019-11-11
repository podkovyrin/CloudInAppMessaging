//
//  CLMCloudKitSerializable.h
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import <CloudKit/CloudKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A protocol describing an object that can be serialized to / from CKRecord
@protocol CLMCloudKitSerializable <NSObject>

- (instancetype)initWithRecord:(CKRecord *)record;

- (CKRecordID *)recordID;
- (CKRecord *)record;

@end

NS_ASSUME_NONNULL_END
