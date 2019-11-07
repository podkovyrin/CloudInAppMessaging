//
//  CLMAlertTranslation.m
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMAlertTranslation.h"

#import "CLMAlertCampaign.h"
#import "Private/CLMKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const CLMAlertTranslationRecordType = @"AlertTranslation";
NSString *const CLMAlertCampaignReferenceKey = @"alertCampaign";

@interface CLMAlertTranslation ()

@property (nullable, nonatomic, strong) CKRecordID *alertCampaignRecordID;

@end

@implementation CLMAlertTranslation

- (instancetype)initWithAlertCampaign:(CLMAlertCampaign *)alertCampaign {
    self = [super init];
    if (self) {
        _alertCampaignRecordID = [alertCampaign recordID];

        _identifier = [NSUUID UUID].UUIDString;
        _buttonTitles = [NSArray array];
    }
    return self;
}

#pragma mark - CLMCloudKitSerializable

- (instancetype)initWithRecord:(CKRecord *)record {
    self = [super init];
    if (self) {
        CKReference *alertReference = record[CLMAlertCampaignReferenceKey];
        _alertCampaignRecordID = alertReference.recordID;

        _identifier = [record.recordID.recordName copy];

        _langCode = [record[CLM_KEYPATH(self, langCode)] copy];

        _title = [record[CLM_KEYPATH(self, title)] copy];
        _message = [record[CLM_KEYPATH(self, message)] copy];
        _buttonTitles = [record[CLM_KEYPATH(self, buttonTitles)] copy] ?: [NSArray array];
    }

    return self;
}

- (CKRecordID *)recordID {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.identifier];
    return recordID;
}

- (CKRecord *)record {
    CKRecordID *recordID = [self recordID];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:CLMAlertTranslationRecordType recordID:recordID];

    record[CLM_KEYPATH(self, langCode)] = self.langCode;

    record[CLM_KEYPATH(self, title)] = self.title;
    record[CLM_KEYPATH(self, message)] = self.message;
    record[CLM_KEYPATH(self, buttonTitles)] = self.buttonTitles;

    // https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/AddingReferences/AddingReferences.html#//apple_ref/doc/uid/TP40014987-CH7-SW1
    // To represent a one-to-many relationship between your model objects, it is more efficient if the reference is from the child record to the parent record—that is, add a reference field to the child record.
    CKReference *alertReference = [[CKReference alloc] initWithRecordID:self.alertCampaignRecordID
                                                                 action:CKReferenceActionDeleteSelf];
    record[CLMAlertCampaignReferenceKey] = alertReference;

    return record;
}

@end

NS_ASSUME_NONNULL_END
