//
//  FLOPopoverWindow.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOPopoverWindow.h"

#import "FLOPopoverProtocols.h"

@interface FLOPopoverWindow () {
    __weak id<FLOPopoverProtocols> _responder;
}

@end

@implementation FLOPopoverWindow

@synthesize disabledColor = _disabledColor;

- (instancetype)init {
    if (self = [super init]) {
        _tag = -1;
        _userInteractionEnable = YES;
        _floatsWhenAppResignsActive = NO;
    }
    
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        _tag = -1;
        _userInteractionEnable = YES;
        _floatsWhenAppResignsActive = NO;
    }
    
    return self;
}

#pragma mark - Override methods

- (BOOL)canBecomeKeyWindow {
    return (self.userInteractionEnable ? self.canBecomeKey : NO);
}

- (void)addChildWindow:(NSWindow *)childWindow ordered:(NSWindowOrderingMode)place {
    [super addChildWindow:childWindow ordered:place];
    
    if ([childWindow isKindOfClass:[FLOPopoverWindow class]]) {
        [(FLOPopoverWindow *)childWindow setUserInteractionEnable:self.userInteractionEnable];
    }
}

#pragma mark - Getter/Setter

- (void)setUserInteractionEnable:(BOOL)userInteractionEnable {
    _userInteractionEnable = userInteractionEnable;
    
    if (self.responder.userInteractionEnable != _userInteractionEnable) {
        [self.responder setUserInteractionEnable:userInteractionEnable];
    }
}

- (void)setDisabledColor:(NSColor *)disabledColor {
    _disabledColor = disabledColor;
    
    if (self.responder.disabledColor != _disabledColor) {
        [self.responder setDisabledColor:disabledColor];
    }
}

#pragma mark - FLOPopoverWindow methods

- (void)setResponder:(id<FLOPopoverProtocols>)responder {
    _responder = responder;
}

- (id<FLOPopoverProtocols>)responder {
    return _responder;
}

- (void)invalidateShadow {
    // Because of [invalidateShadow] of NSWindow is not working,
    // We should do the trick as following to force the NSWindow re-renders its shadow.
    NSRect frame = [self frame];
    NSRect updatedFrame = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width + 1.0, frame.size.height + 1.0);
    
    [self setFrame:updatedFrame display:YES];
    [self setFrame:frame display:YES];
}

@end
