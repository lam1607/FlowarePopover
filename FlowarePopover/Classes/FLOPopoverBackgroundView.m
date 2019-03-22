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

static void CGPathCallback(void *info, const CGPathElement *element) {
    NSBezierPath *bezierPath = (__bridge NSBezierPath *)info;
    CGPoint *points = element->points;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint: {
            [bezierPath moveToPoint:points[0]];
            break;
        }
        case kCGPathElementAddLineToPoint: {
            [bezierPath lineToPoint:points[0]];
            break;
        }
        case kCGPathElementAddQuadCurveToPoint: {
            NSPoint qp0 = bezierPath.currentPoint, qp1 = points[0], qp2 = points[1], cp1, cp2;
            CGFloat m = 0.666666666666667;
            cp1.x = (qp0.x + ((qp1.x - qp0.x) * m));
            cp1.y = (qp0.y + ((qp1.y - qp0.y) * m));
            cp2.x = (qp2.x + ((qp1.x - qp2.x) * m));
            cp2.y = (qp2.y + ((qp1.y - qp2.y) * m));
            [bezierPath curveToPoint:qp2 controlPoint1:cp1 controlPoint2:cp2];
            break;
        }
        case kCGPathElementAddCurveToPoint: {
            [bezierPath curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
            break;
        }
        case kCGPathElementCloseSubpath: {
            [bezierPath closePath];
            break;
        }
    }
}

static NSBezierPath *bezierPathWithCGPath(CGPathRef cgPath) {
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    CGPathApply(cgPath, (__bridge void *)bezierPath, CGPathCallback);
    
    return bezierPath;
}

#pragma mark - FLOPopoverClippingView

@interface FLOPopoverClippingView ()

@property (nonatomic, strong) NSVisualEffectView *visualEffectView;

@end

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
    
    @try {
        self.needsDisplay = YES;
    } @catch (NSException *exception) {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.clippingPath == NULL) return;
    
    [self setupArrowPath];
}

- (void)setupArrowVisualEffectViewMaterial:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    if (self.visualEffectView == nil) {
        self.visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.frame];
        self.visualEffectView.state = state;
        self.visualEffectView.material = material;
        self.visualEffectView.blendingMode = blendingMode;
        
        [self addSubview:self.visualEffectView];
    }
}

- (void)setupArrowPath {
    if (self.visualEffectView != nil) {
        [self.visualEffectView setFrameSize:self.frame.size];
        
        self.visualEffectView.maskImage = [NSImage imageWithSize:self.frame.size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            NSBezierPath *path = bezierPathWithCGPath(self.clippingPath);
            [path fill];
            
            return YES;
        }];
    } else {
        CGContextRef currentContext = NSGraphicsContext.currentContext.CGContext;
        
        if (currentContext != nil) {
            self.pathColor = ((self.pathColor != nil) && (self.pathColor != [NSColor.clearColor CGColor])) ? self.pathColor : [NSColor.lightGrayColor CGColor];
            
            CGContextAddPath(currentContext, self.clippingPath);
            CGContextSetFillColorWithColor(currentContext, self.pathColor);
            CGContextFillPath(currentContext);
        }
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

@property (nonatomic, assign) BOOL isReceivedMouseDownEvent;

@property (nonatomic, assign) BOOL shouldShowArrowWithVisualEffect;

@end

@implementation FLOPopoverBackgroundView

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        _arrowSize = NSZeroSize;
        _fillColor = NSColor.clearColor;
        _isReceivedMouseDownEvent = NO;
        _shouldShowArrowWithVisualEffect = NO;
        
        _clippingView = [[FLOPopoverClippingView alloc] initWithFrame:self.bounds];
        
        _clippingView.translatesAutoresizingMaskIntoConstraints = YES;
        _clippingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        [self addSubview:_clippingView];
    }
    
    return self;
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

