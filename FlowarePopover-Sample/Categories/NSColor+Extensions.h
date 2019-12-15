//
//  NSColor+Extensions.h
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Extensions)

#pragma mark - Initialize

- (instancetype)initWithHex:(NSString *)hex;

#pragma mark - Extensions methods

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

@end
