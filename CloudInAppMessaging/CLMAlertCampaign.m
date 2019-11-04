//
//  CLMAlertCampaignObject.m
//  CloudInAppMessaging
//
//  Created by Andrew Podkovyrin on 10/31/19.
//

#import "CLMAlertCampaign.h"

#import "Private/CLMKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const CLMAlertCampaignButtonURLNoAction = @"__CLM_NO_ACTION_URL__";

CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnForeground = @"CLMAlertCampaignTriggerOnForeground";
CLMAlertCampaignTrigger const CLMAlertCampaignTriggerOnAppLaunch = @"CLMAlertCampaignTriggerOnAppLaunch";

static NSString * const kRecordType = @"AlertCampaign";

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

#pragma mark - CLMCloudKitSerializable

- (instancetype)initWithRecord:(CKRecord *)record {
    self = [super init];
    if (self) {
        _identifier = [record.recordID.recordName copy];
        
        _alertTitle = [record[CLM_KEYPATH(self, alertTitle)] copy];
        _alertMessage = [record[CLM_KEYPATH(self, alertMessage)] copy];
        
        _buttonActionURLs = [record[CLM_KEYPATH(self, buttonActionURLs)] copy] ?: [NSArray array];
        _buttonTitles = [record[CLM_KEYPATH(self, buttonTitles)] copy] ?: [NSArray array];
        
        _defaultLangCode = [record[CLM_KEYPATH(self, defaultLangCode)] copy];
            // TODO ref
        //    record[CLM_KEYPATH(self, translations)]  ?: [NSArray array];
                
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

- (CKRecord *)recordInZone:(CKRecordZone *)zone {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.identifier zoneID:zone.zoneID];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:kRecordType recordID:recordID];
    
    record[CLM_KEYPATH(self, alertTitle)] = self.alertTitle;
    record[CLM_KEYPATH(self, alertMessage)] = self.alertMessage;
    
    record[CLM_KEYPATH(self, buttonActionURLs)] = self.buttonActionURLs;
    record[CLM_KEYPATH(self, buttonTitles)] = self.buttonTitles;
    
    record[CLM_KEYPATH(self, defaultLangCode)] = self.defaultLangCode;
    
    // TODO ref
//    record[CLM_KEYPATH(self, translations)]
    
    record[CLM_KEYPATH(self, countries)] = self.countries;
    record[CLM_KEYPATH(self, languages)] = self.languages;
    record[CLM_KEYPATH(self, maxAppVersion)] = self.maxAppVersion;
    record[CLM_KEYPATH(self, maxOSVersion)] = self.maxOSVersion;
    record[CLM_KEYPATH(self, minAppVersion)] = self.minAppVersion;
    record[CLM_KEYPATH(self, minOSVersion)] = self.minOSVersion;
    
    record[CLM_KEYPATH(self, startDate)] = self.startDate;
    record[CLM_KEYPATH(self, endDate)] = self.endDate;
    record[CLM_KEYPATH(self, trigger)] = self.trigger;
        
    return record;
}

@end

NS_ASSUME_NONNULL_END
