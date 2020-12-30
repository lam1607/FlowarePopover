//
//  NSAppearance+Extensions.m
//  SharedSources
//
//  Created by Lam Nguyen on 12/11/19.
//  Copyright © 2019 Floware. All rights reserved.
//

#import "NSAppearance+Extensions.h"

@implementation NSAppearance (Extensions)

static id<NSAppearanceExtensionsProtocols> _protocolOwner = nil;

#pragma mark - Getter/Setter

+ (id<NSAppearanceExtensionsProtocols>)protocolOwner
{
    return _protocolOwner;
}

+ (void)setProtocolOwner:(id<NSAppearanceExtensionsProtocols>)protocolOwner
{
    _protocolOwner = protocolOwner;
}

#pragma mark - Local methods

+ (BOOL)isDarkModeSupported
{
#ifdef __MAC_10_14
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_14
    if (@available(macOS 10.14, *))
    {
        return YES;
    }
#endif
#endif
    
    return NO;
}

// https://developer.apple.com/documentation/appkit/nsappkitversion
+ (BOOL)isDarkMode
{
#ifdef __MAC_10_14
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_14
    if (@available(macOS 10.14, *))
    {
        NSAppearance *effectiveAppearance = [NSApplication sharedApplication].effectiveAppearance;
        NSAppearanceName appearance = [effectiveAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
        
        return [appearance isEqualToString:NSAppearanceNameDarkAqua];
    }
#endif
#endif
    
    return NO;
}

#pragma mark - Extensions

+ (BOOL)isDarkAppearance
{
    BOOL shouldUseSystemAppearance = NO;
    
    if ((NSAppearance.protocolOwner != nil) && [NSAppearance.protocolOwner respondsToSelector:@selector(shouldUseSystemAppearance)])
    {
        shouldUseSystemAppearance = [NSAppearance.protocolOwner shouldUseSystemAppearance];
    }
    
    if (shouldUseSystemAppearance)
    {
        return ([NSAppearance isDarkModeSupported] && [NSAppearance isDarkMode]);
    }
    else if ((NSAppearance.protocolOwner != nil) && [NSAppearance.protocolOwner respondsToSelector:@selector(isDarkAppearance)])
    {
        return [NSAppearance.protocolOwner isDarkAppearance];
    }
    
    return NO;
}

@end
