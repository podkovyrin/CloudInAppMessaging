//
//  CLMAlertTranslation.m
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMAlertTranslation.h"

#import "Private/CLMKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kRecordType = @"AlertTranslation";

@implementation CLMAlertTranslation

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [NSUUID UUID].UUIDString;
        _buttonTitles = [NSArray array];
    }
    
    return self;
}

#pragma mark - CLMCloudKitSerializable

- (instancetype)initWithRecord:(CKRecord *)record {
    self = [super init];
    if (self) {
        _identifier = [record.recordID.recordName copy];
        
        _langCode = [record[CLM_KEYPATH(self, langCode)] copy];

        _title = [record[CLM_KEYPATH(self, title)] copy];
        _message = [record[CLM_KEYPATH(self, message)] copy];
        _buttonTitles = [record[CLM_KEYPATH(self, buttonTitles)] copy] ?: [NSArray array];
    }
    
    return self;
}

- (CKRecord *)recordInZone:(CKRecordZone *)zone {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.identifier zoneID:zone.zoneID];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:kRecordType recordID:recordID];
    
    record[CLM_KEYPATH(self, langCode)] = self.langCode;

    record[CLM_KEYPATH(self, title)] = self.title;
    record[CLM_KEYPATH(self, message)] = self.message;
    record[CLM_KEYPATH(self, buttonTitles)] = self.buttonTitles;

    return record;
}

@end

NS_ASSUME_NONNULL_END
