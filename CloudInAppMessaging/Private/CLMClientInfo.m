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

@synthesize preferredLanguages = _preferredLanguages;
@synthesize appVersion = _appVersion;
@synthesize osVersion = _osVersion;

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray<NSString *> *preferredLocaleIds = [NSLocale preferredLanguages] ?: @[ @"en" ];
        NSMutableArray *mutablePreferredLanguages = [NSMutableArray array];
        for (NSString *localeId in preferredLocaleIds) {
            NSArray<NSString *> *components = [localeId componentsSeparatedByString:@"-"];
            NSString *languageCode = components.firstObject;
            if (languageCode.length > 0) {
                [mutablePreferredLanguages addObject:languageCode];
            }
        }
        _preferredLanguages = [mutablePreferredLanguages copy];

        _appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

        const NSOperatingSystemVersion systemVersion = [NSProcessInfo processInfo].operatingSystemVersion;
        _osVersion = [NSString stringWithFormat:@"%ld.%ld.%ld",
                                                (long)systemVersion.majorVersion,
                                                (long)systemVersion.minorVersion,
                                                (long)systemVersion.patchVersion];
    }
    return self;
}

- (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (nullable NSString *)countryCode {
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];

    return countryCode;
}

@end

NS_ASSUME_NONNULL_END
