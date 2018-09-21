//
//  FLOPopoverUtils.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverUtils.h"

@interface FLOPopoverUtils ()

@property (nonatomic, strong, readwrite) NSWindow *appMainWindow;

@property (nonatomic, strong, readwrite) NSWindow *topWindow;
@property (nonatomic, strong, readwrite) NSView *topView;

@property (nonatomic, strong, readwrite) NSWindow *animatedWindow;

@end

@implementation FLOPopoverUtils

@synthesize appMainWindow = _appMainWindow;
@synthesize topWindow = _topWindow;
@synthesize topView = _topView;

#pragma mark -
#pragma mark - Singleton
#pragma mark -
+ (FLOPopoverUtils *)sharedInstance {
    static FLOPopoverUtils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FLOPopoverUtils alloc] init];
        _sharedInstance.appMainWindow = [NSApp mainWindow];
    });
    
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Getter/Setter
#pragma mark -
- (NSWindow *)appMainWindow {
    return _appMainWindow;
}

- (NSWindow *)topWindow {
    return _topWindow;
}

- (NSView *)topView {
    return _topView;
}

- (NSWindow *)animatedWindow {
    if (_animatedWindow == nil) {
        _animatedWindow = [[NSWindow alloc] initWithContentRect:self.appMainWindow.screen.visibleFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
        
        _animatedWindow.hidesOnDeactivate = YES;
        _animatedWindow.releasedWhenClosed = NO;
        _animatedWindow.opaque = NO;
        _animatedWindow.hasShadow = NO;
        _animatedWindow.backgroundColor = [NSColor clearColor];
        _animatedWindow.contentView.wantsLayer = YES;
    }
    
    return _animatedWindow;
}

- (void)setTopmostWindow:(NSWindow *)topmostWindow {
    _topWindow = topmostWindow;
}

- (void)setTopmostView:(NSView *)topmostView {
    _topView = topmostView;
}

#pragma mark -
#pragma mark - Utilities
#pragma mark -
+ (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame withAnimationType:(FLOPopoverAnimationTransition)animationType showing:(BOOL)showing {
    switch (animationType) {
        case FLOPopoverAnimationLeftToRight:
            if (showing) {
                (*fromFrame).origin.x -= (*toFrame).size.width / 2;
            } else {
                (*toFrame).origin.x -= (*fromFrame).size.width / 2;
            }
            break;
        case FLOPopoverAnimationRightToLeft:
            if (showing) {
                (*fromFrame).origin.x += (*toFrame).size.width / 2;
            } else {
                (*toFrame).origin.x += (*fromFrame).size.width / 2;
            }
            break;
        case FLOPopoverAnimationTopToBottom:
            if (showing) {
                (*fromFrame).origin.y += (*toFrame).size.height / 2;
            } else {
                (*toFrame).origin.y += (*fromFrame).size.height / 2;
            }
            break;
        case FLOPopoverAnimationBottomToTop:
            if (showing) {
                (*fromFrame).origin.y -= (*toFrame).size.height / 2;
            } else {
                (*toFrame).origin.y -= (*fromFrame).size.height / 2;
            }
            break;
        case FLOPopoverAnimationFromMiddle:
            break;
        default:
            break;
    }
}

@end
