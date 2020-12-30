//
//  SplitViewManager.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/28/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import "SplitViewManager.h"

@interface CustomNSSplitView ()

@end

@implementation CustomNSSplitView

/**
 * Return the color of the dividers that the split view is drawing between subviews.
 * The default implementation of this method returns [NSColor clearColor] for the thick divider style.
 * It will also return [NSColor clearColor] for the thin divider style when the split view is in a textured window.
 * All other thin dividers are drawn with a color that looks good between two white panes.
 * You can override this method to change the color of dividers.
 */
- (NSColor *)dividerColor
{
    return [NSColor clearColor];
}

/**
 * Return the thickness of the dividers that the split view is drawing between subviews.
 * The default implementation returns a value that depends on the divider style.
 * You can override this method to change the size of dividers.
 */
- (CGFloat)dividerThickness
{
    return self.interSpacing;
}

#pragma mark - Getter/Setter

- (void)setInterSpacing:(CGFloat)interSpacing
{
    BOOL isUpdated = (interSpacing != _interSpacing);
    
    _interSpacing = interSpacing;
    
    if (isUpdated)
    {
        [self setNeedsDisplay:YES];
    }
}

@end

#pragma mark -

@interface SplitViewManager () <NSSplitViewDelegate>
{
    __weak NSSplitView *_splitView;
    __weak id<SplitViewManagerProtocols> _protocols;
    
    BOOL _resizesProportionally;
    BOOL _resizesByDivider;
    CGFloat _interSpacing;
    
    NSMutableDictionary *_minLengthsByViewIndex, *_lengthsByViewIndex, *_proportionalLengthsByViewIndex;
    NSMutableDictionary *_viewIndicesByPriority;
}

@end

@implementation SplitViewManager

#pragma mark - Initialize

- (instancetype)initWithSplitView:(NSSplitView * _Nonnull)splitView source:(id<SplitViewManagerProtocols>_Nonnull)source
{
    return [self initWithSplitView:splitView splitType:SplitViewArrangeTypeLeftToRight source:source];
}

