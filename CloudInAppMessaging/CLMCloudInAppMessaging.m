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

#import "CLMCloudInAppMessaging.h"

#import "Private/CLMManager.h"
#import "Private/CLMSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMCloudInAppMessaging ()

@property (readonly, nonatomic, strong) CLMManager *manager;

@end

@implementation CLMCloudInAppMessaging

static CLMCloudInAppMessaging *_sharedInstance = nil;

+ (instancetype)setupWithCloudKitContainerIdentifier:(nullable NSString *)containerIdentifier {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] initWithCloudKitContainerIdentifier:containerIdentifier];
    });

    return _sharedInstance;
}

+ (instancetype)sharedInstance {
    NSAssert(_sharedInstance,
             @"CLMCloudInAppMessaging should be configured with `setupWithCloudKitContainerIdentifier:` before usage");
    return _sharedInstance;
}

- (instancetype)initWithCloudKitContainerIdentifier:(nullable NSString *)containerIdentifier {
    self = [super init];
    if (self) {
        CLMSettings *settings = [[CLMSettings alloc] init];
        settings.fetchMinInterval = 12 * 60 * 60;                  // fetch at most once every 12 hours
        settings.displayForegroundAlertMinInterval = 24 * 60 * 60; // display at most one message from
                                                                   // app-foreground trigger every 24 hours

        _manager = [[CLMManager alloc] initWithCloudKitContainerIdentifier:containerIdentifier
                                                                  settings:settings];

        _enabled = YES;
    }
    return self;
}

- (void)setMessageDisplaySuppressed:(BOOL)messageDisplaySuppressed {
    _messageDisplaySuppressed = messageDisplaySuppressed;
    [self.manager setMessageDisplaySuppressed:messageDisplaySuppressed];
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled) {
        [self.manager resume];
    }
    else {
        [self.manager pause];
    }
}

- (nullable id<CLMAlertPresenter>)alertPresenter {
    return self.manager.alertPresenter;
}

- (void)setAlertPresenter:(nullable id<CLMAlertPresenter>)alertPresenter {
    self.manager.alertPresenter = alertPresenter;
}

@end

NS_ASSUME_NONNULL_END
