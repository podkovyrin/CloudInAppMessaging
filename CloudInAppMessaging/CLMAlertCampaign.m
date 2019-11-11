//
//  CLMAlertCampaignObject.m
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMAlertCampaign.h"

#import "CLMAlertTranslation.h"
#import "Private/CLMKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const CLMAlertCampaignButtonURLNoAction = @"CLM_NO_ACTION_URL";

CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnForeground = @"CLMAlertCampaignTriggerOnForeground";
CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnAppLaunch = @"CLMAlertCampaignTriggerOnAppLaunch";

NSString *const CLMAlertCampaignRecordType = @"AlertCampaign";

@implementation CLMAlertCampaign

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [NSUUID UUID].UUIDString;
        _buttonActionURLs = [NSArray array];
        _buttonTitles = [NSArray array];
        _translations = [NSArray array];
        _countries = [NSArray array];
        _languages = [NSArray array];
    }

    return self;
}

- (void)setMaxAppVersion:(nullable NSString *)maxAppVersion {
    _maxAppVersion = [maxAppVersion stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)setMaxOSVersion:(nullable NSString *)maxOSVersion {
    _maxOSVersion = [maxOSVersion stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)setMinAppVersion:(nullable NSString *)minAppVersion {
    _minAppVersion = [minAppVersion stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)setMinOSVersion:(nullable NSString *)minOSVersion {
    _minOSVersion = [minOSVersion stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

#pragma mark - Public

- (BOOL)alertHasExpired {
    if (self.endDate) {
        return self.endDate.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970;
    }

    return NO;
}

- (BOOL)alertHasStarted {
    if (self.startDate) {
        return self.startDate.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970;
    }

    return YES;
}

- (BOOL)alertDisplayedOnTrigger:(CLMAlertCampaignTrigger)trigger {
    NSAssert(self.trigger, @"Trigger is invalid");

    if (self.trigger) {
        return [self.trigger isEqualToString:trigger];
    }

    return YES;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToAlertCampaign:object];
}

- (BOOL)isEqualToAlertCampaign:(CLMAlertCampaign *)object {
    if (!object) {
        return NO;
    }

    BOOL equals = self.identifier == object.identifier || [self.identifier isEqualToString:object.identifier];
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

    equals = self.buttonActionURLs == object.buttonActionURLs || [self.buttonActionURLs isEqualToArray:object.buttonActionURLs];
    if (!equals) {
        return NO;
    }

    equals = self.buttonTitles == object.buttonTitles || [self.buttonTitles isEqualToArray:object.buttonTitles];
    if (!equals) {
        return NO;
    }

    equals = self.defaultLangCode == object.defaultLangCode || [self.defaultLangCode isEqualToString:object.defaultLangCode];
    if (!equals) {
        return NO;
    }

    equals = self.translations == object.translations || [self.translations isEqualToArray:object.translations];
    if (!equals) {
        return NO;
    }

    equals = self.bundleIdentifier == object.bundleIdentifier || [self.bundleIdentifier isEqualToString:object.bundleIdentifier];
    if (!equals) {
        return NO;
    }

    equals = self.countries == object.countries || [self.countries isEqualToArray:object.countries];
    if (!equals) {
        return NO;
    }

    equals = self.languages == object.languages || [self.languages isEqualToArray:object.languages];
    if (!equals) {
        return NO;
    }

    equals = self.maxAppVersion == object.maxAppVersion || [self.maxAppVersion isEqualToString:object.maxAppVersion];
    if (!equals) {
        return NO;
    }

    equals = self.maxOSVersion == object.maxOSVersion || [self.maxOSVersion isEqualToString:object.maxOSVersion];
    if (!equals) {
        return NO;
    }

    equals = self.minAppVersion == object.minAppVersion || [self.minAppVersion isEqualToString:object.minAppVersion];
    if (!equals) {
        return NO;
    }

    equals = self.minOSVersion == object.minOSVersion || [self.minOSVersion isEqualToString:object.minOSVersion];
    if (!equals) {
        return NO;
    }

    equals = self.startDate == object.startDate || [self.startDate isEqualToDate:object.startDate];
    if (!equals) {
        return NO;
    }

    equals = self.endDate == object.endDate || [self.endDate isEqualToDate:object.endDate];
    if (!equals) {
        return NO;
    }

    equals = self.trigger == object.trigger || [self.trigger isEqualToString:object.trigger];
    if (!equals) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash {
    return (self.identifier.hash ^
            self.title.hash ^
            self.message.hash ^
            self.buttonActionURLs.hash ^
            self.buttonTitles.hash ^
            self.defaultLangCode.hash ^
            self.translations.hash ^
            self.bundleIdentifier.hash ^
            self.countries.hash ^
            self.languages.hash ^
            self.maxAppVersion.hash ^
            self.maxOSVersion.hash ^
            self.minAppVersion.hash ^
            self.minOSVersion.hash ^
            self.startDate.hash ^
            self.endDate.hash ^
            self.trigger.hash);
}

#pragma mark - CLMCloudKitSerializable

- (instancetype)initWithRecord:(CKRecord *)record {
    self = [super init];
    if (self) {
        _identifier = [record.recordID.recordName copy];

        _title = [record[CLM_KEYPATH(self, title)] copy];
        _message = [record[CLM_KEYPATH(self, message)] copy];

        _buttonActionURLs = [record[CLM_KEYPATH(self, buttonActionURLs)] copy] ?: [NSArray array];
        _buttonTitles = [record[CLM_KEYPATH(self, buttonTitles)] copy] ?: [NSArray array];

        _defaultLangCode = [record[CLM_KEYPATH(self, defaultLangCode)] copy];
        _translations = [NSArray array]; // Translations are empty until fetched

        _bundleIdentifier = [record[CLM_KEYPATH(self, bundleIdentifier)] copy];
        _countries = [record[CLM_KEYPATH(self, countries)] copy] ?: [NSArray array];
        _languages = [record[CLM_KEYPATH(self, languages)] copy] ?: [NSArray array];
        _maxAppVersion = [record[CLM_KEYPATH(self, maxAppVersion)] copy];
        _maxOSVersion = [record[CLM_KEYPATH(self, maxOSVersion)] copy];
        _minAppVersion = [record[CLM_KEYPATH(self, minAppVersion)] copy];
        _minOSVersion = [record[CLM_KEYPATH(self, minOSVersion)] copy];

        _startDate = record[CLM_KEYPATH(self, startDate)];
        _endDate = record[CLM_KEYPATH(self, endDate)];
        _trigger = [record[CLM_KEYPATH(self, trigger)] copy];
    }

    return self;
}

- (CKRecordID *)recordID {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.identifier];
    return recordID;
}

- (CKRecord *)record {
    CKRecordID *recordID = [self recordID];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:CLMAlertCampaignRecordType recordID:recordID];

    record[CLM_KEYPATH(self, title)] = self.title;
    record[CLM_KEYPATH(self, message)] = self.message;

    record[CLM_KEYPATH(self, buttonActionURLs)] = self.buttonActionURLs;
    record[CLM_KEYPATH(self, buttonTitles)] = self.buttonTitles;

    record[CLM_KEYPATH(self, defaultLangCode)] = self.defaultLangCode;

    record[CLM_KEYPATH(self, bundleIdentifier)] = self.bundleIdentifier;
    record[CLM_KEYPATH(self, countries)] = self.countries;
    record[CLM_KEYPATH(self, languages)] = self.languages;
    record[CLM_KEYPATH(self, maxAppVersion)] = self.maxAppVersion;
    record[CLM_KEYPATH(self, maxOSVersion)] = self.maxOSVersion;
    record[CLM_KEYPATH(self, minAppVersion)] = self.minAppVersion;
    record[CLM_KEYPATH(self, minOSVersion)] = self.minOSVersion;

    record[CLM_KEYPATH(self, startDate)] = self.startDate;
    record[CLM_KEYPATH(self, endDate)] = self.endDate;
    record[CLM_KEYPATH(self, trigger)] = self.trigger;

    // `translations` should be fetched separately

    return record;
}

@end

NS_ASSUME_NONNULL_END
