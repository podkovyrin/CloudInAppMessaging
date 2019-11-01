#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CLMAlertCampaign.h"
#import "CLMAlertTranslation.h"
#import "CLMCloudKitSerializable.h"
#import "CloudInAppMessaging.h"

FOUNDATION_EXPORT double CloudInAppMessagingVersionNumber;
FOUNDATION_EXPORT const unsigned char CloudInAppMessagingVersionString[];

