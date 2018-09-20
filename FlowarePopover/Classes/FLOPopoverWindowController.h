//
//  FLOPopoverWindowController.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark -
#pragma mark - FLOPopoverWindow
#pragma mark -
// FLOPopoverWindow subclased of NSWindow (can see AnimatedWindow in FloProj)
@interface FLOPopoverWindow : NSWindow

@property (nonatomic, strong, readonly) NSWindow *appMainWindow;

@property (nonatomic, strong, readonly) NSWindow *topWindow;
@property (nonatomic, strong, readonly) NSView *topView;

@property (nonatomic, strong, readonly) NSWindow *animatedWindow;

+ (FLOPopoverWindow *)sharedInstance;

- (void)setTopmostWindow:(NSWindow *)topmostWindow;
- (void)setTopmostView:(NSView *)topmostView;

@end

#pragma mark -
#pragma mark - FLOPopoverWindowController
#pragma mark -
@interface FLOPopoverWindowController : NSWindowController

@end
