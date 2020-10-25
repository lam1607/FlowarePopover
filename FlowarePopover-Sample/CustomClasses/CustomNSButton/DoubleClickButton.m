//
//  DoubleClickButton.m
//  FLOPopupPrototypes
//
//  Created by lamnguyen on 7/13/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import "DoubleClickButton.h"

@interface DoubleClickButton ()
{
    NSInteger _clickCount;
    double _actionTime;
}

@end

@implementation DoubleClickButton

#pragma mark - Initialize

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        _clickCount = 0;
    }
    
    return self;
}

- (void)dealloc
{
}

#pragma mark - Override methods

- (BOOL)needsPanelToBecomeKey
{
    if (![self.window isKeyWindow] || ![[EntitlementsManager sharedInstance] isApplicationActive])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

#pragma mark - Local methods

- (void)invalidateClickCount
{
    _clickCount = 0;
}

- (void)onSingleClick
{
    @synchronized (self)
    {
        _clickCount = 1;
        [self delayAction];
        [self invalidateClickCount];
    }
}

- (void)onDoubleClick
{
    @synchronized (self)
    {
        _clickCount = 2;
        [self delayAction];
        [self invalidateClickCount];
    }
}

- (void)delayAction
{
    NSInteger oldState = self.state;
    
    if ((_clickCount == 2) && (self.state == NSControlStateValueOff))
    {
        self.state = NSControlStateValueOn;
    }
    else if (_clickCount == 1)
    {
        self.state = (self.state == NSControlStateValueOn) ? NSControlStateValueOff : NSControlStateValueOn;
    }
    
    if ((self.target != nil) && (self.doubleAction != nil) && (_clickCount == 2))
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.doubleAction withObject:self];
#pragma clang diagnostic pop
    }
    else if (self.target != nil && self.action != nil && oldState != self.state)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
    }
    
    _actionTime = 0.0;
}

#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
    _clickCount++;
    
    self.clickedPoint = theEvent.locationInWindow;
    
    // Should use application _clickCount for checking single or double click action
    // instead of using NSEvent.clickCount.
    // Because the NSEvent.clickCount is changed when user change the Double-Click speed
    // in Mouse (System Preferences)
    if (_clickCount == 2)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSingleClick) object:nil];
        
        double tDelta = theEvent.timestamp - _actionTime;
        double comparedValue = (self.state == NSControlStateValueOff) ? 0.0999 : 0.1999;
        
        if (tDelta > comparedValue)
        {
            [self performSelector:@selector(onDoubleClick) withObject:nil afterDelay:0.2];
        }
        else
        {
            [self onDoubleClick];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    // Should use application _clickCount for checking single or double click action
    // instead of using NSEvent.clickCount.
    // Because the NSEvent.clickCount is changed when user change the Double-Click speed
    // in Mouse (System Preferences)
    if (_clickCount == 1)
    {
        _actionTime = theEvent.timestamp;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSingleClick) object:nil];
        [self performSelector:@selector(onSingleClick) withObject:nil afterDelay:(self.state == NSControlStateValueOff) ? 0.1 : 0.2];
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    if ((self.target != nil) && (self.rightClickAction != nil))
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.rightClickAction withObject:self];
#pragma clang diagnostic pop
    }
}

@end