- (void)setArrowSize:(CGSize)arrowSize {
    if (NSEqualSizes(arrowSize, self.arrowSize) && (NSEqualSizes(self.arrowSize, NSZeroSize) == NO)) return;
    
    _arrowSize = arrowSize;
    
    self.needsDisplay = YES;
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

- (void)makeMovable:(BOOL)movable {
    self.isMovable = movable;
}

- (void)makeDetachable:(BOOL)detachable {
    self.isDetachable = detachable;
}

- (void)shouldShowShadow:(BOOL)needed {
    if (needed) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [NSColor.shadowColor CGColor];
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
        self.layer.shadowRadius = 3.0;
    }
}

- (void)shouldShowArrow:(BOOL)needed {
    if (NSEqualSizes(self.arrowSize, NSZeroSize) == NO) {
        [self updateClippingView];
    } else {
        self.clippingView.clippingPath = nil;
        
        [self.clippingView setupArrowPath];
    }
}

- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    self.shouldShowArrowWithVisualEffect = needed;
    
    if (needed) {
        [self.clippingView setupArrowVisualEffectViewMaterial:material blendingMode:blendingMode state:state];
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
        CGFloat maxPossible = (NSMaxX(contentRect) - self.borderRadius);
        
        if (maxArrowX > maxPossible) {
            maxArrowX = maxPossible;
            minArrowX = maxArrowX - self.arrowSize.width;
        } else {
            minArrowX = floor(midOriginX - (self.arrowSize.width / 2.0));
            
            if (minArrowX < self.borderRadius) {
                minArrowX = self.borderRadius;
                maxArrowX = minArrowX + self.arrowSize.width;
            }
        }
    } else {
        minArrowY = floor(midOriginY - (self.arrowSize.width / 2.0));
        
        if (minArrowY < self.borderRadius) {
            minArrowY = self.borderRadius;
            maxArrowY = minArrowY + self.arrowSize.width;
        } else {
            maxArrowY = floor(midOriginY + (self.arrowSize.width / 2.0));
            CGFloat maxPossible = (NSMaxY(contentRect) - self.borderRadius);
            
            if (maxArrowY > maxPossible) {
                maxArrowY = maxPossible;
                minArrowY = maxArrowY - self.arrowSize.width;
            }
        }
    }
    
    // These represent the centerpoints of the popover's corner arcs.
    CGFloat minCenterpointX = floor(minX + self.borderRadius);
    CGFloat maxCenterpointX = floor(maxX - self.borderRadius);
    CGFloat minCenterpointY = floor(minY + self.borderRadius);
    CGFloat maxCenterpointY = floor(maxY - self.borderRadius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (self.shouldShowArrowWithVisualEffect) {
        CGPathMoveToPoint(path, NULL, minX, minCenterpointY);
        
        CGFloat radius = self.borderRadius;
        
        CGPathAddArc(path, NULL, minCenterpointX, maxCenterpointY, radius, M_PI, M_PI_2, true);
        CGPathAddArc(path, NULL, maxCenterpointX, maxCenterpointY, radius, M_PI_2, 0, true);
        CGPathAddArc(path, NULL, maxCenterpointX, minCenterpointY, radius, 0, -M_PI_2, true);
        CGPathAddArc(path, NULL, minCenterpointX, minCenterpointY, radius, -M_PI_2, M_PI, true);
    }
    
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

- (void)mouseDown:(NSEvent *)event {
    BOOL isFLOPopoverWindow = [event.window isKindOfClass:[FLOPopoverWindow class]];
    self.originalMouseOffset = isFLOPopoverWindow ? event.locationInWindow : [self convertPoint:event.locationInWindow fromView:self.window.contentView];
    self.dragging = NO;
    self.isReceivedMouseDownEvent = YES;
}

- (void)mouseDragged:(NSEvent *)event {
    if (self.isReceivedMouseDownEvent && (self.isMovable || self.isDetachable)) {
        self.dragging = YES;
        
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

- (void)mouseUp:(NSEvent *)event {
    if (self.isReceivedMouseDownEvent && self.dragging) {
        if (self.isDetachable) {
            self.isDetachable = NO;
            self.isMovable = NO;
            
            if ([self.delegate respondsToSelector:@selector(didPopoverBecomeDetachable:)]) {
                [self.delegate didPopoverBecomeDetachable:event.window];
            }
        }
        
        self.isReceivedMouseDownEvent = NO;
        self.dragging = NO;
    }
}

@end
