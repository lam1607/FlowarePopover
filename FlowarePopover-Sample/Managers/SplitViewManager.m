//
//  SplitViewManager.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/28/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import "SplitViewManager.h"

#pragma mark -

@protocol SplitViewProtocols <NSObject>

@optional
- (void)splitView:(NSSplitView *_Nonnull)splitView willRemoveSubview:(NSView *_Nonnull)subview;

@end

@interface CustomNSSplitView ()

@end

@implementation CustomNSSplitView

- (void)willRemoveSubview:(NSView *)subview
{
    id<SplitViewProtocols> protocols = (id<SplitViewProtocols>)self.delegate;
    
    if (protocols && [protocols respondsToSelector:@selector(splitView:willRemoveSubview:)])
    {
        [protocols splitView:self willRemoveSubview:subview];
    }
}

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

@interface SplitViewManager () <NSSplitViewDelegate, SplitViewProtocols>
{
    __weak NSSplitView *_splitView;
    __weak id<SplitViewManagerProtocols> _protocols;
    
    BOOL _resizesProportionally;
    BOOL _resizesByDivider;
    CGFloat _interSpacing;
    
    NSMutableDictionary *_minLengthsByView, *_lengthsByView, *_proportionalLengthsByView;
    NSMutableArray<NSView *> *_subviews, *_willRemoveSubviews;
}

@end

@implementation SplitViewManager

#pragma mark - Initialize

- (instancetype _Nullable)initWithSplitView:(NSSplitView * _Nonnull)splitView source:(id<SplitViewManagerProtocols>_Nonnull)source
{
    return [self initWithSplitView:splitView splitType:SplitViewArrangeTypeLeftToRight source:source];
}

- (instancetype _Nullable)initWithSplitView:(NSSplitView * _Nonnull)splitView splitType:(SplitViewArrangeType)splitType source:(id<SplitViewManagerProtocols>_Nonnull)source
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
            [_splitView setArrangesAllSubviews:YES];
            _protocols = source;
            _subviews = [[NSMutableArray alloc] init];
            _willRemoveSubviews = [[NSMutableArray alloc] init];
            
            [self setInterSpacing:_interSpacing];
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
    
    [self resetMinLengthsByView];
    [self resetLengthsByView];
    [self resetProportionalLengthsByView];
    [self resetSubviews];
    [self resetWillRemoveSubviews];
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

- (BOOL)resizesByDivider
{
    return _resizesByDivider;
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

- (BOOL)isVertical
{
    return (self.splitType == SplitViewArrangeTypeLeftToRight);
}

- (CGFloat)subviewsMinimumLength
{
    CGFloat interspacing = self.interSpacing;
    __block CGFloat length = SHRT_MIN;
    
    @synchronized (_minLengthsByView)
    {
        NSInteger size = _minLengthsByView.count;
        
        if (size > 0)
        {
            length = 0.0;
            
            [_minLengthsByView enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    length += [obj doubleValue];
                }
            }];
            
            length += interspacing * (size - 1);
        }
    }
    
    return length;
}

- (CGFloat)subviewsLength
{
    CGFloat interspacing = self.interSpacing;
    __block CGFloat length = SHRT_MIN;
    
    @synchronized (_lengthsByView)
    {
        NSInteger size = _lengthsByView.count;
        
        if (size > 0)
        {
            length = 0.0;
            
            [_lengthsByView enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNumber class]])
                {
                    length += (([obj doubleValue] != SplitSubviewNormaLengthTypeWide) ? [obj doubleValue] : [[_minLengthsByView objectForKey:key] doubleValue]);
                }
            }];
            
            length += interspacing * (size - 1);
        }
    }
    
    return length;
}

#pragma mark - Local methods

- (void)resetMinLengthsByView
{
    [_minLengthsByView removeAllObjects];
    _minLengthsByView = nil;
}

- (void)resetLengthsByView
{
    [_lengthsByView removeAllObjects];
    _lengthsByView = nil;
}

- (void)resetProportionalLengthsByView
{
    [_proportionalLengthsByView removeAllObjects];
    _proportionalLengthsByView = nil;
}

- (void)resetSubviews
{
    [_subviews removeAllObjects];
    _subviews = nil;
}

