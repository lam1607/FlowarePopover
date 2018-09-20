//
//  FLOPopoverWindowController.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverWindowController.h"

#pragma mark -
#pragma mark - FLOPopoverWindow
#pragma mark -
@interface FLOPopoverWindow ()

@property (nonatomic, strong, readwrite) NSWindow *appMainWindow;

@property (nonatomic, strong, readwrite) NSWindow *topWindow;
@property (nonatomic, strong, readwrite) NSView *topView;

@property (nonatomic, strong, readwrite) NSWindow *animatedWindow;

@end

@implementation FLOPopoverWindow

@synthesize appMainWindow = _appMainWindow;
@synthesize topWindow = _topWindow;
@synthesize topView = _topView;

#pragma mark -
#pragma mark - Singleton
#pragma mark -
+ (FLOPopoverWindow *)sharedInstance {
    static FLOPopoverWindow *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FLOPopoverWindow alloc] init];
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

@end

#pragma mark -
#pragma mark - FLOPopoverWindowController
#pragma mark -
@interface FLOPopoverWindowController ()

@end

@implementation FLOPopoverWindowController

@end
