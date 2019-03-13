//
//  TableRowView.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/13/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TableRowView.h"

@implementation TableRowView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone)
    {
        // Check UI of ViewComponents for more details.
        // |-- TableRowView
        //    |-- CustomCellView
        //       |-- ContainerView
        NSView *containerView = [[[self.subviews firstObject] subviews] firstObject];
        NSRect selectionRect = [containerView convertRect:containerView.bounds toView:self];
        
#ifdef SHOULD_USE_ASSET_COLORS
        [[NSColor _blueColor] setStroke];
        [[NSColor _backgroundColor] setFill];
#else
        [[NSColor blueColor] setStroke];
        [[NSColor backgroundColor] setFill];
#endif
        
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:5.0 yRadius:5.0];
        selectionPath.lineWidth = 5.0;
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
