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

#import "CLMCKService.h"

#import "../CLMAlertCampaign.h"
#import "../CLMAlertTranslation.h"
#import "CLMCKConfiguration.h"
#import "CLMCKFetchOperation.h"
#import "CLMClientInfo.h"
#import "CLMKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMCKService ()

@property (readonly, nonatomic, strong) CKContainer *container;
@property (readonly, nonatomic, strong) CKDatabase *database;
@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation CLMCKService

- (instancetype)initWithContainerIdentifier:(nullable NSString *)identifier {
    self = [super init];
    if (self) {
        if (identifier) {
            _container = [CKContainer containerWithIdentifier:identifier];
        }
        else {
            _container = [CKContainer defaultContainer];
        }

        _database = _container.publicCloudDatabase;

        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.name = @"clm.cloudKitService.queue";
        operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue = operationQueue;
    }
    return self;
}

- (void)fetchAlertCampaignsForClientInfo:(CLMClientInfo *)clientInfo
                              completion:(void (^)(NSArray<CLMAlertCampaign *> *alertCampaigns))completion {
    NSPredicate *predicate = [self alertCampaignsPredicateForClient:clientInfo];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:CLMAlertCampaignRecordType predicate:predicate];
    CLMCKFetchOperation *operation = [[CLMCKFetchOperation alloc] initWithConfiguration:[self configuration]
                                                                                  query:query];
    __block typeof(operation) blockOperation = operation;
    operation.completionBlock = ^{
        NSMutableArray<CLMAlertCampaign *> *alertCampaigns = [NSMutableArray array];
        for (CKRecord *record in blockOperation.records) {
            CLMAlertCampaign *alertCampaign = [[CLMAlertCampaign alloc] initWithRecord:record];
            [alertCampaigns addObject:alertCampaign];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([alertCampaigns copy]);
            }
        });

        blockOperation = nil;
    };
    [self.operationQueue addOperation:operation];
}

- (void)fetchTranslationsForAlertCampaign:(CLMAlertCampaign *)alertCampaign
                               completion:(void (^)(NSArray<CLMAlertTranslation *> *))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                                                              CLMAlertCampaignReferenceKey,
                                                              alertCampaign.recordID];

    CKQuery *query = [[CKQuery alloc] initWithRecordType:CLMAlertTranslationRecordType predicate:predicate];
    CLMCKFetchOperation *operation = [[CLMCKFetchOperation alloc] initWithConfiguration:[self configuration]
                                                                                  query:query];

    __block typeof(operation) blockOperation = operation;
    operation.completionBlock = ^{
        NSMutableArray<CLMAlertTranslation *> *alertTranslations = [NSMutableArray array];
        for (CKRecord *record in blockOperation.records) {
            CLMAlertTranslation *alertTranslation = [[CLMAlertTranslation alloc] initWithRecord:record];
            [alertTranslations addObject:alertTranslation];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([alertTranslations copy]);
            }
        });

        blockOperation = nil;
    };
    [self.operationQueue addOperation:operation];
}

#pragma mark - Private

- (CLMCKConfiguration *)configuration {
    CLMCKConfiguration *configuration = [[CLMCKConfiguration alloc] initWithContainer:self.container
                                                                             database:self.database];

    return configuration;
}

- (NSPredicate *)alertCampaignsPredicateForClient:(CLMClientInfo *)clientInfo {
    CLMAlertCampaign *alert = nil;

    NSMutableArray<NSPredicate *> *predicates = [NSMutableArray array];

    NSString *countryCode = clientInfo.countryCode;
    if (countryCode) {
        NSPredicate *countries = [NSPredicate predicateWithFormat:@"%@ IN %K",
                                                                  countryCode,
                                                                  CLM_KEYPATH(alert, countries)];
        [predicates addObject:countries];
    }

    NSPredicate *languages = [NSPredicate predicateWithFormat:@"ANY %@ IN %K",
                                                              clientInfo.preferredLanguages,
                                                              CLM_KEYPATH(alert, languages)];
    [predicates addObject:languages];

    NSCompoundPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    return resultPredicate;
}

@end

NS_ASSUME_NONNULL_END
