//
//  NSView+Extensions.m
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "NSView+Extensions.h"

#import "AbstractViewProtocols.h"

@implementation NSView (Extensions)

#ifdef __MAC_10_14
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_14
+ (void)load
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewDidChangeEffectiveAppearance);
        SEL swizzledSelector = @selector(_viewDidChangeEffectiveAppearance);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL isMethodAdded = class_addMethod(class,
                                             originalSelector,
                                             method_getImplementation(swizzledMethod),
                                             method_getTypeEncoding(swizzledMethod));
        
        if (isMethodAdded)
        {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)_viewDidChangeEffectiveAppearance
{
    [self _viewDidChangeEffectiveAppearance];
    
    if ([(id<AbstractViewProtocols>)self respondsToSelector:@selector(refreshUIAppearance)])
    {
        [(id<AbstractViewProtocols>)self refreshUIAppearance];
    }
    else
    {
        NSResponder *responder = [self nextResponder];
        
        if ([(id<AbstractViewProtocols>)responder respondsToSelector:@selector(refreshUIAppearance)])
        {
            [(id<AbstractViewProtocols>)responder refreshUIAppearance];
        }
    }
}
#endif
#endif

- (void)changeEffectiveAppearance
{
    if ([(id<AbstractViewProtocols>)self respondsToSelector:@selector(refreshUIAppearance)])
    {
        [(id<AbstractViewProtocols>)self refreshUIAppearance];
    }
    else
    {
        NSResponder *responder = [self nextResponder];
        
        if ([(id<AbstractViewProtocols>)responder respondsToSelector:@selector(refreshUIAppearance)])
        {
            [(id<AbstractViewProtocols>)responder refreshUIAppearance];
        }
    }
    
    NSArray<NSView *> *subviews = [self subviews];
    
    for (NSView *view in subviews)
    {
        [view changeEffectiveAppearance];
    }
}

- (BOOL)containsView:(NSView *)child {
    return [[self class] views:[self subviews] contain:child];
}

- (BOOL)containsPosition:(NSPoint)position {
    NSView *view = self;
    NSRect relativeRect = [view convertRect:[view alignmentRectForFrame:[view bounds]] toView:nil];
    NSRect viewRect = [view.window convertRectToScreen:relativeRect];
    
    if (NSPointInRect(position, viewRect)) {
        return YES;
    } else {
        NSArray<NSView *> *subviews = [view subviews];
        
        for (NSView *item in subviews) {
            if ([item containsPosition:position]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSVisualEffectView *)containsVisualEffect {
    NSArray<NSView *> *subviews = [self subviews];
    
    for (NSView *view in subviews) {
        if ([view isKindOfClass:[NSVisualEffectView class]]) {
            return (NSVisualEffectView *)view;
        }
    }
    
    return nil;
}

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)constraintAttribute {
    NSView *parentView = [self superview];
    NSArray<NSLayoutConstraint *> *constraints = [parentView constraints];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self) || (constraint.secondItem == self)) {
            if ((constraint.firstAttribute == constraintAttribute) || (constraint.secondAttribute == constraintAttribute)) {
                return constraint;
            }
        }
    }
    
    constraints = [self constraints];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self) || (constraint.secondItem == nil)) {
            if (constraint.firstAttribute == constraintAttribute) {
                return constraint;
            }
        }
    }
    
    return nil;
}

- (void)removeAttribute:(NSLayoutAttribute)constraintAttribute {
    NSMutableArray *removedConstraints = [NSMutableArray array];
    NSView *parentView = [self superview];
    NSArray<NSLayoutConstraint *> *constraints = [parentView constraints];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self) || (constraint.secondItem == self)) {
            if ((constraint.firstAttribute == constraintAttribute) || (constraint.secondAttribute == constraintAttribute)) {
                [removedConstraints addObject:constraint];
            }
        }
    }
    
    for (NSLayoutConstraint *constraint in removedConstraints) {
        [constraint setActive:NO];
        [parentView removeConstraint:constraint];
    }
    
    [removedConstraints removeAllObjects];
    constraints = [self constraints];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self) || (constraint.secondItem == nil)) {
            if (constraint.firstAttribute == constraintAttribute) {
                [removedConstraints addObject:constraint];
            }
        }
    }
    
    for (NSLayoutConstraint *constraint in removedConstraints) {
        [constraint setActive:NO];
        [self removeConstraint:constraint];
    }
}

- (void)setSizeConstraints:(NSRect)withFrame {
    CGFloat width = NSWidth(withFrame);
    CGFloat height = NSHeight(withFrame);
    NSLayoutConstraint *widthConstraint = [self constraintForAttribute:NSLayoutAttributeWidth];
    NSLayoutConstraint *heightConstraint = [self constraintForAttribute:NSLayoutAttributeHeight];
    
    if (widthConstraint == nil) {
        widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1
                                                        constant:width];
        
        [self addConstraint:widthConstraint];
    } else {
        widthConstraint.constant = width;
    }
    
    if (heightConstraint == nil) {
        heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1
                                                         constant:height];
        
        [self addConstraint:heightConstraint];
    } else {
        heightConstraint.constant = height;
    }
    
    [widthConstraint setActive:YES];
    [heightConstraint setActive:YES];
}

- (void)removeSizeConstraints {
    NSLayoutConstraint *widthConstraint = [self constraintForAttribute:NSLayoutAttributeWidth];
    NSLayoutConstraint *heightConstraint = [self constraintForAttribute:NSLayoutAttributeHeight];
    
    [widthConstraint setActive:NO];
    [heightConstraint setActive:NO];
    [self removeConstraint:widthConstraint];
    [self removeConstraint:heightConstraint];
}

