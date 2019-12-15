//
//  Utils.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

@interface Utils : NSObject

#pragma mark - Formats

+ (void)setViewTransparent:(NSView *)view withBackgroundColor:(NSColor *)color;
+ (void)setShadowForView:(NSView *)view;
+ (void)setBackgroundColor:(NSColor *)color forView:(NSView *)view;
+ (void)setBackgroundColor:(NSColor *)color cornerRadius:(CGFloat)radius forView:(NSView *)view;
+ (void)setBackgroundColor:(NSColor *)color cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(NSColor *)borderColor forView:(NSView *)view;
+ (void)setTitle:(NSString *)title attributes:(NSDictionary *)attributes forControl:(NSControl *)control;
+ (void)setTitle:(NSString *)title color:(NSColor *)color fontSize:(CGFloat)fontSize forControl:(NSControl *)control;
+ (void)setTitle:(NSString *)title color:(NSColor *)color forControl:(NSControl *)control;

#pragma mark - String

+ (NSSize)sizeOfControl:(NSControl *)control;
+ (NSSize)sizeOfControl:(NSControl *)control withWidth:(CGFloat)width;
+ (CGFloat)heightForWidth:(CGFloat)width string:(NSAttributedString *)string;
+ (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height string:(NSAttributedString *)string;

#pragma mark - Device

+ (NSSize)screenSize;

@end
