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

NS_ASSUME_NONNULL_BEGIN

static NSString *const kCLMStateKeeperLastDisplayDateKey = @"clm.state.lastDisplayDate";
static NSString *const kCLMStateKeeperLastFetchDateKey = @"clm.state.lastFetchDate";
static NSString *const kCLMStateKeeperImpressionIDsKey = @"clm.state.impressionIDs";

@interface CLMStateKeeper ()

@property (readonly, nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation CLMStateKeeper

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    self = [super init];
    if (self) {
        _userDefaults = userDefaults;
    }
    return self;
}

- (nullable NSDate *)lastDisplayDate {
    return [self.userDefaults objectForKey:kCLMStateKeeperLastDisplayDateKey];
}

- (nullable NSDate *)lastFetchDate {
    return [self.userDefaults objectForKey:kCLMStateKeeperLastFetchDateKey];
}

- (NSArray<NSString *> *)impressionIDs {
    return [self.userDefaults arrayForKey:kCLMStateKeeperImpressionIDsKey] ?: @[];
}

- (void)recordAlertImpression:(CLMAlertCampaign *)alertCampaign {
    @synchronized(self) {
        self.lastDisplayDate = [NSDate date];

        NSMutableArray<NSString *> *impressionIDs = [self.impressionIDs mutableCopy];
        [impressionIDs addObject:alertCampaign.identifier];
        self.impressionIDs = impressionIDs;
    }
}

- (void)recordFetch {
    @synchronized(self) {
        self.lastFetchDate = [NSDate date];
    }
}

#pragma mark - Private

- (void)setLastDisplayDate:(NSDate *_Nullable)lastDisplayDate {
    [self.userDefaults setObject:lastDisplayDate forKey:kCLMStateKeeperLastDisplayDateKey];
}

- (void)setLastFetchDate:(NSDate *_Nullable)lastFetchDate {
    [self.userDefaults setObject:lastFetchDate forKey:kCLMStateKeeperLastFetchDateKey];
}

- (void)setImpressionIDs:(NSArray<NSString *> *)impressionIDs {
    [self.userDefaults setObject:impressionIDs forKey:kCLMStateKeeperImpressionIDsKey];
}

@end

NS_ASSUME_NONNULL_END
