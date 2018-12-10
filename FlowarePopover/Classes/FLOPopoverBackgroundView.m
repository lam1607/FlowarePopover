//
//  FLOPopoverBackgroundView.m
//  FlowarePopover
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverBackgroundView.h"

#import "FLOPopoverUtils.h"

static CGFloat getMedianXFromRects(NSRect r1, NSRect r2) {
    CGFloat minX = fmax(NSMinX(r1), NSMinX(r2));
    CGFloat maxX = fmin(NSMaxX(r1), NSMaxX(r2));
    
    return (minX + maxX) / 2;
}

// Returns the median X value of the shared segment of the X edges of the given rects
static CGFloat getMedianYFromRects(NSRect r1, NSRect r2) {
    CGFloat minY = fmax(NSMinY(r1), NSMinY(r2));
    CGFloat maxY = fmin(NSMaxY(r1), NSMaxY(r2));
    
    return (minY + maxY) / 2;
}

#pragma mark - FLOPopoverClippingView

@implementation FLOPopoverClippingView
- (void)dealloc {
    self.clippingPath = NULL;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return nil;
}

- (void)setClippingPath:(CGPathRef)clippingPath {
    if (clippingPath == _clippingPath) return;
    
    CGPathRelease(_clippingPath);
    _clippingPath = clippingPath;
    CGPathRetain(_clippingPath);
    
    // @TODO: This line crashes on macOS 10.14
    //    self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.clippingPath == NULL) return;
    
    [self setupArrowPath];
}

- (void)setupArrowPath {
    CGContextRef currentContext = NSGraphicsContext.currentContext.CGContext;
    
    if (currentContext != nil) {
        self.pathColor = ((self.pathColor != nil) && (self.pathColor != [NSColor.clearColor CGColor])) ? self.pathColor : [NSColor.lightGrayColor CGColor];
        
        CGContextAddPath(currentContext, self.clippingPath);
        CGContextSetBlendMode(currentContext, kCGBlendModeCopy);
        CGContextSetFillColorWithColor(currentContext, self.pathColor);
        CGContextEOFillPath(currentContext);
    }
}

- (void)setupArrowPathColor:(CGColorRef)color {
    if (color != nil) {
        self.pathColor = color;
        self.needsDisplay = YES;
    }
}

@end

#pragma mark - FLOPopoverBackgroundView

@interface FLOPopoverBackgroundView ()

// The clipping view that's used to shape the popover to the correct path. This
// property is prefixed because it's private and this class is meant to be
// subclassed.
@property (nonatomic, strong, readonly) FLOPopoverClippingView *clippingView;
@property (nonatomic, assign, readwrite) NSRectEdge popoverEdge;
@property (nonatomic, assign, readwrite) NSRect popoverOrigin;

@property (nonatomic, assign) BOOL isMovable;
@property (nonatomic, assign) BOOL isDetachable;

@property (nonatomic, assign) NSPoint originalMouseOffset;
@property (nonatomic, assign) BOOL dragging;

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation FLOPopoverBackgroundView

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        _arrowSize = NSZeroSize;
        _fillColor = NSColor.clearColor;
        
        _clippingView = [[FLOPopoverClippingView alloc] initWithFrame:self.bounds];
        
        _clippingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        _clippingView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [self addSubview:_clippingView];
    }
    
    return self;
}

- (void)dealloc {
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    [self.fillColor set];
    NSRectFill(rect);
}

- (void)viewWillDraw {
    [super viewWillDraw];
    [self updateClippingView];
}

#pragma mark - Getter/Setter

- (void)setFillColor:(NSColor *)fillColor {
    _fillColor = fillColor;
    [self.fillColor set];
}

- (void)setBorderRadius:(CGFloat)borderRadius {
    self.wantsLayer = YES;
    self.layer.cornerRadius = borderRadius;
}

#pragma mark - Others

- (NSRectEdge)arrowEdgeForPopoverEdge:(NSRectEdge)popoverEdge {
    NSRectEdge arrowEdge = NSRectEdgeMinY;
    switch (popoverEdge) {
        case NSRectEdgeMaxX:
            arrowEdge = NSRectEdgeMinX;
            break;
        case NSRectEdgeMaxY:
            arrowEdge = NSRectEdgeMinY;
            break;
        case NSRectEdgeMinX:
            arrowEdge = NSRectEdgeMaxX;
            break;
        case NSRectEdgeMinY:
            arrowEdge = NSRectEdgeMaxY;
            break;
        default:
            break;
    }
    
    return arrowEdge;
}

