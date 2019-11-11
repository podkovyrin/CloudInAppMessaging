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

#import "CLMFetchOnAppForegroundFlow.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CLMFetchOnAppForegroundFlow

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForegroundNotification:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    // for fetch operation, dispatch it to non main UI thread to avoid blocking. It's ok to dispatch
    // to a concurrent global queue instead of serial queue since app open event won't happen at
    // fast speed to cause race conditions
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkAndFetchForInitialAppLaunch:NO];
    });
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

NS_ASSUME_NONNULL_END
