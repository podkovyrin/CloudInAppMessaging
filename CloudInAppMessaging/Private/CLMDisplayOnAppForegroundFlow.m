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

#import "CLMDisplayOnAppForegroundFlow.h"

#import "CLMDisplayExecutor.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CLMDisplayOnAppForegroundFlow

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
    // Show the alert with 0.5 second delay so that the app's UI is more stable.
    // When alerts are displayed, the UI operation will be dispatched back to main UI thread.
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 500 * (int64_t)NSEC_PER_MSEC);
    dispatch_after(when, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.displayExecutor checkAndDisplayNextAppForegroundAlert];
    });
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

NS_ASSUME_NONNULL_END
