//
//  FLOPopoverUtils.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLOPopoverConstants.h"

@interface FLOPopoverUtils : NSObject

@property (nonatomic, strong, readonly) NSWindow *appMainWindow;

@property (nonatomic, strong, readonly) NSWindow *topWindow;
@property (nonatomic, strong, readonly) NSView *topView;

@property (nonatomic, assign, readonly) BOOL appMainWindowResized;

+ (FLOPopoverUtils *)sharedInstance;

- (void)setTopmostWindow:(NSWindow *)topmostWindow;
- (void)setTopmostView:(NSView *)topmostView;
- (void)setAppMainWindowResized:(BOOL)appMainWindowResized;

#pragma mark - Utilities

- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationTransition)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (BOOL)didTheTreeOfView:(NSView *)view containPosition:(NSPoint)position;
- (BOOL)didView:(NSView *)parent contain:(NSView *)child;
- (BOOL)didViews:(NSArray *)views contain:(NSView *)view;
- (BOOL)didWindow:(NSWindow *)parent contain:(NSWindow *)child;
- (BOOL)didWindows:(NSArray *)windows contain:(NSWindow *)window;

@end
