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

#pragma mark -
#pragma mark - Utilities
#pragma mark -
- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame withAnimationType:(FLOPopoverAnimationTransition)animationType showing:(BOOL)showing;

@end
