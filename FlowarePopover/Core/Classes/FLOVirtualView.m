//
//  FLOVirtualView.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 7/19/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOVirtualView.h"

@implementation FLOVirtualView

#pragma mark - Initialize

- (instancetype)initWithFrame:(NSRect)frameRect type:(FLOVirtualViewType)type {
    if (self = [super initWithFrame:frameRect]) {
        _type = type;
        
        [self setupUI];
    }
    
    return self;
}

#pragma mark - Override methods

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return (self.type != FLOVirtualViewAnimation) ? [super hitTest:aPoint] : nil;
}

#pragma mark - Local methods

- (void)setupUI {
    if (self.type == FLOVirtualViewDisable) {
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor.whiteColor colorWithAlphaComponent:0.01] CGColor]];
    }
}

#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)event {
    // Don't do anything here. Just leave this method
    // for receiving the mouse click event on the custom view,
    // instead of those below.
}

@end
