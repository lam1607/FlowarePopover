//
//  CustomNSTableRowView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/9/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "CustomNSTableRowView.h"

@implementation CustomNSTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5f, 2.5f);
        [[NSColor colorTeal] setStroke];
        [[NSColor colorBackground] setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:5.0f yRadius:5.0f];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
