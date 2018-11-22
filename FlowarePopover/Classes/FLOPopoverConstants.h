//
//  FLOPopoverConstants.h
//  FlowarePopover
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#ifndef FLOPopoverConstants_h
#define FLOPopoverConstants_h

#define FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD                                          0.2
#define FLO_CONST_POPOVER_BOTTOM_OFFSET                                                     5.0

typedef NS_ENUM(NSInteger, FLOPopoverType) {
    FLOWindowPopover,
    FLOViewPopover
};

typedef NS_ENUM(NSInteger, FLOPopoverAnchorType) {
    // The anchor view has positive top and positive leading contraints to the positioningView
    FLOPopoverAnchorTopPositiveLeadingPositive,
    // The anchor view has positive top and negative leading contraints to the positioningView
    FLOPopoverAnchorTopPositiveLeadingNegative,
    // The anchor view has negative top and positive leading contraints to the positioningView
    FLOPopoverAnchorTopNegativeLeadingPositive,
    // The anchor view has negative top and negative leading contraints to the positioningView
    FLOPopoverAnchorTopNegativeLeadingNegative,
    
    // The anchor view has positive top and positive trailing contraints to the positioningView
    FLOPopoverAnchorTopPositiveTrailingPositive,
    // The anchor view has positive top and negative trailing contraints to the positioningView
    FLOPopoverAnchorTopPositiveTrailingNegative,
    // The anchor view has negative top and positive trailing contraints to the positioningView
    FLOPopoverAnchorTopNegativeTrailingPositive,
    // The anchor view has negative top and negative trailing contraints to the positioningView
    FLOPopoverAnchorTopNegativeTrailingNegative,
    
    // The anchor view has positive bottom and positive leading contraints to the positioningView
    FLOPopoverAnchorBottomPositiveLeadingPositive,
    // The anchor view has positive bottom and negative leading contraints to the positioningView
    FLOPopoverAnchorBottomPositiveLeadingNegative,
    // The anchor view has negative bottom and positive leading contraints to the positioningView
    FLOPopoverAnchorBottomNegativeLeadingPositive,
    // The anchor view has negative bottom and negative leading contraints to the positioningView
    FLOPopoverAnchorBottomNegativeLeadingNegative,
    
    // The anchor view has positive bottom and positive trailing contraints to the positioningView
    FLOPopoverAnchorBottomPositiveTrailingPositive,
    // The anchor view has positive bottom and negative trailing contraints to the positioningView
    FLOPopoverAnchorBottomPositiveTrailingNegative,
    // The anchor view has negative bottom and positive trailing contraints to the positioningView
    FLOPopoverAnchorBottomNegativeTrailingPositive,
    // The anchor view has negative bottom and negative trailing contraints to the positioningView
    FLOPopoverAnchorBottomNegativeTrailingNegative
};

typedef NS_ENUM(NSInteger, FLOPopoverEdgeType) {
    // Popover will be displayed ABOVE of the selected view,
    // with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeAboveLeftEdge,
    
    // Popover will be displayed ABOVE of the selected view,
    // with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeAboveRightEdge,
    
    // Popover will be displayed BELOW of the selected view,
    // with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBelowLeftEdge,
    
    // Popover will be displayed BELOW of the selected view,
    // with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBelowRightEdge,
    
    // Popover will be displayed at BACKWARD of the selected view,
    // with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBackwardBottomEdge,
    
    // Popover will be displayed at BACKWARD of the selected view,
    // with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBackwardTopEdge,
    
    // Popover will be displayed at FORWARD of the selected view,
    // with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeForwardBottomEdge,
    
    // Popover will be displayed at FORWARD of the selected view,
    // with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeForwardTopEdge,
    
    // Popover will be displayed ABOVE of the selected view,
    // with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeAboveCenter,
    
    // Popover will be displayed BELOW of the selected view,
    // with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBelowCenter,
    
    // Popover will be displayed BACKWARD of the selected view,
    // with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeBackwardCenter,
    
    // Popover will be displayed FORWARD of the selected view,
    // with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)
    FLOPopoverEdgeTypeForwardCenter,
};

typedef NS_ENUM(NSInteger, FLOPopoverAppearance) {
    /*
     - popover will display with the utility animation (if animations anable)
     - arrow point to the preferred Edge (if required)
     */
    FLOPopoverAppearanceUtility = 0,
    
    /*
     - popover will display with the custom animation (if animations anable)
     - arrow point to the preferred Edge (if required)
     */
    FLOPopoverAppearanceUserDefined
};

typedef NS_ENUM(NSInteger, FLOPopoverAnimationBehaviour) {
    /*
     - popover will display with the utility effect
     */
    FLOPopoverAnimationBehaviorNone = 0,
    
    /*
     - popover will display with the transform effect (scale, rotate, ...)
     */
    FLOPopoverAnimationBehaviorTransform,
    
    /*
     - popover will display with the the following requires:
     + shift from left to right before displaying
     + shift from right to right before displaying
     + shift from top to bottom before displaying
     + shift from bottom to top before displaying
     */
    FLOPopoverAnimationBehaviorTransition
};


typedef NS_ENUM(NSInteger, FLOPopoverAnimationTransition) {
    FLOPopoverAnimationLeftToRight = 0,
    FLOPopoverAnimationRightToLeft,
    FLOPopoverAnimationTopToBottom,
    FLOPopoverAnimationBottomToTop,
    FLOPopoverAnimationFromMiddle
};

#endif /* FLOPopoverConstants_h */
