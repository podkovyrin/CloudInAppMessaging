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

#import <Foundation/Foundation.h>

#import "../CLMAlertCampaign.h"

NS_ASSUME_NONNULL_BEGIN

@class CLMStateKeeper;

/// In-memory cache of the alerts that would be searched for finding next alert to be displayed.
/// In the case an alert has been displayed, it's removed from the cache so that it's not
/// considered next time for the alert search.
@interface CLMAlertsMemoryCache : NSObject

- (instancetype)initWithStateKeeper:(CLMStateKeeper *)stateKeeper;

/// Update cache datasource.
- (void)setAlertsData:(NSArray<CLMAlertCampaign *> *)alerts;

/// Get next eligible alert that is appropriate for display.
- (nullable CLMAlertCampaign *)nextAlertForTrigger:(CLMAlertCampaignTrigger)trigger;

/// Call this after an alert has been displayed to remove it from the cache.
- (void)removeAlert:(CLMAlertCampaign *)alert;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