- (void)resetWillRemoveSubviews
{
    [_willRemoveSubviews removeAllObjects];
    _willRemoveSubviews = nil;
}

- (void)removeMinimumLengthForView:(NSView *)view
{
    @synchronized (_minLengthsByView)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:view];
        
        [_minLengthsByView removeObjectForKey:key];
    }
}

- (void)removeLengthForView:(NSView *)view
{
    @synchronized (_lengthsByView)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:view];
        
        [_lengthsByView removeObjectForKey:key];
    }
}

- (void)removeProportionalLengthForView:(NSView *)view
{
    @synchronized (_proportionalLengthsByView)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:view];
        
        [_proportionalLengthsByView removeObjectForKey:key];
    }
}

- (void)handleResizeSubviewsLengthsWithOldSize:(NSSize)oldSize
{
    if (_lengthsByView.count > 0)
    {
        NSSplitView *splitView = self.splitView;
        CGFloat interspacing = self.interSpacing;
        NSMutableDictionary *minLengthsByView = _minLengthsByView;
        NSMutableDictionary *lengthsByView = _lengthsByView;
        NSArray *subviews = [splitView subviews];
        NSInteger subviewsCount = [subviews count];
        BOOL isVertical = [splitView isVertical];
        NSRect splitViewBounds = [splitView bounds];
        NSArray *narrows = [[lengthsByView allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %ld", SplitSubviewNormaLengthTypeWide]];
        CGFloat totalWideLengths = NSWidth(splitViewBounds) - [[narrows valueForKeyPath:@"@sum.self"] doubleValue] - (subviewsCount - 1) * interspacing;
        NSInteger totalTypeWides = [[lengthsByView allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self = %ld", SplitSubviewNormaLengthTypeWide]].count;
        CGFloat delta = ([splitView isVertical] ? (NSWidth(splitViewBounds) - oldSize.width) : (NSHeight(splitViewBounds) - oldSize.height)) / ((totalTypeWides > 0) ? totalTypeWides : 1);
        
        for (NSView *view in subviews)
        {
            NSValue *key = [NSValue valueWithNonretainedObject:view];
            NSSize frameSize = [view frame].size;
            NSNumber *minLength = [minLengthsByView objectForKey:key];
            CGFloat minLengthValue = [minLength doubleValue];
            NSNumber *length = [lengthsByView objectForKey:key];
            CGFloat lengthValue = [length doubleValue];
            
            if (isVertical)
            {
                if ((delta == 0) && (lengthValue == SplitSubviewNormaLengthTypeWide))
                {
                    delta = (totalWideLengths / ((totalTypeWides > 0) ? totalTypeWides : 1)) - frameSize.width;
                }
                
                frameSize.width = ((lengthValue != SplitSubviewNormaLengthTypeWide) ? lengthValue : ((frameSize.width + delta >= minLengthValue) ? (frameSize.width + delta) : minLengthValue));
                frameSize.height = NSHeight(splitViewBounds);
            }
            else
            {
                if ((delta == 0) && (lengthValue == SplitSubviewNormaLengthTypeWide))
                {
                    delta = (totalWideLengths / ((totalTypeWides > 0) ? totalTypeWides : 1)) - frameSize.height;
                }
                
                frameSize.width = NSWidth(splitViewBounds);
                frameSize.height = ((lengthValue != SplitSubviewNormaLengthTypeWide) ? lengthValue : ((frameSize.height + delta >= minLengthValue) ? (frameSize.height + delta) : minLengthValue));
            }
            
            [view setFrameSize:frameSize];
        }
        
        [self refreshSubviewsFrames];
    }
}

- (void)handleResizeSubviewsProportionalLengthsWithOldSize:(NSSize)oldSize
{
    if (_proportionalLengthsByView.count > 0)
    {
        NSSplitView *splitView = self.splitView;
        CGFloat interspacing = self.interSpacing;
        NSMutableDictionary *minLengthsByView = _minLengthsByView;
        NSMutableDictionary *proportionalLengthsByView = _proportionalLengthsByView;
        NSArray *subviews = [splitView subviews];
        NSInteger subviewsCount = [subviews count];
        BOOL isVertical = [splitView isVertical];
        NSRect splitViewBounds = [splitView bounds];
        CGFloat delta = [splitView isVertical] ? (NSWidth(splitViewBounds) - oldSize.width) : (NSHeight(splitViewBounds) - oldSize.height);
        
        for (NSView *view in subviews)
        {
            NSValue *key = [NSValue valueWithNonretainedObject:view];
            NSSize frameSize = [view frame].size;
            NSNumber *minLength = [minLengthsByView objectForKey:key];
            CGFloat minLengthValue = [minLength doubleValue];
            NSNumber *proportionalLength = [proportionalLengthsByView objectForKey:key];
            CGFloat lengthValue = [proportionalLength doubleValue] * ((isVertical ? NSWidth(splitViewBounds) : NSHeight(splitViewBounds)) - (subviewsCount - 1) * interspacing);
            
            if (isVertical)
            {
                frameSize.width = ((lengthValue != SplitSubviewNormaLengthTypeWide) ? lengthValue : ((frameSize.width + delta >= minLengthValue) ? (frameSize.width + delta) : minLengthValue));
                frameSize.height = NSHeight(splitViewBounds);
            }
            else
            {
                frameSize.width = NSWidth(splitViewBounds);
                frameSize.height = ((lengthValue != SplitSubviewNormaLengthTypeWide) ? lengthValue : ((frameSize.height + delta >= minLengthValue) ? (frameSize.height + delta) : minLengthValue));
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

- (void)setMinimumLength:(CGFloat)minLength forView:(NSView *_Nonnull)view
{
    @synchronized (_minLengthsByView)
    {
        if (minLength > 0.0)
        {
            NSValue *key = [NSValue valueWithNonretainedObject:view];
            
            if (!_minLengthsByView)
            {
                _minLengthsByView = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            
            [_minLengthsByView setObject:[NSNumber numberWithDouble:minLength] forKey:key];
        }
        else
        {
            NSAssert1((minLength > 0.0), @"minLength value must be larger than 0.0. minLength parameter value %f is not valid.", minLength);
        }
    }
}

- (void)setLength:(CGFloat)length forView:(NSView *_Nonnull)view
{
    @synchronized (_lengthsByView)
    {
        if ((length > 0.0) || (length == SplitSubviewNormaLengthTypeWide))
        {
            NSValue *key = [NSValue valueWithNonretainedObject:view];
            
            if (!_lengthsByView)
            {
                _lengthsByView = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            
            [_lengthsByView setObject:[NSNumber numberWithDouble:length] forKey:key];
        }
        else
        {
            NSAssert1((length > 0.0), @"minLength value must be larger than 0.0. minLength parameter value %f is not valid.", length);
        }
    }
}

- (void)setProportionalLength:(CGFloat)proportionalLength forView:(NSView *_Nonnull)view
{
    @synchronized (_proportionalLengthsByView)
    {
        if ((proportionalLength > 0.0) && (proportionalLength <= 1.0))
        {
            NSValue *key = [NSValue valueWithNonretainedObject:view];
            
            if (!_proportionalLengthsByView)
            {
                _proportionalLengthsByView = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            
            [_proportionalLengthsByView setObject:[NSNumber numberWithDouble:proportionalLength] forKey:key];
        }
        else
        {
            NSAssert1(((proportionalLength > 0.0) && (proportionalLength <= 1.0)),
                      @"Proportional length value must stay in range (0, 1]. proportionalLength parameter value %f is not valid.",
                      proportionalLength);
        }
    }
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
        
        if (!resizesProportionally && (_lengthsByView.count > 0))
        {
            [self handleResizeSubviewsLengthsWithOldSize:oldSize];
        }
        else if (resizesProportionally && (_proportionalLengthsByView.count > 0))
        {
            [self handleResizeSubviewsProportionalLengthsWithOldSize:oldSize];
        }
    }
}

/**
 * Adds a view as arranged split pane. If the view is not a subview of the receiver, it will be added as one.
 */
- (BOOL)addArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength length:(CGFloat)length
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if (![_subviews containsObject:view])
        {
            successful = YES;
            [_subviews addObject:view];
            [self setMinimumLength:minLength forView:view];
            [self setLength:length forView:view];
            [self.splitView addArrangedSubview:view];
            [self adjustSubviews];
        }
    }
    
    return successful;
}

/**
 * Adds a view as arranged split pane. If the view is not a subview of the receiver, it will be added as one.
 */
- (BOOL)addArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength proportionalLength:(CGFloat)proportionalLength
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if (![_subviews containsObject:view])
        {
            successful = YES;
            [_subviews addObject:view];
            [self setMinimumLength:minLength forView:view];
            [self setProportionalLength:proportionalLength forView:view];
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
- (BOOL)insertArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength length:(CGFloat)length atIndex:(NSInteger)index
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if (![_subviews containsObject:view])
        {
            @try
            {
                successful = YES;
                [_subviews insertObject:view atIndex:index];
                [self setMinimumLength:minLength forView:view];
                [self setLength:length forView:view];
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
 * Adds a view as an arranged split pane list at the specific index.
 * If the view is already an arranged split view, it will move the view the specified index (but not move the subview index).
 * If the view is not a subview of the receiver, it will be added as one (not necessarily at the same index).
 */
- (BOOL)insertArrangedSubview:(NSView *_Nonnull)view minimumLength:(CGFloat)minLength proportionalLength:(CGFloat)proportionalLength atIndex:(NSInteger)index
{
    BOOL successful = NO;
    
    if ([view isKindOfClass:[NSView class]] && [self.splitView isKindOfClass:[NSSplitView class]])
    {
        if (![_subviews containsObject:view])
        {
            @try
            {
                successful = YES;
                [_subviews insertObject:view atIndex:index];
                [self setMinimumLength:minLength forView:view];
                [self setProportionalLength:proportionalLength forView:view];
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
        if ([_subviews containsObject:view])
        {
            successful = YES;
            [_subviews removeObject:view];
            [self removeMinimumLengthForView:view];
            [self removeLengthForView:view];
            [self removeProportionalLengthForView:view];
            
            if (![_willRemoveSubviews containsObject:view])
            {
                [self.splitView removeArrangedSubview:view];
            }
            
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
    
    CGFloat minimumSize = [[_minLengthsByView objectForKey:[NSNumber numberWithInteger:dividerIndex]] doubleValue];
    
    /// Should keep the minimum size (+ minimumSize) of the view on left side
    /// when dragging the the divider at index to the left direction.
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
    
    CGFloat minimumSize = [[_minLengthsByView objectForKey:[NSNumber numberWithInteger:(dividerIndex + 1)]] doubleValue];
    
    /// Should keep the minimum size (- minimumSize) of the view on right side
    /// when dragging the the divider at index to the right direction.
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
    return floor(proposedPosition);
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
    if (self.resizesByDivider)
    {
        return proposedEffectiveRect;
    }
    
    return NSZeroRect;
}

/**
 * Given a divider index, return an additional rectangular area (in the coordinate system established by the split view's bounds)
 * in which mouse clicks should also initiate divider dragging, or NSZeroRect to not add one.
 * If a split view has no delegate, or if its delegate does not respond to this message,
 * only mouse clicks within the effective frame of a divider initiate divider dragging.
 */
- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    if (self.resizesByDivider)
    {
        CGFloat interspacing = self.interSpacing;
        NSView *subview = [[splitView subviews] objectAtIndex:dividerIndex];
        NSRect subviewFrame = subview.frame;
        NSRect additionalEffectiveRect = NSMakeRect(NSMaxX(subview.frame), NSMinY(subview.frame), interspacing, NSHeight(subviewFrame));
        
        return additionalEffectiveRect;
    }
    
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

#pragma mark - SplitViewProtocols

- (void)splitView:(NSSplitView *_Nonnull)splitView willRemoveSubview:(NSView *_Nonnull)subview
{
    @synchronized (_willRemoveSubviews)
    {
        if (![_willRemoveSubviews containsObject:subview])
        {
            [_willRemoveSubviews addObject:subview];
            [self removeArrangedSubview:subview];
            [_willRemoveSubviews removeObject:subview];
        }
    }
}

@end
