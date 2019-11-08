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

#import "CLMCKFetchOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMCKFetchOperation ()

@property (readonly, nonatomic, strong) CKQuery *query;
@property (nullable, nonatomic, weak) CKOperation *operation;

@property (nonatomic, strong) NSMutableArray<CKRecord *> *mutableRecords;

@end

@implementation CLMCKFetchOperation

- (instancetype)initWithConfiguration:(CLMCKConfiguration *)configuration query:(CKQuery *)query {
    self = [super initWithConfiguration:configuration];
    if (self) {
        _query = query;
    }
    return self;
}

- (NSArray<CKRecord *> *)records {
    return [self.mutableRecords copy];
}

- (void)execute {
    self.mutableRecords = [NSMutableArray array];
    [self fetchWithQuery:self.query];
}

- (void)cancel {
    [self.operation cancel];
    [super cancel];
}

#pragma mark - Private

- (void)fetchWithQuery:(CKQuery *)query {
    CKQueryOperation *operation = [[CKQueryOperation alloc] initWithQuery:query];
    [self performFetchOperation:operation];
}

- (void)fetchWithCursor:(CKQueryCursor *)cursor {
    CKQueryOperation *operation = [[CKQueryOperation alloc] initWithCursor:cursor];
    [self performFetchOperation:operation];
}

- (void)performFetchOperation:(CKQueryOperation *)operation {
    __weak typeof(self) weakSelf = self;

    operation.recordFetchedBlock = ^(CKRecord *record) {
        [weakSelf.mutableRecords addObject:record];
    };

    operation.queryCompletionBlock = ^(CKQueryCursor *_Nullable cursor, NSError *_Nullable operationError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        if (strongSelf.isCancelled) {
            return;
        }

        if (cursor) {
            [strongSelf fetchWithCursor:cursor];

            return;
        }

        if (operationError) {
            const BOOL retrying = [self retryExecutionIfPossibleWithError:operationError];
            if (!retrying) {
                [strongSelf finishWithError:operationError];
            }
            // else: `execute` will be called again
        }
        else {
            [strongSelf finishWithError:nil];
        }
    };

    [self.database addOperation:operation];
    self.operation = operation;
}

@end

NS_ASSUME_NONNULL_END
