//
//  FLOExtensionsNSColor.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOExtensionsNSColor.h"

@implementation NSColor (FLOExtensionsNSColor)

#pragma mark -
#pragma mark - Initialize
#pragma mark -
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
                                         alpha:1.0f];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Additional colors
#pragma mark -
+ (NSColor *)colorBlue {
    return [[NSColor alloc] initWithHex:@"#1274FF"];
}

+ (NSColor *)colorLavender {
    return [[NSColor alloc] initWithHex:@"#4F00FE"];
}

+ (NSColor *)colorViolet {
    return [[NSColor alloc] initWithHex:@"#A90D91"];
}

+ (NSColor *)colorTeal {
    return [[NSColor alloc] initWithHex:@"#18B089"];
}

+ (NSColor *)colorOrange {
    return [[NSColor alloc] initWithHex:@"#FE4500"];
}

+ (NSColor *)colorMoss {
    return [[NSColor alloc] initWithHex:@"#0F7001"];
}

+ (NSColor *)colorDust {
    return [[NSColor alloc] initWithHex:@"#C24548"];
}

+ (NSColor *)colorGray {
    return [[NSColor alloc] initWithHex:@"#7D7D7D"];
}

+ (NSColor *)colorUltraLightGray {
    return [[NSColor alloc] initWithHex:@"#F0F0F0"];
}

+ (NSColor *)colorBackground {
    return [[NSColor alloc] initWithHex:@"#EBF5FE"];
}

@end
