//
//  Utils.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "Utils.h"

@implementation Utils

#pragma mark - Formats

+ (void)setViewTransparent:(NSView *)view withBackgroundColor:(NSColor *)color
{
    view.layer.backgroundColor = [[color colorWithAlphaComponent:COLOR_ALPHA] CGColor];
}

+ (void)setShadowForView:(NSView *)view
{
    NSShadow *dropShadow = [[NSShadow alloc] init];
    
    [dropShadow setShadowColor:[NSColor shadowColor]];
    
    [dropShadow setShadowOffset:NSMakeSize(-0.1, 0.1)];
    [dropShadow setShadowBlurRadius:1.0];
    
    [view setWantsLayer:YES];
    [view setShadow:dropShadow];
}

+ (void)setBackgroundColor:(NSColor *)color forView:(NSView *)view
{
    view.wantsLayer = YES;
    view.layer.backgroundColor = [color CGColor];
}

+ (void)setBackgroundColor:(NSColor *)color cornerRadius:(CGFloat)radius forView:(NSView *)view
{
    [self setBackgroundColor:color forView:view];
    view.layer.cornerRadius = radius;
}

+ (void)setBackgroundColor:(NSColor *)color cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(NSColor *)borderColor forView:(NSView *)view
{
    [self setBackgroundColor:color cornerRadius:radius forView:view];
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = [borderColor CGColor];
}

+ (void)setTitle:(NSString *)title attributes:(NSDictionary *)attributes forControl:(NSControl *)control
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    control.attributedStringValue = attributedString;
    
    if ([control isKindOfClass:[NSButton class]])
    {
        ((NSButton *)control).attributedTitle = attributedString;
    }
}

+ (void)setTitle:(NSString *)title color:(NSColor *)color fontSize:(CGFloat)fontSize forControl:(NSControl *)control
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize:fontSize weight:NSFontWeightRegular], NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    control.attributedStringValue = attributedString;
    
    if ([control isKindOfClass:[NSButton class]])
    {
        ((NSButton *)control).attributedTitle = attributedString;
    }
}

+ (void)setTitle:(NSString *)title color:(NSColor *)color forControl:(NSControl *)control
{
    [self setTitle:title color:color fontSize:14.0 forControl:control];
}

#pragma mark - String

+ (NSSize)sizeOfControl:(NSControl *)control
{
    return [self sizeOfControl:control withWidth:control.frame.size.width];
}

+ (NSSize)sizeOfControl:(NSControl *)control withWidth:(CGFloat)width
{
    return [control sizeThatFits:NSMakeSize(width, (CGFloat) SHRT_MAX)];
}

+ (CGFloat)heightForWidth:(CGFloat)width string:(NSAttributedString *)string
{
    return [self sizeForWidth:width height:FLT_MAX string:string].height;
}

+ (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height string:(NSAttributedString *)string
{
    NSInteger typesetterBehavior = NSTypesetterLatestBehavior;
    NSSize size = NSZeroSize;

    if ([string length] > 0)
    {
        // Checking for empty string is necessary since Layout Manager will give the nominal
        // height of one line if length is 0.  Our API specifies 0.0 for an empty string.
        NSSize dumpSize = NSMakeSize(width, height);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:dumpSize];
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:string];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        [layoutManager setHyphenationFactor:0.0];

        if (typesetterBehavior != NSTypesetterLatestBehavior)
        {
            [layoutManager setTypesetterBehavior:typesetterBehavior];
        }

        // NSLayoutManager is lazy, so we need the following kludge to force layout:
        [layoutManager glyphRangeForTextContainer:textContainer];

        size = [layoutManager usedRectForTextContainer:textContainer].size;

        // Adjust if there is extra height for the cursor
        NSSize extraLineSize = [layoutManager extraLineFragmentRect].size;

        if (extraLineSize.height > 0)
        {
            size.height -= extraLineSize.height;
        }

        // In case we changed it above, set typesetterBehavior back
        // to the default value.
        typesetterBehavior = NSTypesetterLatestBehavior;
    }

    return size;
}

#pragma mark - Device

+ (NSSize)screenSize
{
    return [[NSScreen mainScreen] frame].size;
}

@end
