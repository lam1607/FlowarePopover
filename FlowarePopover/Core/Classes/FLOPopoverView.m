//
//  FLOPopoverView.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOPopoverView.h"

#import "FLOPopoverProtocols.h"
#import "FLOPopoverClippingView.h"

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

@interface FLOPopoverView () {
    __weak id<FLOPopoverProtocols> _responder;
    NSTrackingArea *_trackingArea;
    
    BOOL _isMovable;
    BOOL _isDetachable;
    
    NSPoint _originalMouseOffset;
    BOOL _dragging;
    
    BOOL _mouseDownEventReceived;
    BOOL _mouseEnteredEventReceived;
    
    BOOL _shouldShowArrowWithVisualEffect;
}

// The clipping view that's used to shape the popover to the correct path. This
// property is prefixed because it's private and this class is meant to be
// subclassed.
@property (nonatomic, strong, readonly) FLOPopoverClippingView *clippingView;
@property (nonatomic, assign, readwrite) NSRectEdge popoverEdge;
@property (nonatomic, assign, readwrite) NSRect popoverOrigin;

@end

@implementation FLOPopoverView

@synthesize tag = _tag;

- (instancetype)init {
    if (self = [super init]) {
        _tag = -1;
        _arrowSize = NSZeroSize;
        _fillColor = NSColor.clearColor;
        _mouseDownEventReceived = NO;
        _mouseEnteredEventReceived = NO;
        _shouldShowArrowWithVisualEffect = NO;
        _userInteractionEnable = YES;
        _becomesKeyOnMouseOver = NO;
        
        _clippingView = [[FLOPopoverClippingView alloc] initWithFrame:self.bounds];
        
        _clippingView.translatesAutoresizingMaskIntoConstraints = YES;
        _clippingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        [self addSubview:_clippingView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tag = -1;
        _arrowSize = NSZeroSize;
        _fillColor = NSColor.clearColor;
        _mouseDownEventReceived = NO;
        _mouseEnteredEventReceived = NO;
        _shouldShowArrowWithVisualEffect = NO;
        _userInteractionEnable = YES;
        _becomesKeyOnMouseOver = NO;
        
        _clippingView = [[FLOPopoverClippingView alloc] initWithFrame:self.bounds];
        
        _clippingView.translatesAutoresizingMaskIntoConstraints = YES;
        _clippingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        [self addSubview:_clippingView];
    }
    
    return self;
}

- (void)dealloc {
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
        _trackingArea = nil;
    }
}

#pragma mark - Override methods

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

- (void)setArrowSize:(CGSize)arrowSize {
    if (NSEqualSizes(arrowSize, self.arrowSize) && !NSEqualSizes(self.arrowSize, NSZeroSize)) return;
    
    _arrowSize = arrowSize;
}

- (void)setFillColor:(NSColor *)fillColor {
    _fillColor = fillColor;
    [self.fillColor set];
}

- (void)setBorderRadius:(CGFloat)borderRadius {
    _borderRadius = borderRadius;
    
    self.wantsLayer = YES;
    self.layer.cornerRadius = borderRadius;
}

#pragma mark - Local methods

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
    if (!NSEqualSizes(self.arrowSize, NSZeroSize)) {
        CGPathRef clippingPath = [self clippingPathForEdge:self.popoverEdge frame:self.clippingView.bounds];
        self.clippingView.clippingPath = clippingPath;
        CGPathRelease(clippingPath);
    }
}

#pragma mark - FLOPopoverView methods

- (void)setResponder:(id<FLOPopoverProtocols>)responder {
    _responder = responder;
}

- (id<FLOPopoverProtocols>)responder {
    return _responder;
}

- (void)setMovable:(BOOL)movable {
    _isMovable = movable;
}

- (void)setDetachable:(BOOL)detachable {
    _isDetachable = detachable;
}

- (void)setShadow:(BOOL)needed {
    if (needed) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [NSColor.shadowColor CGColor];
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
        self.layer.shadowRadius = 3.0;
    }
}

- (void)setArrow:(BOOL)needed {
    if (needed && !NSEqualSizes(self.arrowSize, NSZeroSize)) {
        self.needsDisplay = YES;
    } else {
        [self.clippingView clearClippingPath];
        [self.clippingView drawClippingPath];
    }
}

- (void)setVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    _shouldShowArrowWithVisualEffect = needed;
    
    if (needed) {
        [self.clippingView setVisualEffectMaterial:material blendingMode:blendingMode state:state];
    }
}

- (void)setArrowColor:(CGColorRef)color {
    if (!NSEqualSizes(self.arrowSize, NSZeroSize) && (color != NULL)) {
        [self.clippingView setPathColor:color];
    }
}

- (BOOL)isOpaque {
    return NO;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
}

