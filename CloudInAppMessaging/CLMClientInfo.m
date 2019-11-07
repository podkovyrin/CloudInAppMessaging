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

#import "CLMClientInfo.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CLMClientInfo

- (NSArray<NSString *> *)preferredLanguages {
    return [NSLocale preferredLanguages];
}

- (NSString *)countryCode {
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSParameterAssert(countryCode);
    return countryCode;
}

- (NSString *)appVersion {
    static NSString *appVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSParameterAssert(appVersion);
    });
    return appVersion;
}

- (NSString *)osVersion {
    static NSString *OSVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperatingSystemVersion systemVersion = [NSProcessInfo processInfo].operatingSystemVersion;
        OSVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)systemVersion.majorVersion,
                                               (long)systemVersion.minorVersion,
                                               (long)systemVersion.patchVersion];
    });
    return OSVersion;
}

@end

NS_ASSUME_NONNULL_END
