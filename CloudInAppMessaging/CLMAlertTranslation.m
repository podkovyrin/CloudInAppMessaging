//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
    return [self initWithIdentifier:[NSUUID UUID].UUIDString alertCampaignRecordID:[alertCampaign recordID]];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
             alertCampaignRecordID:(CKRecordID *)alertCampaignRecordID {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _alertCampaignRecordID = alertCampaignRecordID;
        _buttonTitles = [NSArray array];
    }

    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToAlertTranslation:object];
}

- (BOOL)isEqualToAlertTranslation:(CLMAlertTranslation *)object {
    if (!object) {
        return NO;
    }

    BOOL equals = self.identifier == object.identifier || [self.identifier isEqualToString:object.identifier];
    if (!equals) {
        return NO;
    }

    equals = self.langCode == object.langCode || [self.langCode isEqualToString:object.langCode];
    if (!equals) {
        return NO;
    }

    equals = self.title == object.title || [self.title isEqualToString:object.title];
    if (!equals) {
        return NO;
    }

    equals = self.message == object.message || [self.message isEqualToString:object.message];
    if (!equals) {
        return NO;
    }

    equals = self.buttonTitles == object.buttonTitles || [self.buttonTitles isEqualToArray:object.buttonTitles];
    if (!equals) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash {
    return (self.identifier.hash ^
            self.langCode.hash ^
            self.title.hash ^
            self.message.hash ^
            self.buttonTitles.hash);
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    typeof(self) copy = [[self.class alloc] initWithIdentifier:self.identifier
                                         alertCampaignRecordID:self.alertCampaignRecordID];

    copy.langCode = self.langCode;

    copy.title = self.title;
    copy.message = self.message;

    copy.buttonTitles = self.buttonTitles;

    return copy;
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
