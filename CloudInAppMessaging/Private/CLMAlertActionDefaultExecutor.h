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

#import "../CLMAlertActionExecutor.h"

NS_ASSUME_NONNULL_BEGIN

/// A class for handling Alert Campaign actions.
/// It tries to handle these cases:
/// 1. Follow a universal link.
/// 2. Follow a custom url scheme link.
/// 3. Follow other types of links.
@interface CLMAlertActionDefaultExecutor : NSObject <CLMAlertActionExecutor>

@end

NS_ASSUME_NONNULL_END
