//
//  CLMKeyPath.h
//  Pods
//
//  Created by Andrew Podkovyrin on 11/1/19.
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
