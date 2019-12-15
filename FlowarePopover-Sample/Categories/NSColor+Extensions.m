//
//  NSColor+Extensions.m
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "NSColor+Extensions.h"

@implementation NSColor (Extensions)

#pragma mark - Initialize

- (instancetype)initWithHex:(NSString *)hex
{
    if (![hex isKindOfClass:[NSString class]]) return nil;
    
    if (self = [self init])
    {
        unsigned colorCode = 0;
        unsigned char redByte, greenByte, blueByte;
        
        hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
        NSScanner *scanner = [NSScanner scannerWithString:hex];
        (void)[scanner scanHexInt:&colorCode]; // ignore error
        
        redByte = (unsigned char) (colorCode >> 16);
        greenByte = (unsigned char) (colorCode >> 8);
        blueByte = (unsigned char) (colorCode); // masks off high bits
        
        self = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff
                                         green:(CGFloat)greenByte / 0xff
                                          blue:(CGFloat)blueByte / 0xff
                                         alpha:1.0];
    }
    
    return self;
}

#pragma mark - Extensions methods

+ (NSColor *)backgroundColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#323232"] : [[NSColor alloc] initWithHex:@"#E1E1E1"];
}

+ (NSColor *)backgroundWhiteColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#201F24"] : [[NSColor alloc] initWithHex:@"#FDFDFD"];
}

+ (NSColor *)blueColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#007FD5"] : [[NSColor alloc] initWithHex:@"#008EFF"];
}

+ (NSColor *)dustColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#854548"] : [[NSColor alloc] initWithHex:@"#C24548"];
}

+ (NSColor *)grayColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#282828"] : [[NSColor alloc] initWithHex:@"#969696"];
}

+ (NSColor *)lavenderColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#4F00FE"] : [[NSColor alloc] initWithHex:@"#4F5FFE"];
}

+ (NSColor *)mossColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#0F7001"] : [[NSColor alloc] initWithHex:@"#0FA301"];
}

+ (NSColor *)orangeColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#C04500"] : [[NSColor alloc] initWithHex:@"#FE4500"];
}

+ (NSColor *)shadowColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#505050"] : [[NSColor alloc] initWithHex:@"#B7B7B7"];
}

+ (NSColor *)tealColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#68B089"] : [[NSColor alloc] initWithHex:@"#18B089"];
}

+ (NSColor *)textBlackColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#DFDFDF"] : [[NSColor alloc] initWithHex:@"#212121"];
}

+ (NSColor *)textGrayColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#A5A5A5"] : [[NSColor alloc] initWithHex:@"#747474"];
}

+ (NSColor *)textLightGrayColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#646368"] : [[NSColor alloc] initWithHex:@"#B3B3B3"];
}

+ (NSColor *)textWhiteColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#FAFEFF"] : [[NSColor alloc] initWithHex:@"#FAFEFF"];
}

+ (NSColor *)violetColor
{
    return [NSAppearance isDarkAppearance] ? [[NSColor alloc] initWithHex:@"#A90D91"] : [[NSColor alloc] initWithHex:@"#D70D91"];
}

@end
