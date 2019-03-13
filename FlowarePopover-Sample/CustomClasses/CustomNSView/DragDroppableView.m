//
//  DragDroppableView.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "DragDroppableView.h"

@implementation DragDroppableView

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, nil]];
    }
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, nil]];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, nil]];
}

#pragma mark - NSDraggingDestination implementation

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)draggingInfo
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    return (([draggingInfo draggingSource] != nil) && ([[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])) ? NSDragOperationGeneric : NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)draggingInfo
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    return (([draggingInfo draggingSource] != nil) && ([[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])) ? NSDragOperationGeneric : NSDragOperationNone;
}

- (void)draggingExited:(nullable id<NSDraggingInfo>)draggingInfo
{
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)draggingInfo
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    BOOL agreesToPerform = NO;
    
    if ([[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])
    {
        agreesToPerform = YES;
        
        id draggedObject = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:(NSPasteboardType)kUTTypeData]];
        NSPoint draggedLocation = [self convertPoint:draggingInfo.draggingLocation fromView:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dragDroppableView:performDragOperation:object:location:)])
        {
            [self.delegate dragDroppableView:self performDragOperation:draggingInfo object:draggedObject location:draggedLocation];
        }
    }
    
    return agreesToPerform;
}

- (void)draggingEnded:(id<NSDraggingInfo>)draggingInfo
{
}

@end
