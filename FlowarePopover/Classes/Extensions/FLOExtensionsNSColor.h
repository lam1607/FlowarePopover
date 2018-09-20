//
//  FLOExtensionsNSColor.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (FLOExtensionsNSColor)

- (instancetype)initWithHex:(NSString *)hex;

+ (NSColor *)colorBlue;
+ (NSColor *)colorLavender;
+ (NSColor *)colorViolet;
+ (NSColor *)colorTeal;
+ (NSColor *)colorOrange;
+ (NSColor *)colorMoss;
+ (NSColor *)colorDust;
+ (NSColor *)colorGray;
+ (NSColor *)colorUltraLightGray;
+ (NSColor *)colorBackground;

@end
