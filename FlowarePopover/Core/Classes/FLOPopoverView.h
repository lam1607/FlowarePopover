//
//  FLOPopoverView.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FLOPopoverProtocols;

@protocol FLOPopoverViewDelegate <NSObject>

@optional
- (void)popoverWillMakeMovement;
- (void)popoverDidMakeMovement;
- (void)popoverDidMakeDetachable:(NSWindow *)targetWindow;

@end

@interface FLOPopoverView : NSView

@property (nonatomic, weak, readonly) id<FLOPopoverProtocols> responder;

@property (nonatomic, assign, readwrite) NSInteger tag;

@property (nonatomic, weak) id<FLOPopoverViewDelegate> delegate;

/// The edge of the target view which the popover is appearing next to. This will
/// be set by the popover.
@property (nonatomic, assign, readonly) NSRectEdge popoverEdge;

/// The rectangle, in screen coordinates, where the popover originated. This will
/// be set by the popover.
@property (nonatomic, assign, readonly) NSRect popoverOrigin;

/// The path which the view will clip to. The clippingPath will be retained and
/// released automatically.
@property (nonatomic, readonly) CGPathRef clippingPath;
@property (nonatomic, readonly) CGColorRef pathColor;

@property (nonatomic, assign, readonly) BOOL isArrowVisible;

/// The size of the arrow used to indicate the origin of the popover.
///
/// Note that the height will always be the distance from the view to the tip of
/// the arrow.
@property (nonatomic, assign) NSSize arrowSize;

/// The color used to fill the shape of the background view.
@property (nonatomic, strong) NSColor *fillColor;

@property (nonatomic, assign) CGFloat borderRadius;

/// Determine whether the popover can be interacted.
@property (nonatomic, assign) BOOL userInteractionEnable;

/// The dim color of disable view when the popover interaction is disabled.
@property (nonatomic, strong) NSColor *disabledColor;

/// Make popover become key, order front when mouse hovers the popover
///
@property (nonatomic, assign) BOOL becomesKeyOnMouseOver;

/// Given a size of the content this should be overridden by subclasses to
/// describe how big the overall popover should be.
///
/// contentSize - The size of the content contained within the popover.
/// popoverEdge - The edge that is adjacent to the `positioningFrame`.
///
/// Returns the overall size of the backgroundView as a `CGSize`.
- (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(NSRectEdge)popoverEdge;

- (NSSize)contentViewSizeForSize:(NSSize)size;

/// Given a frame for the background this should be overridden by subclasses to
/// describe where the content should fit within the popover.
/// By default this sits the content in the frame of the background view whilst
/// nudging the content to make room for the arrow and a 1px border.
///
/// frame            - The frame of the `backgroundView`.
/// popoverEdge      - The edge that is adjacent to the `positioningFrame`.
///
/// Returns the frame of the content relative to the given background view frame
/// as a `NSRect`.
- (NSRect)contentViewFrameForBackgroundFrame:(NSRect)frame popoverEdge:(NSRectEdge)popoverEdge;

/// The outline shape of a popover.
/// This can be overridden by subclasses if they wish to change the shape of the
/// popover but still use the default drawing of a simple stroke and fill.
///
/// popoverEdge - The edge that is adjacent to the `positioningFrame`.
/// frame       - The frame of the background view.
///
/// Returns a `CGPathRef` of the outline of the background view.
- (CGPathRef)clippingPathForEdge:(NSRectEdge)popoverEdge frame:(NSRect)frame;


- (void)setResponder:(id<FLOPopoverProtocols>)responder;
- (void)setMovable:(BOOL)movable;
- (void)setDetachable:(BOOL)detachable;
- (void)setShadow:(BOOL)needed;
- (void)setArrow:(BOOL)needed;
- (void)setVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state;
- (void)setArrowColor:(CGColorRef)color;
- (void)setPopoverEdge:(NSRectEdge)popoverEdge;
- (void)setPopoverOrigin:(NSRect)popoverOrigin;

/// Invalidate the popover shadow in case of changing position of popover arrow
/// or other case the popover shadow not updated when popover moves.
- (void)invalidateShadow;

@end