- (void)setPopoverEdge:(NSRectEdge)popoverEdge {
    if (popoverEdge == self.popoverEdge) return;
    
    _popoverEdge = popoverEdge;
}

- (void)setPopoverOrigin:(NSRect)popoverOrigin {
    if (NSEqualRects(popoverOrigin, self.popoverOrigin)) return;
    
    _popoverOrigin = popoverOrigin;
}

- (NSSize)sizeForBackgroundViewWithContentSize:(NSSize)contentSize popoverEdge:(NSRectEdge)popoverEdge {
    NSSize returnSize = contentSize;
    
    if (!NSEqualSizes(self.arrowSize, NSZeroSize)) {
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
    
    if (!NSEqualSizes(self.arrowSize, NSZeroSize)) {
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
    
    if (!NSEqualSizes(self.arrowSize, NSZeroSize)) {
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

- (CGPathRef)clippingPathForEdge:(NSRectEdge)popoverEdge frame:(NSRect)frame {
    CGFloat arrowWidth = self.arrowSize.width;
    CGFloat arrowHeight = self.arrowSize.height;
    CGFloat borderRadius = self.borderRadius;
    NSRectEdge arrowEdge = [self arrowEdgeForPopoverEdge:popoverEdge];
    
    NSRect contentRect = NSIntegralRect([self contentViewFrameForBackgroundFrame:frame popoverEdge:self.popoverEdge]);
    CGFloat minX = NSMinX(contentRect);
    CGFloat maxX = NSMaxX(contentRect);
    CGFloat minY = NSMinY(contentRect);
    CGFloat maxY = NSMaxY(contentRect);
    
    NSRect windowRect = [self.window convertRectFromScreen:self.popoverOrigin];
    NSRect originRect = [self convertRect:windowRect fromView:nil];
    CGFloat midOriginX = floor(getMedianXFromRects(originRect, contentRect));
    CGFloat midOriginY = floor(getMedianYFromRects(originRect, contentRect));
    
    CGFloat minArrowX = 0.0;
    CGFloat maxArrowX = 0.0;
    CGFloat minArrowY = 0.0;
    CGFloat maxArrowY = 0.0;
    
    // Even I have no idea at this point… :trollface:
    // So we don't have a weird arrow situation we need to make sure we draw it within the radius.
    // If we have to nudge it then we have to shrink the arrow as otherwise it looks all wonky and weird.
    // That is what this complete mess below does.
    if (arrowEdge == NSRectEdgeMinY || arrowEdge == NSRectEdgeMaxY) {
        maxArrowX = floor(midOriginX + (arrowWidth / 2));
        CGFloat maxPossible = (NSMaxX(contentRect) - borderRadius);
        
        if (maxArrowX > maxPossible) {
            maxArrowX = maxPossible;
            minArrowX = maxArrowX - arrowWidth;
        } else {
            minArrowX = floor(midOriginX - (arrowWidth / 2));
            
            if (minArrowX < borderRadius) {
                minArrowX = borderRadius;
                maxArrowX = minArrowX + arrowWidth;
            }
        }
    } else {
        minArrowY = floor(midOriginY - (arrowWidth / 2));
        
        if (minArrowY < borderRadius) {
            minArrowY = borderRadius;
            maxArrowY = minArrowY + arrowWidth;
        } else {
            maxArrowY = floor(midOriginY + (arrowWidth / 2));
            CGFloat maxPossible = (NSMaxY(contentRect) - borderRadius);
            
            if (maxArrowY > maxPossible) {
                maxArrowY = maxPossible;
                minArrowY = maxArrowY - arrowWidth;
            }
        }
    }
    
    NSPoint minBasePoint, tipPoint, maxBasePoint;
    
    switch (arrowEdge) {
        case NSRectEdgeMinX:
            minBasePoint = NSMakePoint(minX, minArrowY);
            tipPoint = NSMakePoint(floor(minX - arrowHeight), floor((minArrowY + maxArrowY) / 2));
            maxBasePoint = NSMakePoint(minX, maxArrowY);
            break;
        case NSRectEdgeMaxY:
            minBasePoint = NSMakePoint(minArrowX, maxY);
            tipPoint = NSMakePoint(floor((minArrowX + maxArrowX) / 2), floor(maxY + arrowHeight));
            maxBasePoint = NSMakePoint(maxArrowX, maxY);
            break;
        case NSRectEdgeMaxX:
            minBasePoint = NSMakePoint(maxX, minArrowY);
            tipPoint = NSMakePoint(floor(maxX + arrowHeight), floor((minArrowY + maxArrowY) / 2));
            maxBasePoint = NSMakePoint(maxX, maxArrowY);
            break;
        case NSRectEdgeMinY:
            minBasePoint = NSMakePoint(minArrowX, minY);
            tipPoint = NSMakePoint(floor((minArrowX + maxArrowX) / 2), floor(minY - arrowHeight));
            maxBasePoint = NSMakePoint(maxArrowX, minY);
            break;
        default:
            break;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (_shouldShowArrowWithVisualEffect) {
        CGFloat minX = NSMinX(contentRect);
        CGFloat maxX = NSMaxX(contentRect);
        CGFloat minY = NSMinY(contentRect);
        CGFloat maxY = NSMaxY(contentRect);
        
        // These represent the centerpoints of the popover's corner arcs.
        CGFloat minCenterpointX = floor(minX + borderRadius);
        CGFloat maxCenterpointX = floor(maxX - borderRadius);
        CGFloat minCenterpointY = floor(minY + borderRadius);
        CGFloat maxCenterpointY = floor(maxY - borderRadius);
        
        CGPathMoveToPoint(path, NULL, minX, minCenterpointY);
        
        CGPathAddArc(path, NULL, minCenterpointX, maxCenterpointY, borderRadius, M_PI, M_PI_2, true);
        CGPathAddArc(path, NULL, maxCenterpointX, maxCenterpointY, borderRadius, M_PI_2, 0, true);
        CGPathAddArc(path, NULL, maxCenterpointX, minCenterpointY, borderRadius, 0, -M_PI_2, true);
        CGPathAddArc(path, NULL, minCenterpointX, minCenterpointY, borderRadius, -M_PI_2, M_PI, true);
    }
    
    CGPathMoveToPoint(path, NULL, minBasePoint.x, minBasePoint.y);
    CGPathAddLineToPoint(path, NULL, tipPoint.x, tipPoint.y);
    CGPathAddLineToPoint(path, NULL, maxBasePoint.x, maxBasePoint.y);
    
    return path;
}

#pragma mark - Mouse events

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (!self.becomesKeyOnMouseOver) return;
    
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
        _trackingArea = nil;
    }
    
    NSInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways);
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    if (![[NSApplication sharedApplication] isActive]) return;
    if (!self.becomesKeyOnMouseOver) return;
    if (!self.userInteractionEnable) return;
    
    if ((event.window == self.window) && ![event.window isKeyWindow]) {
        _mouseEnteredEventReceived = YES;
        
        [event.window makeKeyAndOrderFront:nil];
    }
}

- (void)mouseExited:(NSEvent *)event {
    if (![[NSApplication sharedApplication] isActive]) return;
    if (!self.becomesKeyOnMouseOver) return;
    if (!self.userInteractionEnable) return;
    
    if (event.window == self.window) {
        _mouseEnteredEventReceived = NO;
        
        [event.window makeKeyAndOrderFront:nil];
    }
}

- (void)mouseMoved:(NSEvent *)event {
    if (![[NSApplication sharedApplication] isActive]) return;
    if (!self.becomesKeyOnMouseOver) return;
    if (!self.userInteractionEnable) return;
    if (!_mouseEnteredEventReceived) return;
    
    if ((event.window == self.window) && ![event.window isKeyWindow]) {
        [event.window makeKeyAndOrderFront:nil];
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.userInteractionEnable) return;
    
    BOOL isPopover = [event.window respondsToSelector:@selector(tag)];
    _originalMouseOffset = isPopover ? event.locationInWindow : [self convertPoint:event.locationInWindow fromView:self.window.contentView];
    _dragging = NO;
    _mouseDownEventReceived = YES;
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.userInteractionEnable) return;
    
    if (_mouseDownEventReceived && (_isMovable || _isDetachable)) {
        _dragging = YES;
        
        if ([self.delegate respondsToSelector:@selector(popoverDidMakeMovement)]) {
            [self.delegate popoverDidMakeMovement];
        }
        
        BOOL isPopover = [event.window respondsToSelector:@selector(tag)];
        
        NSPoint currentMouseOffset = isPopover ? event.locationInWindow : [self convertPoint:event.locationInWindow fromView:event.window.contentView];
        NSPoint difference = NSMakePoint(currentMouseOffset.x - _originalMouseOffset.x, currentMouseOffset.y - _originalMouseOffset.y);
        NSPoint currentOrigin = isPopover ? event.window.frame.origin : self.frame.origin;
        NSPoint nextOrigin = NSMakePoint(currentOrigin.x + difference.x, currentOrigin.y + difference.y);
        
        if (isPopover) {
            [event.window setFrameOrigin:nextOrigin];
        } else {
            [self setFrameOrigin:nextOrigin];
        }
    }
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.userInteractionEnable) return;
    
    if (_mouseDownEventReceived && _dragging) {
        if (_isDetachable) {
            _isDetachable = NO;
            _isMovable = NO;
            
            if ([self.delegate respondsToSelector:@selector(popoverDidMakeDetachable:)]) {
                [self.delegate popoverDidMakeDetachable:event.window];
            }
        }
        
        _mouseDownEventReceived = NO;
        _dragging = NO;
    }
}

@end
