//
//  SplitViewManager.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/28/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, SplitViewArrangeType)
{
    SplitViewArrangeTypeUnknown,
    SplitViewArrangeTypeLeftToRight = 1,
    SplitViewArrangeTypeTopToBottom
};

typedef NS_ENUM(NSInteger, SplitSubviewType)
{
    SplitSubviewTypeNarrow = 1,
    SplitSubviewTypeWide
};

typedef NS_ENUM(NSInteger, SplitSubviewNormaLengthType)
{
    SplitSubviewNormaLengthTypeNarrow = 350,
    SplitSubviewNormaLengthTypeNarrowExpanded = 660,
    SplitSubviewNormaLengthTypeWideCollapsed = 520,
    SplitSubviewNormaLengthTypeWide = -1
};

#pragma mark -

@interface CustomNSSplitView : NSSplitView

@property (nonatomic, assign) CGFloat interSpacing;

@end

#pragma mark -

@protocol SplitViewManagerProtocols <NSObject>

@optional

@end

#pragma mark -

@interface SplitViewManager : NSObject

/// Protocols
///
@property (nonatomic, weak, readonly) id<SplitViewManagerProtocols> protocols;

/// @property
///
@property (nonatomic, weak, readonly) NSSplitView *splitView;
@property (nonatomic, assign, readonly) SplitViewArrangeType splitType;
@property (nonatomic, assign, readonly) NSSplitViewDividerStyle dividerStyle;
@property (nonatomic, assign, readonly) BOOL resizesProportionally;
@property (nonatomic, assign, readonly) BOOL resizesByDivider;
@property (nonatomic, assign, readonly) CGFloat interSpacing;

@property (nonatomic, assign, readonly) BOOL isVertical;
@property (nonatomic, assign, readonly) CGFloat subviewsMinimumLength;
@property (nonatomic, assign, readonly) CGFloat subviewsLength;

/// Initializes
///
- (instancetype _Nullable)initWithSplitView:(NSSplitView * _Nonnull)splitView source:(id<SplitViewManagerProtocols>_Nonnull)source;
- (instancetype _Nullable)initWithSplitView:(NSSplitView * _Nonnull)splitView splitType:(SplitViewArrangeType)splitType source:(id<SplitViewManagerProtocols>_Nonnull)source;

/// SplitViewManager methods
///
- (void)setSplitType:(SplitViewArrangeType)splitType;
- (void)setDividerStyle:(NSSplitViewDividerStyle)dividerStyle;
- (void)setResizesProportionally:(BOOL)resizesProportionally;
- (void)setResizesByDivider:(BOOL)resizesByDivider;
- (void)setInterSpacing:(CGFloat)interSpacing;

- (void)setMinimumLength:(CGFloat)minLength forView:(NSView *_Nonnull)view;
- (void)setLength:(CGFloat)length forView:(NSView *_Nonnull)view;
- (void)setProportionalLength:(CGFloat)proportionalLength forView:(NSView *_Nonnull)view;

/**
 * Set the frames of the split view's subviews so that they, plus the dividers, fill the split view.
 * The default implementation of this method resizes all of the subviews proportionally
 * so that the ratio of heights (in the horizontal split view case) or widths (in the vertical split view case) doesn't change,
 * even though the absolute sizes of the subviews do change.
 * This message should be sent to split views from which subviews have been added or removed,
 * to reestablish the consistency of subview placement.
 */
- (void)adjustSubviews;

/**
 * Adds a view as arranged split pane. If the view is not a subview of the receiver, it will be added as one.
 */
- (BOOL)addArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength length:(CGFloat)length;

/**
 * Adds a view as arranged split pane. If the view is not a subview of the receiver, it will be added as one.
 */
- (BOOL)addArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength proportionalLength:(CGFloat)proportionalLength;

/**
 * Adds a view as an arranged split pane list at the specific index.
 * If the view is already an arranged split view, it will move the view the specified index (but not move the subview index).
 * If the view is not a subview of the receiver, it will be added as one (not necessarily at the same index).
 */
- (BOOL)insertArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength length:(CGFloat)length atIndex:(NSInteger)index;

/**
 * Adds a view as an arranged split pane list at the specific index.
 * If the view is already an arranged split view, it will move the view the specified index (but not move the subview index).
 * If the view is not a subview of the receiver, it will be added as one (not necessarily at the same index).
 */
- (BOOL)insertArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength proportionalLength:(CGFloat)proportionalLength atIndex:(NSInteger)index;

/**
 * Removes a view as arranged split pane. If \c -arrangesAllSubviews is set to NO, this does not remove the view as a subview.
 * Removing the view as a subview (either by -[view removeFromSuperview] or setting the receiver's subviews) will automatically remove it as an arranged subview.
 */
- (BOOL)removeArrangedSubview:(NSView *_Nonnull)view;

@end
