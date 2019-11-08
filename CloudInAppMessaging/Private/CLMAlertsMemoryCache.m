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

#import "CLMAlertsMemoryCache.h"

#import "CLMStateKeeper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMAlertsMemoryCache ()

@property (readonly, nonatomic, strong) CLMStateKeeper *stateKeeper;
@property (nullable, nonatomic, strong) NSMutableArray<CLMAlertCampaign *> *alerts;

@end

@implementation CLMAlertsMemoryCache

- (instancetype)initWithStateKeeper:(CLMStateKeeper *)stateKeeper {
    self = [super init];
    if (self) {
        _stateKeeper = stateKeeper;
    }
    return self;
}

- (void)setAlertsData:(NSArray<CLMAlertCampaign *> *)alerts {
    @synchronized(self) {
        NSSet<NSString *> *impressionSet = [NSSet setWithArray:self.stateKeeper.impressionIDs];

        // while resetting the whole alerts set, we do prefiltering based on the impressions
        // data to get rid of alerts we don't care so that the future searches are more efficient
        NSPredicate *notImpressedPredicate =
            [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                CLMAlertCampaign *alert = (CLMAlertCampaign *)evaluatedObject;
                return ![impressionSet containsObject:alert.identifier];
            }];

        self.alerts = [[alerts filteredArrayUsingPredicate:notImpressedPredicate] mutableCopy];
    }
}

- (nullable CLMAlertCampaign *)nextAlertForTrigger:(CLMAlertCampaignTrigger)trigger {
    // search from the start to end in the list (which implies the display priority) for the
    // first match (some alerts in the cache may not be eligible for the current display alert fetch
    NSSet<NSString *> *impressionSet = [NSSet setWithArray:self.stateKeeper.impressionIDs];

    @synchronized(self) {
        for (CLMAlertCampaign *next in self.alerts) {
            // message being active and message not impressed yet
            if ([next alertHasStarted] && ![next alertHasExpired] &&
                ![impressionSet containsObject:next.identifier] &&
                [next alertDisplayedOnTrigger:trigger]) {
                return next;
            }
        }
    }

    return nil;
}

@end

NS_ASSUME_NONNULL_END
