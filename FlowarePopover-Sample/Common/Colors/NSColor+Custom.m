//
//  NSColor+Custom.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 11/14/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NSColor+Custom.h"

@implementation NSColor (Custom)

#pragma mark - Initialize

- (instancetype)initWithHex:(NSString *)hex {
    if (self = [self init]) {
        unsigned colorCode = 0;
        unsigned char redByte, greenByte, blueByte;
        
        if (hex) {
            hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
            NSScanner *scanner = [NSScanner scannerWithString:hex];
            (void) [scanner scanHexInt:&colorCode]; // ignore error
        }
        
        redByte = (unsigned char) (colorCode >> 16);
        greenByte = (unsigned char) (colorCode >> 8);
        blueByte = (unsigned char) (colorCode); // masks off high bits
        
        self = [NSColor colorWithCalibratedRed:(CGFloat) redByte / 0xff
                                         green:(CGFloat) greenByte / 0xff
                                          blue:(CGFloat) blueByte / 0xff
                                         alpha:1.0];
    }
    
    return self;
}

#pragma mark - Normal additional colors

+ (NSColor *)backgroundColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#323232"] : [[NSColor alloc] initWithHex:@"#E1E1E1"];
}

+ (NSColor *)backgroundWhiteColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#201F24"] : [[NSColor alloc] initWithHex:@"#FDFDFD"];
}

+ (NSColor *)blueColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#007FD5"] : [[NSColor alloc] initWithHex:@"#008EFF"];
}

+ (NSColor *)dustColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#854548"] : [[NSColor alloc] initWithHex:@"#C24548"];
}

+ (NSColor *)grayColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#282828"] : [[NSColor alloc] initWithHex:@"#969696"];
}

+ (NSColor *)lavenderColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#4F00FE"] : [[NSColor alloc] initWithHex:@"#4F5FFE"];
}

+ (NSColor *)mossColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#0F7001"] : [[NSColor alloc] initWithHex:@"#0FA301"];
}

+ (NSColor *)orangeColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#C04500"] : [[NSColor alloc] initWithHex:@"#FE4500"];
}

+ (NSColor *)shadowColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#505050"] : [[NSColor alloc] initWithHex:@"#B7B7B7"];
}

+ (NSColor *)tealColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#68B089"] : [[NSColor alloc] initWithHex:@"#18B089"];
}

+ (NSColor *)textBlackColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#DFDFDF"] : [[NSColor alloc] initWithHex:@"#212121"];
}

+ (NSColor *)textGrayColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#A5A5A5"] : [[NSColor alloc] initWithHex:@"#747474"];
}

+ (NSColor *)textLightGrayColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#646368"] : [[NSColor alloc] initWithHex:@"#B3B3B3"];
}

+ (NSColor *)textWhiteColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#FAFEFF"] : [[NSColor alloc] initWithHex:@"#FAFEFF"];
}

+ (NSColor *)violetColor {
    return [Utils isDarkMode] ? [[NSColor alloc] initWithHex:@"#A90D91"] : [[NSColor alloc] initWithHex:@"#D70D91"];
}

#pragma mark - Asset additional colors

+ (NSColor *)_backgroundColor {
    return [NSColor colorNamed:@"_backgroundColor"];
}

+ (NSColor *)_backgroundWhiteColor {
    return [NSColor colorNamed:@"_backgroundWhiteColor"];
}

+ (NSColor *)_blueColor {
    return [NSColor colorNamed:@"_blueColor"];
}

+ (NSColor *)_dustColor {
    return [NSColor colorNamed:@"_dustColor"];
}

+ (NSColor *)_grayColor {
    return [NSColor colorNamed:@"_grayColor"];
}

+ (NSColor *)_lavenderColor {
    return [NSColor colorNamed:@"_lavenderColor"];
}

+ (NSColor *)_mossColor {
    return [NSColor colorNamed:@"_mossColor"];
}

+ (NSColor *)_orangeColor {
    return [NSColor colorNamed:@"_orangeColor"];
}

+ (NSColor *)_shadowColor {
    return [NSColor colorNamed:@"_shadowColor"];
}

+ (NSColor *)_tealColor {
    return [NSColor colorNamed:@"_tealColor"];
}

+ (NSColor *)_textBlackColor {
    return [NSColor colorNamed:@"_textBlackColor"];
}

+ (NSColor *)_textGrayColor {
    return [NSColor colorNamed:@"_textGrayColor"];
}

+ (NSColor *)_textLightGrayColor {
    return [NSColor colorNamed:@"_textLightGrayColor"];
}

+ (NSColor *)_textWhiteColor {
    return [NSColor colorNamed:@"_textWhiteColor"];
}

+ (NSColor *)_violetColor {
    return [NSColor colorNamed:@"_violetColor"];
}

@end
