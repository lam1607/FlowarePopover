//
//  CustomNSOutlineView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/23/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "CustomNSOutlineView.h"

@implementation CustomNSOutlineView

#pragma mark -
#pragma mark - Mouse events
#pragma mark -
- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    
    NSPoint clickedPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:clickedPoint];
    
    if ([[self pdelegate] respondsToSelector:@selector(outlineView:didSelectRow:)]){
        [[self pdelegate] outlineView:self didSelectRow:clickedRow];
    }
    
    if ([[self pdelegate] respondsToSelector:@selector(outlineView:didSelectRow:location:)]) {
        [[self pdelegate] outlineView:self didSelectRow:clickedRow location:clickedPoint];
    }
}

@end
