//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CLMOperationState) {
    /// The initial state of an `CLMOperation`.
    CLMOperationStateInitialized,

    /// The `CLMOperation` is executing.
    CLMOperationStateExecuting,

    /// The `CLMOperation` has finished executing.
    CLMOperationStateFinished,
};

/// Base operation class to perform async code on NSOperationQueue
/// Simplified version of Advanced Operations (https://developer.apple.com/videos/wwdc/2015/?id=226)
@interface CLMOperation : NSOperation

@property (readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) BOOL userInitiated;
@property (atomic, readonly) CLMOperationState state;

@property (nonatomic, copy, readonly) NSArray<NSError *> *internalErrors;

/**
`execute` is the entry point of execution for all `CLMOperation` subclasses.
If you subclass `CLMOperation` and wish to customize its execution, you would
do so by overriding the `execute` method.

At some point, your `CLMOperation` subclass must call one of the "finish"
methods defined below; this is how you indicate that your operation has
finished its execution, and that operations dependent on yours can re-evaluate
their readiness state.
*/
- (void)execute;

- (void)cancel NS_REQUIRES_SUPER;
- (void)cancelWithError:(nullable NSError *)error NS_REQUIRES_SUPER;
- (void)cancelWithErrors:(nullable NSArray<NSError *> *)errors NS_REQUIRES_SUPER;

- (void)finishWithError:(nullable NSError *)error NS_REQUIRES_SUPER;
- (void)finishWithErrors:(nullable NSArray<NSError *> *)errors NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
