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

#import "WoopraSDK.h"

FOUNDATION_EXPORT double Woopra_iOSVersionNumber;
FOUNDATION_EXPORT const unsigned char Woopra_iOSVersionString[];