- (void)updateClippingView {
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        CGPathRef clippingPath = [self newPopoverPathForEdge:self.popoverEdge inFrame:self.clippingView.bounds];
        self.clippingView.clippingPath = clippingPath;
        CGPathRelease(clippingPath);
    }
}

#pragma mark - Processes

- (void)setMovable:(BOOL)movable {
    self.isMovable = movable;
}

- (void)setDetachable:(BOOL)detachable {
    self.isDetachable = detachable;
}

- (void)setShouldShowShadow:(BOOL)needed {
    if (needed) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [NSColor.shadowColor CGColor];
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
        self.layer.shadowRadius = 5.0;
    }
}

- (void)setShouldShowArrow:(BOOL)needed {
    self.arrowSize = needed ? CGSizeMake(PopoverBackgroundViewArrowWidth, PopoverBackgroundViewArrowHeight) : NSZeroSize;
    
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        [self updateClippingView];
    }
}

- (void)setArrowColor:(CGColorRef)color {
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        [self.clippingView setupArrowPathColor:color];
    }
}

- (BOOL)isOpaque {
    return NO;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    self.needsDisplay = YES;
}

- (void)setArrowSize:(CGSize)arrowSize {
    if (CGSizeEqualToSize(arrowSize, self.arrowSize)) return;
    
    _arrowSize = arrowSize;
    self.needsDisplay = YES;
}

- (void)setPopoverEdge:(NSRectEdge)popoverEdge {
    if (popoverEdge == self.popoverEdge) return;
    
    _popoverEdge = popoverEdge;
    self.needsDisplay = YES;
}

- (void)setPopoverOrigin:(NSRect)popoverOrigin {
    if (NSEqualRects(popoverOrigin, self.popoverOrigin)) return;
    
    _popoverOrigin = popoverOrigin;
    self.needsDisplay = YES;
}

- (NSSize)sizeForBackgroundViewWithContentSize:(NSSize)contentSize popoverEdge:(NSRectEdge)popoverEdge {
    NSSize returnSize = contentSize;
    
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        if (popoverEdge == NSRectEdgeMaxX || popoverEdge == NSRectEdgeMinX) {
            returnSize.width += self.arrowSize.height;
        } else {
            returnSize.height += self.arrowSize.height;
        }
    }
    
    return returnSize;
}

- (NSSize)contentViewSizeForSize:(NSSize)size {
    NSSize returnSize = size;
    
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        if ((self.popoverEdge == NSRectEdgeMinX) || (self.popoverEdge == NSRectEdgeMaxX)) {
            returnSize.width -= self.arrowSize.height;
        } else {
            returnSize.height -= self.arrowSize.height;
        }
    }
    
    return returnSize;
}

- (NSRect)contentViewFrameForBackgroundFrame:(NSRect)backgroundFrame popoverEdge:(NSRectEdge)popoverEdge {
    NSRect returnFrame = NSInsetRect(backgroundFrame, 0.0, 0.0);
    
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        switch (popoverEdge) {
            case NSRectEdgeMinX:
                returnFrame.size.width -= self.arrowSize.height;
                break;
            case NSRectEdgeMinY:
                returnFrame.size.height -= self.arrowSize.height;
                break;
            case NSRectEdgeMaxX:
                returnFrame.size.width -= self.arrowSize.height;
                returnFrame.origin.x += self.arrowSize.height;
                break;
            case NSRectEdgeMaxY:
                returnFrame.size.height -= self.arrowSize.height;
                returnFrame.origin.y += self.arrowSize.height;
                break;
            default:
                NSAssert(NO, @"Failed to pass in a valid NSRectEdge");
                break;
        }
    }
    
    return returnFrame;
}