- (instancetype)initWithSplitView:(NSSplitView * _Nonnull)splitView splitType:(SplitViewArrangeType)splitType source:(id<SplitViewManagerProtocols>_Nonnull)source
{
    if (self = [super init])
    {
        if ([splitView isKindOfClass:[NSSplitView class]] && [source conformsToProtocol:@protocol(SplitViewManagerProtocols)])
        {
            _resizesProportionally = NO;
            _resizesByDivider = NO;
            _interSpacing = 5.0;
            _splitView = splitView;
            [_splitView setVertical:(splitType == SplitViewArrangeTypeLeftToRight)];
            [_splitView setDividerStyle:NSSplitViewDividerStyleThin];
            [_splitView setDelegate:self];
            _protocols = source;
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
    }
    
    return self;
}

- (void)dealloc
{
    _splitView = nil;
    _protocols = nil;
    
    [self resetMinLengthsByViewIndex];
    [self resetLengthsByViewIndex];
    [self resetProportionalLengthsByViewIndex];
    [self resetViewIndicesByPriority];
}

#pragma mark - Getter/Setter

- (NSSplitView *)splitView
{
    return _splitView;
}

- (SplitViewArrangeType)splitType
{
    if (self.splitView != nil)
    {
        return ([self.splitView isVertical] ? SplitViewArrangeTypeLeftToRight : SplitViewArrangeTypeTopToBottom);
    }
    
    return SplitViewArrangeTypeUnknown;
}

- (void)setSplitType:(SplitViewArrangeType)splitType
{
    if (self.splitView != nil)
    {
        [self.splitView setVertical:(splitType == SplitViewArrangeTypeLeftToRight)];
    }
}

- (NSSplitViewDividerStyle)dividerStyle
{
    if (self.splitView != nil)
    {
        return [self.splitView dividerStyle];
    }
    
    return NSSplitViewDividerStyleThick;
}

- (void)setDividerStyle:(NSSplitViewDividerStyle)dividerStyle
{
    if (self.splitView != nil)
    {
        [self.splitView setDividerStyle:dividerStyle];
    }
}

- (BOOL)resizesByDivider
{
    return _resizesByDivider;
}

- (BOOL)resizesProportionally
{
    return _resizesProportionally;
}

- (void)setResizesProportionally:(BOOL)resizesProportionally
{
    BOOL isUpdated = (resizesProportionally != _resizesProportionally);
    
    _resizesProportionally = resizesProportionally;
    
    if (isUpdated)
    {
        [self adjustSubviews];
    }
}

- (void)setResizesByDivider:(BOOL)resizesByDivider
{
    _resizesByDivider = resizesByDivider;
}

- (void)setInterSpacing:(CGFloat)interSpacing
{
    BOOL isUpdated = (interSpacing != _interSpacing);
    
    _interSpacing = interSpacing;
    
    if ([self.splitView isKindOfClass:[CustomNSSplitView class]])
    {
        [(CustomNSSplitView *)self.splitView setInterSpacing:interSpacing];
    }
    
    if (isUpdated)
    {
        [self adjustSubviews];
    }
}

#pragma mark - Local methods

- (void)resetMinLengthsByViewIndex
{
    [_minLengthsByViewIndex removeAllObjects];
    _minLengthsByViewIndex = nil;
}

- (void)resetLengthsByViewIndex
{
    [_lengthsByViewIndex removeAllObjects];
    _lengthsByViewIndex = nil;
}

- (void)resetProportionalLengthsByViewIndex
{
    [_proportionalLengthsByViewIndex removeAllObjects];
    _proportionalLengthsByViewIndex = nil;
}

- (void)resetViewIndicesByPriority
{
    [_viewIndicesByPriority removeAllObjects];
    _viewIndicesByPriority = nil;
}

- (void)handleResizeSubviewsLengthsWithOldSize:(NSSize)oldSize
{
    if (_lengthsByViewIndex.count > 0)
    {
        NSSplitView *splitView = self.splitView;
        NSArray *subviews = [splitView subviews];
        NSInteger subviewsCount = [subviews count];
        BOOL isVertical = [splitView isVertical];
        NSRect splitViewBounds = [splitView bounds];
        NSInteger totalTypeWides = [[_lengthsByViewIndex allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF = %ld", SplitSubviewNormaWidthTypeWide]].count;
        CGFloat delta = ([splitView isVertical] ? (NSWidth(splitViewBounds) - oldSize.width) : (NSHeight(splitViewBounds) - oldSize.height)) / ((totalTypeWides > 0) ? totalTypeWides : 1);
        
        for (NSNumber *priorityIndex in [[_viewIndicesByPriority allKeys] sortedArrayUsingSelector:@selector(compare:)])
        {
            NSNumber *viewIndex = [_viewIndicesByPriority objectForKey:priorityIndex];
            NSInteger viewIndexValue = [viewIndex integerValue];
            
            if (viewIndexValue >= subviewsCount)
            {
                continue;
            }
            
            NSView *view = [subviews objectAtIndex:viewIndexValue];
            NSSize frameSize = [view frame].size;
            NSNumber *minLength = [_minLengthsByViewIndex objectForKey:viewIndex];
            CGFloat minLengthValue = [minLength doubleValue];
            NSNumber *length = [_lengthsByViewIndex objectForKey:viewIndex];
            CGFloat lengthValue = [length doubleValue];
            
            if (isVertical)
            {
                frameSize.width = ((lengthValue != SplitSubviewNormaWidthTypeWide) ? lengthValue : ((frameSize.width + delta >= minLengthValue) ? (frameSize.width + delta) : minLengthValue));
                frameSize.height = NSHeight(splitViewBounds);
                
                // if ((delta > 0) || (frameSize.width + delta >= minLengthValue))
                // {
                //     frameSize.width += delta;
                //     delta = 0;
                // }
                // else if (delta < 0)
                // {
                //     delta += frameSize.width - minLengthValue;
                //     frameSize.width = minLengthValue;
                // }
            }
            else
            {
                frameSize.width = NSWidth(splitViewBounds);
                frameSize.height = ((lengthValue != SplitSubviewNormaWidthTypeWide) ? lengthValue : ((frameSize.height + delta >= minLengthValue) ? (frameSize.height + delta) : minLengthValue));
                
                // if ((delta > 0) || (frameSize.height + delta >= minLengthValue))
                // {
                //     frameSize.height += delta;
                //     delta = 0;
                // }
                // else if (delta < 0)
                // {
                //     delta += frameSize.height - minLengthValue;
                //     frameSize.height = minLengthValue;
                // }
            }
            
            [view setFrameSize:frameSize];
        }
        
        [self refreshSubviewsFrames];
    }
}

- (void)handleResizeSubviewsProportionalLengthsWithOldSize:(NSSize)oldSize
{
    if (_proportionalLengthsByViewIndex.count > 0)
    {
        NSSplitView *splitView = self.splitView;
        NSArray *subviews = [splitView subviews];
        NSInteger subviewsCount = [subviews count];
        BOOL isVertical = [splitView isVertical];
        NSRect splitViewBounds = [splitView bounds];
        CGFloat delta = [splitView isVertical] ? (NSWidth(splitViewBounds) - oldSize.width) : (NSHeight(splitViewBounds) - oldSize.height);
        
        for (NSNumber *priorityIndex in [[_viewIndicesByPriority allKeys] sortedArrayUsingSelector:@selector(compare:)])
        {
            NSNumber *viewIndex = [_viewIndicesByPriority objectForKey:priorityIndex];
            NSInteger viewIndexValue = [viewIndex integerValue];
            
            if (viewIndexValue >= subviewsCount)
            {
                continue;
            }
            
            NSView *view = [subviews objectAtIndex:viewIndexValue];
            NSSize frameSize = [view frame].size;
            NSNumber *minLength = [_minLengthsByViewIndex objectForKey:viewIndex];
            CGFloat minLengthValue = [minLength doubleValue];
            NSNumber *proportionalLength = [_lengthsByViewIndex objectForKey:viewIndex];
            CGFloat lengthValue = [proportionalLength doubleValue] * (isVertical ? NSWidth(splitViewBounds) : NSHeight(splitViewBounds));
            
            if (isVertical)
            {
                frameSize.width = ((lengthValue != SplitSubviewNormaWidthTypeWide) ? lengthValue : ((frameSize.width + delta >= minLengthValue) ? (frameSize.width + delta) : minLengthValue));
                frameSize.height = NSHeight(splitViewBounds);
                
                // if ((delta > 0) || (frameSize.width + delta >= minLengthValue))
                // {
                //     frameSize.width += delta;
                //     delta = 0;
                // }
                // else if (delta < 0)
                // {
                //     delta += frameSize.width - minLengthValue;
                //     frameSize.width = minLengthValue;
                // }
            }
            else
            {
                frameSize.width = NSWidth(splitViewBounds);
                frameSize.height = ((lengthValue != SplitSubviewNormaWidthTypeWide) ? lengthValue : ((frameSize.height + delta >= minLengthValue) ? (frameSize.height + delta) : minLengthValue));
                
                // if ((delta > 0) || (frameSize.height + delta >= minLengthValue))
                // {
                //     frameSize.height += delta;
                //     delta = 0;
                // }
                // else if (delta < 0)
                // {
                //     delta += frameSize.height - minLengthValue;
                //     frameSize.height = minLengthValue;
                // }
            }
            
            [view setFrameSize:frameSize];
        }
        
        [self refreshSubviewsFrames];
    }
}

- (void)refreshSubviewsFrames
{
    NSSplitView *splitView = self.splitView;
    CGFloat interspacing = self.interSpacing;
    NSArray *subviews = [splitView subviews];
    CGFloat offset = 0;
    // CGFloat dividerThickness = [splitView dividerThickness];
    
    for (NSView *subview in subviews)
    {
        NSRect viewFrame = subview.frame;
        NSPoint viewOrigin = viewFrame.origin;
        viewOrigin.x = offset;
        [subview setFrameOrigin:viewOrigin];
        offset += viewFrame.size.width + interspacing;
    }
}

#pragma mark - SplitViewManager methods

- (void)setMinimumLength:(CGFloat)minLength forViewAtIndex:(NSInteger)viewIndex
{
    if (minLength > 0.0)
    {
        if (!_minLengthsByViewIndex)
        {
            _minLengthsByViewIndex = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        [_minLengthsByViewIndex setObject:[NSNumber numberWithDouble:minLength] forKey:[NSNumber numberWithInteger:viewIndex]];
    }
    else
    {
        NSAssert1((minLength > 0.0), @"minLength value must be larger than 0.0. minLength parameter value %f is not valid.", minLength);
    }
}

- (void)setLength:(CGFloat)length forViewAtIndex:(NSInteger)viewIndex
{
    if ((length > 0.0) || (length == SplitSubviewNormaWidthTypeWide))
    {
        if (!_lengthsByViewIndex)
        {
            _lengthsByViewIndex = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        [_lengthsByViewIndex setObject:[NSNumber numberWithDouble:length] forKey:[NSNumber numberWithInteger:viewIndex]];
    }
    else
    {
        NSAssert1((length > 0.0), @"minLength value must be larger than 0.0. minLength parameter value %f is not valid.", length);
    }
}

- (void)setProportionalLength:(CGFloat)proportionalLength forViewAtIndex:(NSInteger)viewIndex
{
    if ((proportionalLength > 0.0) && (proportionalLength <= 1.0))
    {
        if (!_proportionalLengthsByViewIndex)
        {
            _proportionalLengthsByViewIndex = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        [_proportionalLengthsByViewIndex setObject:[NSNumber numberWithDouble:proportionalLength] forKey:[NSNumber numberWithInteger:viewIndex]];
    }
    else
    {
        NSAssert1(((proportionalLength > 0.0) && (proportionalLength <= 1.0)),
                  @"Proportional length value must stay in range (0, 1]. proportionalLength parameter value %f is not valid.",
                  proportionalLength);
    }
}

- (void)setPriority:(NSInteger)priorityIndex forViewAtIndex:(NSInteger)viewIndex
{
    if (!_viewIndicesByPriority)
    {
        _viewIndicesByPriority = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    [_viewIndicesByPriority setObject:[NSNumber numberWithInteger:viewIndex] forKey:[NSNumber numberWithInteger:priorityIndex]];
}

/**
 * Set the frames of the split view's subviews so that they, plus the dividers, fill the split view.
 * The default implementation of this method resizes all of the subviews proportionally
 * so that the ratio of heights (in the horizontal split view case) or widths (in the vertical split view case) doesn't change,
 * even though the absolute sizes of the subviews do change.
 * This message should be sent to split views from which subviews have been added or removed,
 * to reestablish the consistency of subview placement.
 */
- (void)adjustSubviews
{
    if ([self.splitView isKindOfClass:[NSSplitView class]])
    {
        [self adjustSubviews:[self.splitView bounds].size];
    }
}

- (void)adjustSubviews:(NSSize)oldSize
{
    if ([self.splitView isKindOfClass:[NSSplitView class]])
    {
        BOOL resizesProportionally = self.resizesProportionally;
        
        if (!resizesProportionally && (_lengthsByViewIndex.count > 0))
        {
            [self handleResizeSubviewsLengthsWithOldSize:oldSize];
        }
        else if (resizesProportionally && (_proportionalLengthsByViewIndex.count > 0))
        {
            [self handleResizeSubviewsProportionalLengthsWithOldSize:oldSize];
        }
    }
}

/**
 * Adds a view as arranged split pane. If the view is not a subview of the receiver, it will be added as one.
 */
- (BOOL)addArrangedSubview:(NSView *_Nonnull)view
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if (![view isDescendantOf:self.splitView])
        {
            successful = YES;
            [self.splitView addArrangedSubview:view];
            [self adjustSubviews];
        }
    }
    
    return successful;
}

/**
 * Adds a view as an arranged split pane list at the specific index.
 * If the view is already an arranged split view, it will move the view the specified index (but not move the subview index).
 * If the view is not a subview of the receiver, it will be added as one (not necessarily at the same index).
 */
- (BOOL)insertArrangedSubview:(NSView *_Nonnull)view atIndex:(NSInteger)index
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if (![view isDescendantOf:self.splitView])
        {
            @try
            {
                successful = YES;
                [self.splitView insertArrangedSubview:view atIndex:index];
                [self adjustSubviews];
            }
            @catch (NSException *exception)
            {
                NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols]:\n%@\n", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
            }
        }
    }
    
    return successful;
}

/**
 * Removes a view as arranged split pane. If \c -arrangesAllSubviews is set to NO, this does not remove the view as a subview.
 * Removing the view as a subview (either by -[view removeFromSuperview] or setting the receiver's subviews) will automatically remove it as an arranged subview.
 */
- (BOOL)removeArrangedSubview:(NSView *_Nonnull)view
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if ([view isDescendantOf:self.splitView])
        {
            successful = YES;
            [self.splitView removeArrangedSubview:view];
            [self adjustSubviews];
        }
    }
    
    return successful;
}

