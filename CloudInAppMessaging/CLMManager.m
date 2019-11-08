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

#import "CLMManager.h"

#import "Private/CLMCKService.h"
#import "Private/CLMClientInfo.h"
#import "Private/CLMPresentingWindowHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMManager ()

@property (readonly, nonatomic, strong) CLMClientInfo *clientInfo;
@property (readonly, nonatomic, strong) CLMCKService *cloudKitService;

@end

@implementation CLMManager

- (instancetype)initWithCloudKitContainerIdentifier:(nullable NSString *)containerIdentifier {
    NSAssert([NSThread isMainThread], @"Should be initialized on the Main Thread");

    self = [super init];
    if (self) {
        _clientInfo = [[CLMClientInfo alloc] init];
        _cloudKitService = [[CLMCKService alloc] initWithContainerIdentifier:containerIdentifier];

        [_cloudKitService fetchAlertCampaignsForClientInfo:_clientInfo
                                                completion:^(NSArray<CKRecord *> *_Nonnull alertCampaigns) {
                                                    NSLog(@"%@", alertCampaigns);
                                                }];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
