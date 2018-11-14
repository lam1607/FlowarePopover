//
//  FLOPopoverUtils.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverUtils.h"

@interface FLOPopoverUtils () <NSWindowDelegate>

@property (nonatomic, strong, readwrite) NSWindow *appMainWindow;

@property (nonatomic, strong, readwrite) NSWindow *topWindow;
@property (nonatomic, strong, readwrite) NSView *topView;

@property (nonatomic, assign, readwrite) BOOL appMainWindowResized;

@end

@implementation FLOPopoverUtils

@synthesize appMainWindow = _appMainWindow;
@synthesize topWindow = _topWindow;
@synthesize topView = _topView;
@synthesize appMainWindowResized = _appMainWindowResized;

#pragma mark -
#pragma mark - Singleton
#pragma mark -
+ (FLOPopoverUtils *)sharedInstance {
    static FLOPopoverUtils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FLOPopoverUtils alloc] init];
        
        if ([NSApp mainWindow] != nil) {
            _sharedInstance.appMainWindow = [NSApp mainWindow];
        } else {
            _sharedInstance.appMainWindow = [[[NSApplication sharedApplication] windows] firstObject];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:_sharedInstance selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
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

- (BOOL)appMainWindowResized {
    return _appMainWindowResized;
}

- (void)setTopmostWindow:(NSWindow *)topmostWindow {
    _topWindow = topmostWindow;
}

- (void)setTopmostView:(NSView *)topmostView {
    _topView = topmostView;
}

- (void)setAppMainWindowResized:(BOOL)appMainWindowResized {
    _appMainWindowResized = appMainWindowResized;
}

#pragma mark -
#pragma mark - Local implementations
#pragma mark -
- (void)windowDidEndResize {
    _appMainWindowResized = NO;
}

#pragma mark -
#pragma mark - Utilities
#pragma mark -
- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame withAnimationType:(FLOPopoverAnimationTransition)animationType showing:(BOOL)showing {
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

- (BOOL)didTheTreeOfView:(NSView *)view containPosition:(NSPoint)position {
    NSRect relativeRect = [view convertRect:[view alignmentRectForFrame:[view bounds]] toView:nil];
    NSRect viewRect = [view.window convertRectToScreen:relativeRect];
    
    if (NSPointInRect(position, viewRect)) {
        return YES;
    } else {
        for (NSView *item in [view subviews]) {
            if ([self didTheTreeOfView:item containPosition:position]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)didView:(NSView *)parent contain:(NSView *)child {
    return [self didViews:[parent subviews] contain:child];
}

- (BOOL)didViews:(NSArray *)views contain:(NSView *)view {
    if ([views containsObject:view]) {
        return YES;
    } else {
        for (NSView *item in views) {
            if ([self didViews:[item subviews] contain:view]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)didWindow:(NSWindow *)parent contain:(NSWindow *)child {
    return [self didWindows:parent.childWindows contain:child];
}

- (BOOL)didWindows:(NSArray *)windows contain:(NSWindow *)window {
    if ([windows containsObject:window]) {
        return YES;
    } else {
        for (NSWindow *item in windows) {
            if ([self didWindows:item.childWindows contain:window]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark -
#pragma mark - NSWindowDelegate
#pragma mark -
- (void)windowDidResize:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowDidResizeNotification] && [notification.object isKindOfClass:[NSWindow class]]) {
        NSWindow *resizedWindow = (NSWindow *) notification.object;
        
        if (resizedWindow == self.appMainWindow) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(windowDidEndResize) object:nil];
            [self performSelector:@selector(windowDidEndResize) withObject:nil afterDelay:0.5];
        }
    }
}

@end