#pragma mark - NSSplitViewDelegate

/**
 * Return YES if a subview can be collapsed, NO otherwise.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * none of the split view's subviews can be collapsed.
 * If a split view has a delegate, and the delegate responds to this message,
 * it will be sent at least twice when the user clicks or double-clicks on one of the split view's dividers,
 * once per subview on either side of the divider, and may be resent as the user continues to drag the divider.
 * If a subview is collapsible, the current implementation of NSSplitView will collapse it
 * when the user has dragged the divider more than halfway between the position
 * that would make the subview its minimum size and the position that would make it zero size.
 * The subview will become uncollapsed if the user drags the divider back past that point.
 * The comments for -splitView:constrainMinCoordinate:ofSubviewAt: and -splitView:constrainMaxCoordinate:ofSubviewAt:
 * describe how subviews' minimum sizes are determined.
 * Collapsed subviews are hidden but retained by the split view. Collapsing of a subview will not change its bounds,
 * but may set its frame to zero pixels high (in horizontal split views) or zero pixels wide (vertical).
 */
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return NO;
}

/**
 * Return YES if the subview should be collapsed because the user has double-clicked on an adjacent divider.
 * If a split view has a delegate, and the delegate responds to this message,
 * it will be sent once for the subview before a divider when the user double-clicks on that divider,
 * and again for the subview after the divider, but only if the delegate returned YES when sent -splitView:canCollapseSubview:
 * for the subview in question. When the delegate indicates that both subviews should be collapsed NSSplitView's behavior is undefined.
 * API_DEPRECATED("NSSplitView no longer supports collapsing sections via double-click. This delegate method is never called.", macos(10.5, 10.15))
 */
//- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
//{
//    return NO;
//}

/**
 * Given a proposed minimum allowable position for one of the dividers of a split view,
 * return the minimum allowable position for the divider.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * the split view behaves as if it has a delegate that responds to this message by merely returning the proposed minimum.
 * If a split view has a delegate, and the delegate responds to this message,
 * it will be sent at least once when the user begins dragging one of the split view's dividers,
 * and may be resent as the user continues to drag the divider.
 * Delegates that respond to this message and return a number larger than the proposed minimum position effectively
 * declare a minimum size for the subview above or to the left of the divider in question,
 * the minimum size being the difference between the proposed and returned minimum positions.
 * This minimum size is only effective for the divider-dragging operation
 * during which the -splitView:constrainMinCoordinate:ofSubviewAt: message is sent.
 * NSSplitView's behavior is undefined when a delegate responds to this message by returning a number smaller than the proposed minimum.
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    NSView *subview = [[splitView subviews] objectAtIndex:dividerIndex];
    NSRect subviewFrame = subview.frame;
    CGFloat frameOrigin;
    
    if ([splitView isVertical])
    {
        frameOrigin = subviewFrame.origin.x;
    }
    else
    {
        frameOrigin = subviewFrame.origin.y;
    }
    
    CGFloat minimumSize = [[_minLengthsByViewIndex objectForKey:[NSNumber numberWithInteger:dividerIndex]] doubleValue];
    
    return frameOrigin + minimumSize;
}

/**
 * Given a proposed maximum allowable position for one of the dividers of a split view,
 * return the maximum allowable position for the divider.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * the split view behaves as if it has a delegate that responds to this message by merely returning the proposed maximum.
 * If a split view has a delegate, and the delegate responds to this message,
 * it will be sent at least once when the user begins dragging one of the split view's dividers,
 * and may be resent as the user continues to drag the divider.
 * Delegates that respond to this message and return a number smaller than the proposed maximum position effectively
 * declare a minimum size for the subview below or to the right of the divider in question,
 * the minimum size being the difference between the proposed and returned maximum positions.
 * This minimum size is only effective for the divider-dragging operation
 * during which the -splitView:constrainMaxCoordinate:ofSubviewAt: message is sent.
 * NSSplitView's behavior is undefined when a delegate responds to this message by returning a number larger than the proposed maximum.
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    NSView *growingSubview = [[splitView subviews] objectAtIndex:dividerIndex];
    NSView *shrinkingSubview = [[splitView subviews] objectAtIndex:(dividerIndex + 1)];
    NSRect growingSubviewFrame = growingSubview.frame;
    NSRect shrinkingSubviewFrame = shrinkingSubview.frame;
    CGFloat shrinkingSize;
    CGFloat currentCoordinate;
    
    if ([splitView isVertical])
    {
        currentCoordinate = growingSubviewFrame.origin.x + growingSubviewFrame.size.width;
        shrinkingSize = shrinkingSubviewFrame.size.width;
    }
    else
    {
        currentCoordinate = growingSubviewFrame.origin.y + growingSubviewFrame.size.height;
        shrinkingSize = shrinkingSubviewFrame.size.height;
    }
    
    CGFloat minimumSize = [[_minLengthsByViewIndex objectForKey:[NSNumber numberWithInteger:(dividerIndex + 1)]] doubleValue];
    
    return currentCoordinate + (shrinkingSize - minimumSize);
}

/**
 * Given a proposed position for one of the dividers of a split view,
 * return a position at which the divider should be placed as the user drags it.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * the split view behaves as if it has a delegate that responds to this message by merely returning the proposed position.
 * If a split view has a delegate, and the delegate responds to this message,
 * it will be sent repeatedly as the user drags one of the split view's dividers.
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return 0.0;
}

/**
 * Given that a split view has been resized but has not yet adjusted its subviews to accomodate the new size,
 * and given the former size of the split view, adjust the subviews to accomodate the new size of the split view.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * the split view behaves as if it has a delegate that responds to this message by merely sending the split view an -adjustSubviews message.
 * Delegates that respond to this message should adjust the frames of the uncollapsed subviews
 * so that they exactly fill the split view with room for dividers in between, taking its new size into consideration.
 * The thickness of dividers can be determined by sending the split view a -dividerThickness message.
 */
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [self adjustSubviews:oldSize];
}