- (CGPathRef)newPopoverPathForEdge:(NSRectEdge)popoverEdge inFrame:(NSRect)frame {
    NSRectEdge arrowEdge = [self arrowEdgeForPopoverEdge:popoverEdge];
    
    NSRect contentRect = NSIntegralRect([self contentViewFrameForBackgroundFrame:frame popoverEdge:self.popoverEdge]);
    CGFloat minX = NSMinX(contentRect);
    CGFloat maxX = NSMaxX(contentRect);
    CGFloat minY = NSMinY(contentRect);
    CGFloat maxY = NSMaxY(contentRect);
    
    NSWindow *window = (self.window != nil) ? self.window : [[FLOPopoverUtils sharedInstance] appMainWindow];
    NSRect windowRect = [window convertRectFromScreen:self.popoverOrigin];
    NSRect originRect = [self convertRect:windowRect fromView:nil];
    CGFloat midOriginX = floor(getMedianXFromRects(originRect, contentRect));
    CGFloat midOriginY = floor(getMedianYFromRects(originRect, contentRect));
    
    CGFloat maxArrowX = 0.0;
    CGFloat minArrowX = 0.0;
    CGFloat minArrowY = 0.0;
    CGFloat maxArrowY = 0.0;
    
    // Even I have no idea at this point… :trollface:
    // So we don't have a weird arrow situation we need to make sure we draw it within the radius.
    // If we have to nudge it then we have to shrink the arrow as otherwise it looks all wonky and weird.
    // That is what this complete mess below does.
    if (arrowEdge == NSRectEdgeMinY || arrowEdge == NSRectEdgeMaxY) {
        maxArrowX = floor(midOriginX + (self.arrowSize.width / 2.0));
        CGFloat maxPossible = (NSMaxX(contentRect) - PopoverBackgroundViewBorderRadius);
        
        if (maxArrowX > maxPossible) {
            maxArrowX = maxPossible;
            minArrowX = maxArrowX - self.arrowSize.width;
        } else {
            minArrowX = floor(midOriginX - (self.arrowSize.width / 2.0));
            
            if (minArrowX < PopoverBackgroundViewBorderRadius) {
                minArrowX = PopoverBackgroundViewBorderRadius;
                maxArrowX = minArrowX + self.arrowSize.width;
            }
        }
    } else {
        minArrowY = floor(midOriginY - (self.arrowSize.width / 2.0));
        
        if (minArrowY < PopoverBackgroundViewBorderRadius) {
            minArrowY = PopoverBackgroundViewBorderRadius;
            maxArrowY = minArrowY + self.arrowSize.width;
        } else {
            maxArrowY = floor(midOriginY + (self.arrowSize.width / 2.0));
            CGFloat maxPossible = (NSMaxY(contentRect) - PopoverBackgroundViewBorderRadius);
            
            if (maxArrowY > maxPossible) {
                maxArrowY = maxPossible;
                minArrowY = maxArrowY - self.arrowSize.width;
            }
        }
    }
    
    // These represent the centerpoints of the popover's corner arcs.
    CGFloat minCenterpointX = floor(minX + PopoverBackgroundViewBorderRadius);
    CGFloat maxCenterpointX = floor(maxX - PopoverBackgroundViewBorderRadius);
    CGFloat minCenterpointY = floor(minY + PopoverBackgroundViewBorderRadius);
    CGFloat maxCenterpointY = floor(maxY - PopoverBackgroundViewBorderRadius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX, minCenterpointY);
    
    CGFloat radius = PopoverBackgroundViewBorderRadius;
    
    CGPathAddArc(path, NULL, minCenterpointX, maxCenterpointY, radius, M_PI, M_PI_2, true);
    CGPathAddArc(path, NULL, maxCenterpointX, maxCenterpointY, radius, M_PI_2, 0, true);
    CGPathAddArc(path, NULL, maxCenterpointX, minCenterpointY, radius, 0, -M_PI_2, true);
    CGPathAddArc(path, NULL, minCenterpointX, minCenterpointY, radius, -M_PI_2, M_PI, true);
    
    CGPoint minBasePoint, tipPoint, maxBasePoint;
    switch (arrowEdge) {
        case NSRectEdgeMinX:
            minBasePoint = NSMakePoint(minX, minArrowY);
            tipPoint = NSMakePoint(floor(minX - self.arrowSize.height), floor((minArrowY + maxArrowY) / 2));
            maxBasePoint = NSMakePoint(minX, maxArrowY);
            break;
        case NSRectEdgeMaxY:
            minBasePoint = NSMakePoint(minArrowX, maxY);
            tipPoint = NSMakePoint(floor((minArrowX + maxArrowX) / 2), floor(maxY + self.arrowSize.height));
            maxBasePoint = NSMakePoint(maxArrowX, maxY);
            break;
        case NSRectEdgeMaxX:
            minBasePoint = NSMakePoint(maxX, minArrowY);
            tipPoint = NSMakePoint(floor(maxX + self.arrowSize.height), floor((minArrowY + maxArrowY) / 2));
            maxBasePoint = NSMakePoint(maxX, maxArrowY);
            break;
        case NSRectEdgeMinY:
            minBasePoint = NSMakePoint(minArrowX, minY);
            tipPoint = NSMakePoint(floor((minArrowX + maxArrowX) / 2), floor(minY - self.arrowSize.height));
            maxBasePoint = NSMakePoint(maxArrowX, minY);
            break;
        default:
            break;
    }
    
    CGPathMoveToPoint(path, NULL, minBasePoint.x, minBasePoint.y);
    CGPathAddLineToPoint(path, NULL, tipPoint.x, tipPoint.y);
    CGPathAddLineToPoint(path, NULL, maxBasePoint.x, maxBasePoint.y);
    
    return path;
}

