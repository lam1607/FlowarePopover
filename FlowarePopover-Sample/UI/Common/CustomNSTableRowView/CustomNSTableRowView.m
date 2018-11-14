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
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
        
#ifdef SHOULD_USE_ASSET_COLORS
        [[NSColor _tealColor] setStroke];
        [[NSColor _backgroundColor] setFill];
#else
        [[NSColor tealColor] setStroke];
        [[NSColor backgroundColor] setFill];
#endif
        
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:5.0 yRadius:5.0];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
