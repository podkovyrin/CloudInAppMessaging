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

#import <CloudKit/CloudKit.h>

#import "CLMCKConfiguration.h"
#import "CLMOperation.h"

NS_ASSUME_NONNULL_BEGIN

/// Base class for CloudKit-based operations.
@interface CLMCKBaseOperation : CLMOperation

@property (readonly, nonatomic, strong) CKContainer *container;
@property (readonly, nonatomic, strong) CKDatabase *database;

- (instancetype)initWithConfiguration:(CLMCKConfiguration *)configuration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// Checks if it's possible to retry operation with the given error.
/// Returns `YES` and enqueues `execute` method if check succeeded.
/// Max number of retries is 3.
- (BOOL)retryExecutionIfPossibleWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