/**
 * Given that a split view has been resized and is adjusting its subviews to accomodate the new size,
 * return YES if -adjustSubviews can change the size of the indexed subview, NO otherwise.
 * -adjustSubviews may change the origin of the indexed subview regardless of what this method returns.
 * -adjustSubviews may also resize otherwise nonresizable subviews to prevent an invalid subview layout.
 * If a split view has no delegate, or if its delegate does not respond to this message, the split view behaves as if it has a delegate that returns YES when sent this message.
 */
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    return NO;
}

/**
 * Given that a split view has been resized and is adjusting its subviews to accomodate the new size,
 * or that the user is dragging a divider,
 * return YES to allow the divider to be dragged or adjusted off the edge of the split view where it will not be visible.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * the split view behaves as if it has a delegate that returns NO when sent this message.
 */
- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return NO;
}

/**
 * Given the drawn frame of a divider (in the coordinate system established by the split view's bounds),
 * return the frame in which mouse clicks should initiate divider dragging.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * the split view behaves as if it has a delegate that returns proposedEffectiveRect when sent this message.
 * A split view with thick dividers proposes the drawn frame as the effective frame.
 * A split view with thin dividers proposes an effective frame that's a litte larger than the drawn frame,
 * to make it easier for the user to actually grab the divider.
 */
- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    // NSZeroRect: Remove the dragable area so the subview is not resizable
    return (self.resizesByDivider ? proposedEffectiveRect : NSZeroRect);
}

/**
 * Given a divider index, return an additional rectangular area (in the coordinate system established by the split view's bounds)
 * in which mouse clicks should also initiate divider dragging, or NSZeroRect to not add one.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * only mouse clicks within the effective frame of a divider initiate divider dragging.
 */
- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    return NSZeroRect;
}

/**
 * Respond as if the delegate had registered for the NSSplitViewWillResizeSubviewsNotification notification.
 * A split view's behavior is not explicitly affected by a delegate's ability or inability to respond to these messages,
 * though the delegate may send messages to the split view in response to these messages.
 */
- (void)splitViewWillResizeSubviews:(NSNotification *)notification
{
}

/**
 * Respond as if the delegate had registered for the NSSplitViewDidResizeSubviewsNotification notification.
 * A split view's behavior is not explicitly affected by a delegate's ability or inability to respond to these messages,
 * though the delegate may send messages to the split view in response to these messages.
 */
- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
}

@end
