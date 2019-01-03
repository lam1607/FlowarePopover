//
//  NSColor+Custom.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 11/14/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor (Custom)

- (instancetype)initWithHex:(NSString *)hex;

#pragma mark - Normal additional colors

+ (NSColor *)backgroundColor;
+ (NSColor *)backgroundWhiteColor;
+ (NSColor *)blueColor;
+ (NSColor *)dustColor;
+ (NSColor *)grayColor;
+ (NSColor *)lavenderColor;
+ (NSColor *)mossColor;
+ (NSColor *)orangeColor;
+ (NSColor *)shadowColor;
+ (NSColor *)tealColor;
+ (NSColor *)textBlackColor;
+ (NSColor *)textGrayColor;
+ (NSColor *)textLightGrayColor;
+ (NSColor *)textWhiteColor;
+ (NSColor *)violetColor;

#pragma mark - Asset additional colors

+ (NSColor *)_backgroundColor;
+ (NSColor *)_backgroundWhiteColor;
+ (NSColor *)_blueColor;
+ (NSColor *)_dustColor;
+ (NSColor *)_grayColor;
+ (NSColor *)_lavenderColor;
+ (NSColor *)_mossColor;
+ (NSColor *)_orangeColor;
+ (NSColor *)_shadowColor;
+ (NSColor *)_tealColor;
+ (NSColor *)_textBlackColor;
+ (NSColor *)_textGrayColor;
+ (NSColor *)_textLightGrayColor;
+ (NSColor *)_textWhiteColor;
+ (NSColor *)_violetColor;

@end

NS_ASSUME_NONNULL_END
