//
//  FLOVirtualInteractionView.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOVirtualInteractionView.h"

@implementation FLOVirtualInteractionView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setTitle:@""];
        [self setBordered:NO];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor.whiteColor colorWithAlphaComponent:0.01] CGColor]];
    }
    
    return self;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return [super hitTest:aPoint];
}

- (void)mouseDown:(NSEvent *)event {
}

@end
