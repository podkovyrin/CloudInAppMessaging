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

#import "CLMAlertCampaign.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMAlertCampaign (CLMPresenting)

/// Returns object that can be used for displaying by the alert campaign presenter.
/// It will return either `CLMAlertCampaign` itself if a `defultLang` matches one of `preferredLanguages`
/// or one of the Alert Translations.
/// If nothing matches any of `preferredLanguages` `CLMAlertCampaign` is used.
- (id<CLMAlertDataSource>)clm_dataSourceForPreferredLanguages:(NSArray<NSString *> *)preferredLanguages
    NS_SWIFT_NAME(dataSource(forPreferredLanguages:));

@end

NS_ASSUME_NONNULL_END
