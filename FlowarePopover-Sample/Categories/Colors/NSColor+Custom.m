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
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_backgroundColor"];
    } else {
        return [NSColor backgroundColor];
    }
}

+ (NSColor *)_backgroundWhiteColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_backgroundWhiteColor"];
    } else {
        return [NSColor backgroundWhiteColor];
    }
}

+ (NSColor *)_blueColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_blueColor"];
    } else {
        return [NSColor blueColor];
    }
}

+ (NSColor *)_dustColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_dustColor"];
    } else {
        return [NSColor dustColor];
    }
}

+ (NSColor *)_grayColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_grayColor"];
    } else {
        return [NSColor grayColor];
    }
}

+ (NSColor *)_lavenderColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_lavenderColor"];
    } else {
        return [NSColor lavenderColor];
    }
}

+ (NSColor *)_mossColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_mossColor"];
    } else {
        return [NSColor mossColor];
    }
}

+ (NSColor *)_orangeColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_orangeColor"];
    } else {
        return [NSColor orangeColor];
    }
}

+ (NSColor *)_shadowColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_shadowColor"];
    } else {
        return [NSColor shadowColor];
    }
}

+ (NSColor *)_tealColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_tealColor"];
    } else {
        return [NSColor tealColor];
    }
}

+ (NSColor *)_textBlackColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_textBlackColor"];
    } else {
        return [NSColor textBlackColor];
    }
}

+ (NSColor *)_textGrayColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_textGrayColor"];
    } else {
        return [NSColor textGrayColor];
    }
}

+ (NSColor *)_textLightGrayColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_textLightGrayColor"];
    } else {
        return [NSColor textLightGrayColor];
    }
}

+ (NSColor *)_textWhiteColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_textWhiteColor"];
    } else {
        return [NSColor textWhiteColor];
    }
}

+ (NSColor *)_violetColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"_violetColor"];
    } else {
        return [NSColor violetColor];
    }
}

@end
