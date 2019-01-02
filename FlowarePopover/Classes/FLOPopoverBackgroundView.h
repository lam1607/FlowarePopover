//
//  FLOPopoverBackgroundView.h
//  FlowarePopover
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopover.h"

static CGFloat const PopoverBackgroundViewBorderRadius = 5.0;
static CGFloat const PopoverBackgroundViewArrowWidth = 17.0;
static CGFloat const PopoverBackgroundViewArrowHeight = 12.0;

#pragma mark - FLOPopoverClippingView

// A class which forcably draws `NSClearColor.clearColor` around a given path,
// effectively clipping any views to the path. You can think of it like a
// `maskLayer` on a `CALayer`.
@interface FLOPopoverClippingView : NSView

// The path which the view will clip to. The clippingPath will be retained and
// released automatically.
@property (nonatomic) CGPathRef clippingPath;

@property (nonatomic) CGColorRef pathColor;

- (void)setupArrowPath;
- (void)setupArrowPathColor:(CGColorRef)color;

@end

#pragma mark - FLOPopoverBackgroundView

@protocol FLOPopoverBackgroundViewDelegate <NSObject>

@optional
- (void)didPopoverMakeMovement;
- (void)didPopoverBecomeDetachable:(NSWindow *)targetWindow;

@end

@interface FLOPopoverBackgroundView : FLOPopoverView

@property (nonatomic, weak) id<FLOPopoverBackgroundViewDelegate> delegate;

// The edge of the target view which the popover is appearing next to. This will
// be set by the popover.
@property (nonatomic, assign, readonly) NSRectEdge popoverEdge;

// The rectangle, in screen coordinates, where the popover originated. This will
// be set by the popover.
@property (nonatomic, assign, readonly) NSRect popoverOrigin;

// The size of the arrow used to indicate the origin of the popover.
//
// Note that the height will always be the distance from the view to the tip of
// the arrow.
@property (nonatomic, assign) NSSize arrowSize;

// The color used to fill the shape of the background view.
@property (nonatomic, strong) NSColor *fillColor;

@property (nonatomic, assign) CGFloat borderRadius;

// Given a size of the content this should be overridden by subclasses to
// describe how big the overall popover should be.
//
// contentSize - The size of the content contained within the popover.
// popoverEdge - The edge that is adjacent to the `positioningRect`.
//
// Returns the overall size of the backgroundView as a `CGSize`.
- (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(NSRectEdge)popoverEdge;

- (NSSize)contentViewSizeForSize:(NSSize)size;

// Given a frame for the background this should be overridden by subclasses to
// describe where the content should fit within the popover.
// By default this sits the content in the frame of the background view whilst
// nudging the content to make room for the arrow and a 1px border.
//
// frame            - The frame of the `backgroundView`.
// popoverEdge      - The edge that is adjacent to the `positioningRect`.
//
// Returns the frame of the content relative to the given background view frame
// as a `NSRect`.
- (NSRect)contentViewFrameForBackgroundFrame:(NSRect)frame popoverEdge:(NSRectEdge)popoverEdge;

// The outline shape of a popover.
// This can be overridden by subclasses if they wish to change the shape of the
// popover but still use the default drawing of a simple stroke and fill.
//
// popoverEdge - The edge that is adjacent to the `positioningRect`.
// frame       - The frame of the background view.
//
// Returns a `CGPathRef` of the outline of the background view.
- (CGPathRef)newPopoverPathForEdge:(NSRectEdge)popoverEdge inFrame:(NSRect)frame;

- (void)setMovable:(BOOL)movable;
- (void)setDetachable:(BOOL)detachable;
- (void)setShouldShowShadow:(BOOL)needed;
- (void)setShouldShowArrow:(BOOL)needed;
- (void)setArrowColor:(CGColorRef)color;
- (void)setPopoverEdge:(NSRectEdge)popoverEdge;
- (void)setPopoverOrigin:(NSRect)popoverOrigin;

@end
