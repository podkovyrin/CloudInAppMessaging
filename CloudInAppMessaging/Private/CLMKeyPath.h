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

#ifndef CLMKeyPath_h
#define CLMKeyPath_h

// Compile-time check for keypaths
// More info: https://pspdfkit.com/blog/2017/even-swiftier-objective-c/
#if DEBUG
#define CLM_KEYPATH(object, property) ((void)(NO && ((void)object.property, NO)), @ #property)
#else
#define CLM_KEYPATH(object, property) @ #property
#endif

#endif /* CLMKeyPath_h */