#pragma mark - Mouse events

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (self.makeKeyWindowOnMouseEvents && [self.window isKindOfClass:[FLOPopoverWindow class]]) {
        if (self.trackingArea != nil) {
            [self removeTrackingArea:self.trackingArea];
            self.trackingArea = nil;
        }
        
        NSInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
        self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
        [self addTrackingArea:self.trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    if (self.makeKeyWindowOnMouseEvents && [self.window isKindOfClass:[FLOPopoverWindow class]]) {
        if ([self isDescendantOf:event.window.contentView] && ([event.window isKeyWindow] == NO)) {
            [event.window makeKeyAndOrderFront:nil];
        }
    }
}

- (void)mouseExited:(NSEvent *)event {
    if (self.makeKeyWindowOnMouseEvents && [self.window isKindOfClass:[FLOPopoverWindow class]]) {
        if ([self isDescendantOf:event.window.contentView] && [event.window isKeyWindow]) {
            [event.window resignKeyWindow];
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    BOOL isFLOPopoverWindow = [event.window isKindOfClass:[FLOPopoverWindow class]];
    self.originalMouseOffset = isFLOPopoverWindow ? event.locationInWindow : [self convertPoint:event.locationInWindow fromView:self.window.contentView];
    self.dragging = NO;
}

- (void)mouseDragged:(NSEvent *)event {
    self.dragging = YES;
    
    if (self.isMovable || self.isDetachable) {
        if (self.dragging) {
            if ([self.delegate respondsToSelector:@selector(didPopoverMakeMovement)]) {
                [self.delegate didPopoverMakeMovement];
            }
            
            BOOL isFLOPopoverWindow = [event.window isKindOfClass:[FLOPopoverWindow class]];
            
            NSPoint currentMouseOffset = isFLOPopoverWindow ? event.locationInWindow : [self convertPoint:event.locationInWindow fromView:event.window.contentView];
            NSPoint difference = NSMakePoint(currentMouseOffset.x - self.originalMouseOffset.x, currentMouseOffset.y - self.originalMouseOffset.y);
            NSPoint currentOrigin = isFLOPopoverWindow ? event.window.frame.origin : self.frame.origin;
            NSPoint nextOrigin = NSMakePoint(currentOrigin.x + difference.x, currentOrigin.y + difference.y);
            
            if (isFLOPopoverWindow) {
                [event.window setFrameOrigin:nextOrigin];
            } else {
                [self setFrameOrigin:nextOrigin];
            }
        }
    }
}

- (void)mouseUp:(NSEvent *)event {
    if (self.dragging) {
        if (self.isDetachable) {
            self.isDetachable = NO;
            self.isMovable = NO;
            
            if ([self.delegate respondsToSelector:@selector(didPopoverBecomeDetachable:)]) {
                [self.delegate didPopoverBecomeDetachable:event.window];
            }
        }
        
        self.dragging = NO;
    }
}

@end
