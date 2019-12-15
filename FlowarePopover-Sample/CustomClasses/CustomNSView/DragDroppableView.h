//
//  DragDroppableView.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

@class DragDroppableView;

@protocol DragDropTrackingDelegate <NSObject>

@optional
- (void)dragDroppableView:(DragDroppableView *)dragDroppableView performDragOperation:(id<NSDraggingInfo>)draggingInfo object:(id)object location:(NSPoint)location;

@end

@interface DragDroppableView : NSView <NSDraggingDestination>

@property (nonatomic, weak) id<DragDropTrackingDelegate> delegate;

@end
