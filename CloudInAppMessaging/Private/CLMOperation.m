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

#import "CLMOperation.h"

@interface CLMOperation ()

@property (atomic, assign) BOOL hasFinishedAlready;
@property (atomic, assign) CLMOperationState state;
@property (getter=isCancelled) BOOL cancelled;

@property (nonatomic, copy) NSArray<NSError *> *internalErrors;

@end

@implementation CLMOperation

@synthesize cancelled = _cancelled;
@synthesize userInitiated = _userInitiated;
@synthesize state = _state;

// use the KVO mechanism to indicate that changes to "state" affect other properties as well
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([@[ @"isReady" ] containsObject:key]) {
        return [NSSet setWithArray:@[ @"state", @"cancelledState" ]];
    }
    if ([@[ @"isExecuting", @"isFinished" ] containsObject:key]) {
        return [NSSet setWithArray:@[ @"state" ]];
    }
    if ([@[ @"isCancelled" ] containsObject:key]) {
        return [NSSet setWithArray:@[ @"cancelledState" ]];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([@[ @"state", @"cancelledState" ] containsObject:key]) {
        return NO;
    }

    return YES;
}

- (CLMOperationState)state {
    @synchronized(self) {
        return _state;
    }
}

- (void)setState:(CLMOperationState)newState {
    // Manually fire the KVO notifications for state change, since this is "private".
    @synchronized(self) {
        if (_state != CLMOperationStateFinished) {
            [self willChangeValueForKey:@"state"];
            NSAssert(_state != newState, @"Performing invalid cyclic state transition.");
            _state = newState;
            [self didChangeValueForKey:@"state"];
        }
    }
}

- (BOOL)isCancelled {
    @synchronized(self) {
        return _cancelled;
    }
}

- (void)setCancelled:(BOOL)cancelled {
    @synchronized(self) {
        [self willChangeValueForKey:@"cancelledState"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"cancelledState"];
    }
}

- (BOOL)isReady {
    BOOL ready = NO;

    @synchronized(self) {
        switch (self.state) {
            case CLMOperationStateInitialized:
                ready = [super isReady] || [self isCancelled];
                break;
            default:
                ready = NO;
                break;
        }
    }

    return ready;
}

- (BOOL)userInitiated {
    if ([self respondsToSelector:@selector(qualityOfService)]) {
        return self.qualityOfService == NSQualityOfServiceUserInitiated;
    }

    return _userInitiated;
}

- (void)setUserInitiated:(BOOL)newValue {
    NSAssert(self.state < CLMOperationStateExecuting, @"Cannot modify userInitiated after execution has begun.");
    if ([self respondsToSelector:@selector(setQualityOfService:)]) {
        self.qualityOfService = newValue ? NSQualityOfServiceUserInitiated : NSQualityOfServiceDefault;
    }
    _userInitiated = newValue;
}

- (BOOL)isExecuting {
    return self.state == CLMOperationStateExecuting;
}

- (BOOL)isFinished {
    return self.state == CLMOperationStateFinished;
}

- (void)addDependency:(NSOperation *)op {
    NSAssert(self.state <= CLMOperationStateExecuting, @"Dependencies cannot be modified after execution has begun.");
    [super addDependency:op];
}

#pragma mark - Execution and Cancellation

- (void)start {
    NSAssert(self.state == CLMOperationStateInitialized, @"This operation must be performed on an operation queue.");

    if (self.isCancelled) {
        [self finishWithError:nil];
        return;
    }
    self.state = CLMOperationStateExecuting;

    [self execute];
}

- (void)execute {
    NSLog(@"%@ must override `execute`.", NSStringFromClass(self.class));
    [self finishWithError:nil];
}

- (void)cancel {
    if (self.isFinished) {
        return;
    }

    self.cancelled = YES;
    if (self.state > CLMOperationStateInitialized) {
        [self finishWithError:nil];
    }
}

- (void)cancelWithError:(NSError *)error {
    if (error) {
        self.internalErrors = [self.internalErrors arrayByAddingObject:error];
    }
    [self cancel];
}

- (void)cancelWithErrors:(NSArray<NSError *> *)errors {
    self.internalErrors = [self.internalErrors arrayByAddingObjectsFromArray:errors];
    [self cancel];
}

#pragma mark - Finishing

- (NSArray *)internalErrors {
    if (!_internalErrors) {
        _internalErrors = @[];
    }
    return _internalErrors;
}

- (void)finishWithErrors:(NSArray<NSError *> *)errors {
    if (!self.hasFinishedAlready) {
        self.hasFinishedAlready = YES;

        _internalErrors = [self.internalErrors arrayByAddingObjectsFromArray:errors];

        self.state = CLMOperationStateFinished;
    }
}

- (void)finishWithError:(NSError *)error {
    if (error) {
        [self finishWithErrors:@[ error ]];
    }
    else {
        [self finishWithErrors:nil];
    }
}

- (void)waitUntilFinished {
    /*
     Waiting on operations is almost NEVER the right thing to do. It is
     usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
     or `dispatch_group_notify`, or even `NSLock` objects. Many developers
     use waiting when they should instead be chaining discrete operations
     together using dependencies.
     
     To reinforce this idea, invoking `waitUntilFinished` will crash your
     app, as incentive for you to find a more appropriate way to express
     the behavior you're wishing to create.
     */
    NSAssert(NO, @"Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.");
}

@end
