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

#import "CLMStateKeeper.h"

#import "../CLMAlertCampaign.h"
#import "CLMTimeFetcher.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kCLMStateKeeperLastDisplayTimeIntervalKey = @"clm.state.lastDisplayTimeInterval";
static NSString *const kCLMStateKeeperLastFetchTimeIntervalKey = @"clm.state.lastFetchTimeInterval";
static NSString *const kCLMStateKeeperImpressionIDsKey = @"clm.state.impressionIDs";

@interface CLMStateKeeper ()

@property (readonly, nonatomic, strong) NSUserDefaults *userDefaults;
@property (readonly, nonatomic, strong) id<CLMTimeFetcher> timeFetcher;

@property (nonatomic, assign) NSTimeInterval lastDisplayTimeInterval;
@property (nonatomic, assign) NSTimeInterval lastFetchTimeInterval;

@end

@implementation CLMStateKeeper

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                         timeFetcher:(id<CLMTimeFetcher>)timeFetcher {
    self = [super init];
    if (self) {
        _userDefaults = userDefaults;
        _timeFetcher = timeFetcher;
    }
    return self;
}

#pragma mark - CLMStateKeeper

- (NSTimeInterval)lastDisplayTimeInterval {
    return [self.userDefaults doubleForKey:kCLMStateKeeperLastDisplayTimeIntervalKey];
}

- (NSTimeInterval)lastFetchTimeInterval {
    return [self.userDefaults doubleForKey:kCLMStateKeeperLastFetchTimeIntervalKey];
}

- (NSArray<NSString *> *)impressionIDs {
    return [self.userDefaults arrayForKey:kCLMStateKeeperImpressionIDsKey] ?: @[];
}

- (void)recordAlertImpression:(CLMAlertCampaign *)alertCampaign {
    @synchronized(self) {
        self.lastDisplayTimeInterval = [self.timeFetcher currentTimestamp];

        NSMutableArray<NSString *> *impressionIDs = [self.impressionIDs mutableCopy];
        [impressionIDs addObject:alertCampaign.identifier];
        self.impressionIDs = impressionIDs;
    }
}

- (void)recordFetch {
    @synchronized(self) {
        self.lastFetchTimeInterval = [self.timeFetcher currentTimestamp];
    }
}

#pragma mark - Private

- (void)setLastDisplayTimeInterval:(NSTimeInterval)lastDisplayTimeInterval {
    [self.userDefaults setDouble:lastDisplayTimeInterval forKey:kCLMStateKeeperLastDisplayTimeIntervalKey];
}

- (void)setLastFetchTimeInterval:(NSTimeInterval)lastFetchTimeInterval {
    [self.userDefaults setDouble:lastFetchTimeInterval forKey:kCLMStateKeeperLastFetchTimeIntervalKey];
}

- (void)setImpressionIDs:(NSArray<NSString *> *)impressionIDs {
    [self.userDefaults setObject:impressionIDs forKey:kCLMStateKeeperImpressionIDsKey];
}

@end

NS_ASSUME_NONNULL_END
