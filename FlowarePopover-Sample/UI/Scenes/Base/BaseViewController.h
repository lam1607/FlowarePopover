//
//  BaseViewController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BaseViewController : NSViewController

#pragma mark -
#pragma mark - Formats
#pragma mark -
- (void)setBackgroundColor:(NSColor *)color forView:(NSView *)view;
- (void)setBackgroundColor:(NSColor *)color cornerRadius:(CGFloat)radius forView:(NSView *)view;
- (void)setTitle:(NSString *)title attributes:(NSDictionary *)attributes forControl:(NSControl *)control;

@end
