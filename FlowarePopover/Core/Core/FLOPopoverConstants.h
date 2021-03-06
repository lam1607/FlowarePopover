//
//  FLOPopoverConstants.h
//  FlowarePopover
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#ifndef FLOPopoverConstants_h
#define FLOPopoverConstants_h

#import <Foundation/Foundation.h>

static const NSUInteger kFlowarePopover_Max_Try                     = 4;
static const NSTimeInterval kFlowarePopover_AnimationTimeInterval   = 0.2;
static const CGFloat kFlowarePopover_BottomOffset                   = 5.0;
static const CGFloat kFlowarePopover_ShadowRadius                   = 5.0;
static const CGFloat kFlowarePopover_BorderRadius                   = 5.0;
static const CGFloat kFlowarePopover_ArrowWidth                     = 17.0;
static const CGFloat kFlowarePopover_ArrowHeight                    = 12.0;
/// Summary
/// Sets the origin and size of the window’s frame rectangle according to a given frame rectangle, thereby setting its position and size onscreen.
/// Declaration
///     - (void)setFrame:(NSRect)frameRect display:(BOOL)flag;
/// Discussion
///     Note that the window server limits window position coordinates to ±16,000 and sizes to 10,000.
/// Parameters
///     frameRect: The frame rectangle for the window, including the title bar.
///     flag: Specifies whether the window redraws the views that need to be displayed.
///     When YES the window sends a displayIfNeeded message down its view hierarchy, thus redrawing all views.
/// References
///     apple-reference-documentation://hc8DLANLsA
///     apple-reference-documentation://hceMUw20an
static const CGFloat kFlowarePopover_OffScreen_Value                = -16000;

typedef NS_ENUM(NSInteger, FLOPopoverType) {
    FLOWindowPopover,
    FLOViewPopover
};

typedef NS_ENUM(NSInteger, FLOPopoverStyle) {
    FLOPopoverStyleNormal,
    FLOPopoverStyleAlert
};

typedef NS_ENUM(NSInteger, FLOVirtualViewType) {
    FLOVirtualViewNone,
    FLOVirtualViewDisable
};

/// NSLayoutAttributeTop
/// NSLayoutAttributeLeading
/// NSLayoutAttributeBottom
/// NSLayoutAttributeTrailing
/// The anchor view used to display the popover has the following type of 'constraints' to the positioningView
/// (top, leading), (top, trailing), (bottom, leading), (bottom, trailing)
typedef NS_ENUM(NSInteger, FLOPopoverRelativePositionType) {
    /// Automatic: It means that relative position (anchor view constraints)
    /// will be calculated automatically based on the given frame
    FLOPopoverRelativePositionAutomatic,
    FLOPopoverRelativePositionTopLeading,
    FLOPopoverRelativePositionTopTrailing,
    FLOPopoverRelativePositionBottomLeading,
    FLOPopoverRelativePositionBottomTrailing
};

typedef NS_ENUM(NSInteger, FLOPopoverEdgeType) {
    /// Popover will be displayed ABOVE of the selected view,
    /// with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeAboveLeftEdge,
    
    /// Popover will be displayed ABOVE of the selected view,
    /// with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeAboveRightEdge,
    
    /// Popover will be displayed BELOW of the selected view,
    /// with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBelowLeftEdge,
    
    /// Popover will be displayed BELOW of the selected view,
    /// with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBelowRightEdge,
    
    /// Popover will be displayed at BACKWARD of the selected view,
    /// with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBackwardBottomEdge,
    
    /// Popover will be displayed at BACKWARD of the selected view,
    /// with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBackwardTopEdge,
    
    /// Popover will be displayed at FORWARD of the selected view,
    /// with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeForwardBottomEdge,
    
    /// Popover will be displayed at FORWARD of the selected view,
    /// with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeForwardTopEdge,
    
    /// Popover will be displayed ABOVE of the selected view,
    /// with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeAboveCenter,
    
    /// Popover will be displayed BELOW of the selected view,
    /// with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBelowCenter,
    
    /// Popover will be displayed BACKWARD of the selected view,
    /// with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBackwardCenter,
    
    /// Popover will be displayed FORWARD of the selected view,
    /// with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeForwardCenter,
};

typedef NS_ENUM(NSInteger, FLOPopoverAppearance) {
    /// Popover will display with the utility animation (if animations anable)
    /// arrow point to the preferred edge (if required)
    FLOPopoverAppearanceUtility = 0,
    
    /// Popover will display with the custom animation (if animations anable)
    /// arrow point to the preferred Edge (if required)
    FLOPopoverAppearanceUserDefined
};

typedef NS_ENUM(NSInteger, FLOPopoverAnimationBehaviour) {
    /// Popover will display with default slightly fade in/out animation
    FLOPopoverAnimationBehaviorDefault = 0,
    
    /// popover will display with the transform effect (scale, rotate, ...)
    FLOPopoverAnimationBehaviorTransform,
    
    /// Popover will display with the the following requires:
    ///     + shift from left to right before displaying
    ///     + shift from right to right before displaying
    ///     + shift from top to bottom before displaying
    ///     + shift from bottom to top before displaying
    FLOPopoverAnimationBehaviorTransition
};


typedef NS_ENUM(NSInteger, FLOPopoverAnimationType) {
    /// FLOPopoverAnimationBehaviorDefault
    FLOPopoverAnimationDefault = 0,
    
    /// FLOPopoverAnimationBehaviorTransform
    FLOPopoverAnimationScale,
    FLOPopoverAnimationRotate,
    FLOPopoverAnimationFlip,
    
    /// FLOPopoverAnimationBehaviorTransition
    FLOPopoverAnimationLeftToRight,
    FLOPopoverAnimationRightToLeft,
    FLOPopoverAnimationTopToBottom,
    FLOPopoverAnimationBottomToTop
};

#endif /* FLOPopoverConstants_h */