- (void)removeConstraints {
    NSMutableArray *removedConstraints = [NSMutableArray array];
    NSView *parentView = [self superview];
    NSArray<NSLayoutConstraint *> *constraints = [parentView constraints];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self) || (constraint.secondItem == self)) {
            if ((constraint.firstAttribute == NSLayoutAttributeTop) || (constraint.secondAttribute == NSLayoutAttributeTop) ||
                (constraint.firstAttribute == NSLayoutAttributeLeading) || (constraint.secondAttribute == NSLayoutAttributeLeading) ||
                (constraint.firstAttribute == NSLayoutAttributeBottom) || (constraint.secondAttribute == NSLayoutAttributeBottom) ||
                (constraint.firstAttribute == NSLayoutAttributeTrailing) || (constraint.secondAttribute == NSLayoutAttributeTrailing)) {
                [removedConstraints addObject:constraint];
            }
        }
    }
    
    for (NSLayoutConstraint *constraint in removedConstraints) {
        [constraint setActive:NO];
        [parentView removeConstraint:constraint];
    }
    
    [removedConstraints removeAllObjects];
    constraints = [self constraints];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ((constraint.firstItem == self) && (constraint.secondItem == nil)) {
            if ((constraint.firstAttribute == NSLayoutAttributeWidth) || (constraint.firstAttribute == NSLayoutAttributeHeight)) {
                [removedConstraints addObject:constraint];
            }
        }
    }
    
    for (NSLayoutConstraint *constraint in removedConstraints) {
        [constraint setActive:NO];
        [self removeConstraint:constraint];
    }
}

- (void)addAutoResize:(BOOL)isAutoResize toParent:(NSView *)parentView {
    [self addAutoResize:isAutoResize toParent:parentView contentInsets:NSEdgeInsetsZero];
}

- (void)addAutoResize:(BOOL)isAutoResize toParent:(NSView *)parentView contentInsets:(NSEdgeInsets)contentInsets {
    NSView *view = self;
    
    if (![view isKindOfClass:[NSView class]] || ![parentView isKindOfClass:[NSView class]]) return;
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
    }
    
    if (isAutoResize && [view isDescendantOf:parentView]) {
        NSDictionary *metrics = @{@"top":@(contentInsets.top), @"leading":@(contentInsets.left), @"bottom":@(contentInsets.bottom), @"trailing":@(contentInsets.right)};
        
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leading)-[view]-(trailing)-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:metrics
                                                                             views:NSDictionaryOfVariableBindings(view)]];
        
        [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[view]-(bottom)-|"
                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
                                                                           metrics:metrics
                                                                             views:NSDictionaryOfVariableBindings(view)]];
    }
}

- (void)addCenterAutoResize:(BOOL)isCenterAutoResize toParent:(NSView *)parentView {
    NSView *view = self;
    
    if (![view isKindOfClass:[NSView class]] || ![parentView isKindOfClass:[NSView class]]) return;
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
    }
    
    if (isCenterAutoResize && [view isDescendantOf:parentView]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:parentView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:0
                                                                  toItem:view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
        
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:parentView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:0
                                                                  toItem:view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0]];
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:view
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:NSWidth(view.frame)];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:NSHeight(view.frame)];
        
        [width setActive:YES];
        [height setActive:YES];
        
        [view addConstraints:@[width, height]];
    }
}

- (void)updateConstraintsWithInsets:(NSEdgeInsets)contentInsets {
    NSLayoutConstraint *topConstraint = [self constraintForAttribute:NSLayoutAttributeTop];
    NSLayoutConstraint *leadingConstraint = [self constraintForAttribute:NSLayoutAttributeLeading];
    NSLayoutConstraint *bottomConstraint = [self constraintForAttribute:NSLayoutAttributeBottom];
    NSLayoutConstraint *trailingConstraint = [self constraintForAttribute:NSLayoutAttributeTrailing];
    
    topConstraint.constant = contentInsets.top;
    leadingConstraint.constant = contentInsets.left;
    bottomConstraint.constant = contentInsets.bottom;
    trailingConstraint.constant = contentInsets.right;
}

- (NSEdgeInsets)contentInsetsWithFrame:(NSRect)frame {
    NSView *view = self;
    NSView *parentView = [view superview];
    
    if (![view isKindOfClass:[NSView class]] || ![parentView isKindOfClass:[NSView class]]) return NSEdgeInsetsZero;
    
    NSEdgeInsets edgeInsets = NSEdgeInsetsZero;
    
    if ([view isDescendantOf:parentView]) {
        NSRect viewFrame = frame;
        NSRect parentFrame = [parentView bounds];
        CGFloat top = NSMaxY(parentFrame) - NSMaxY(viewFrame);
        CGFloat left = NSMinX(viewFrame) - NSMinX(parentFrame);
        CGFloat bottom = NSMinY(viewFrame) - NSMinY(parentFrame);
        CGFloat right = NSMaxX(parentFrame) - NSMaxX(viewFrame);
        
        edgeInsets = NSEdgeInsetsMake(top, left, bottom, right);
    }
    
    return edgeInsets;
}

#pragma mark - Class methods

+ (BOOL)views:(NSArray *)views contain:(NSView *)view {
    if ([views containsObject:view]) {
        return YES;
    } else {
        for (NSView *item in views) {
            if ([[self class] views:[item subviews] contain:view]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
