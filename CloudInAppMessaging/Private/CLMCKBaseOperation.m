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

#import "CLMCKBaseOperation.h"

NS_ASSUME_NONNULL_BEGIN

static NSInteger const kMaxRetryCount = 1;

@interface CLMCKBaseOperation ()

@property (nonatomic, assign) NSInteger retryCount;

@end

@implementation CLMCKBaseOperation

- (instancetype)initWithConfiguration:(CLMCKConfiguration *)configuration {
    self = [super init];
    if (self) {
        _container = configuration.container;
        _database = configuration.database;
    }
    return self;
}

- (BOOL)retryExecutionIfPossibleWithError:(NSError *)error {
    if (!error || ![error.domain isEqualToString:CKErrorDomain]) {
        return NO;
    }

    if (self.retryCount >= kMaxRetryCount) {
        return NO;
    }

    NSNumber *retryAfter = error.userInfo[CKErrorRetryAfterKey];
    if (retryAfter) {
        NSTimeInterval retryAfterSeconds = retryAfter.doubleValue;
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryAfterSeconds * NSEC_PER_SEC));
        dispatch_after(when, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self execute];
        });


        self.retryCount += 1;

        return YES;
    }

    if (@available(iOS 11.0, *)) {
        if (error.code == CKErrorServerResponseLost) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self execute];
            });

            self.retryCount += 1;

            return YES;
        }
    }

    return NO;
}

@end

NS_ASSUME_NONNULL_END
