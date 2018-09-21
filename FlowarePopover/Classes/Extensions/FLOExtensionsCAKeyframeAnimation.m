//
//  FLOExtensionsCAKeyframeAnimation.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOExtensionsCAKeyframeAnimation.h"

#import "FLOExtensionsNSValue.h"

static const CGFloat FLOAnimationDefaultMass = 5.f;
static const CGFloat FLOAnimationDefaultDamping = 30.f;
static const CGFloat FLOAnimationDefaultStiffness = 300.f;
static const CGFloat FLOAnimationKeyframeStep = 0.001f;
static const CGFloat FLOAnimationMinimumThreshold = 0.0001f;

@interface FLOExtensionsCAKeyframeAnimation()

@property (nonatomic, copy) NSArray *interpolatedValues;
@property (nonatomic, assign) BOOL needsRecalculation;

@end

@implementation FLOExtensionsCAKeyframeAnimation

#pragma mark -
#pragma mark - Initialization
#pragma mark -

+ (instancetype)animationWithKeyPath:(NSString *)path {
    return [super animationWithKeyPath:path];
}

- (id)init {
    if (self = [super init]) {
        _mass = FLOAnimationDefaultMass;
        _damping = FLOAnimationDefaultDamping;
        _stiffness = FLOAnimationDefaultStiffness;
        _needsRecalculation = NO;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FLOExtensionsCAKeyframeAnimation *copy = [super copyWithZone:zone];
    
    copy.interpolatedValues = self.interpolatedValues;
    copy.duration = self.interpolatedValues.count * FLOAnimationKeyframeStep;
    copy.fromValue = self.fromValue;
    copy.stiffness = self.stiffness;
    copy.toValue = self.toValue;
    copy.damping = self.damping;
    copy.mass = self.mass;
    
    copy.needsRecalculation = NO;
    
    return copy;
}

#pragma mark -
#pragma mark - API
#pragma mark -
- (void)setToValue:(id)toValue {
    _toValue = toValue;
    self.needsRecalculation = YES;
}

- (void)setFromValue:(id)fromValue {
    _fromValue = fromValue;
    self.needsRecalculation = YES;
}

- (void)setStiffness:(CGFloat)stiffness {
    _stiffness = stiffness;
    self.needsRecalculation = YES;
}

- (void)setMass:(CGFloat)mass {
    _mass = mass;
    self.needsRecalculation = YES;
}

- (NSArray *)values {
    return self.interpolatedValues;
}

- (void)setDamping:(CGFloat)damping {
    if (damping <= 0) {
        NSLog(@"[%@] LOGIC ERROR. `damping` should be > 0.0f to avoid an infinite spring calculation", NSStringFromClass([self class]));
        damping = 1.0f;
    }
    
    _damping = damping;
    self.needsRecalculation = YES;
}

- (CFTimeInterval)duration {
    if ((self.fromValue != nil) && (self.toValue != nil)) {
        return self.interpolatedValues.count * FLOAnimationKeyframeStep;
    }
    
    return 0.f;
}

- (NSArray *)interpolatedValues {
    if (self.needsRecalculation || (_interpolatedValues == nil)) {
        [self calculateInterpolatedValues];
    }
    
    return _interpolatedValues;
}

#pragma mark -
#pragma mark - Interpolation
#pragma mark -
- (void)calculateInterpolatedValues {
    NSAssert(self.fromValue != nil && self.toValue != nil, @"fromValue and or toValue must not be nil.");
    
    FLOValueType fromType = [self.fromValue flo_type];
    __unused FLOValueType toType = [self.toValue flo_type];
    NSArray *values = nil;
    
    if (fromType == FLOValueTypeNumber) {
        values = [self valuesFromNumbers:@[self.fromValue] toNumbers:@[self.toValue] map:^id(CGFloat *values, NSUInteger count) {
            return @(values[0]);
        }];
    } else if (fromType == FLOValueTypePoint) {
        CGPoint f = [self.fromValue flo_pointValue];
        CGPoint t = [self.toValue flo_pointValue];
        values = [self valuesFromNumbers:@[@(f.x), @(f.y)]
                               toNumbers:@[@(t.x), @(t.y)]
                                     map:^id(CGFloat *values, NSUInteger count) {
                                         return [NSValue flo_valueWithPoint:CGPointMake(values[0], values[1])];
                                     }];
    } else if (fromType == FLOValueTypeSize) {
        CGSize f = [self.fromValue flo_sizeValue];
        CGSize t = [self.toValue flo_sizeValue];
        values = [self valuesFromNumbers:@[@(f.width), @(f.height)]
                               toNumbers:@[@(t.width), @(t.height)]
                                     map:^id(CGFloat *values, NSUInteger count) {
                                         return [NSValue flo_valueWithSize:CGSizeMake(values[0], values[1])];
                                     }];
    } else if (fromType == FLOValueTypeRect) { // note that CA will not animate the `frame` property
        CGRect f = [self.fromValue flo_rectValue];
        CGRect t = [self.toValue flo_rectValue];
        values = [self valuesFromNumbers:@[@(f.origin.x), @(f.origin.y), @(f.size.width), @(f.size.height)]
                               toNumbers:@[@(t.origin.x), @(t.origin.y), @(t.size.width), @(t.size.height)]
                                     map:^id(CGFloat *values, NSUInteger count) {
                                         return [NSValue flo_valueWithRect:CGRectMake(values[0], values[1], values[2], values[3])];
                                     }];
    } else if (fromType == FLOValueTypeAffineTransform) {
        CGAffineTransform f = [self.fromValue flo_affineTransformValue];
        CGAffineTransform t = [self.toValue flo_affineTransformValue];
        
        values = [self valuesFromNumbers:@[@(f.a), @(f.b), @(f.c), @(f.d), @(f.tx), @(f.ty)]
                               toNumbers:@[@(t.a), @(t.b), @(t.c), @(t.d), @(t.tx), @(t.ty)]
                                     map:^id(CGFloat *values, NSUInteger count) {
                                         CGAffineTransform transform;
                                         transform.a = values[0];
                                         transform.b = values[1];
                                         transform.c = values[2];
                                         transform.d = values[3];
                                         transform.tx = values[4];
                                         transform.ty = values[5];
                                         
                                         return [NSValue flo_valueWithAffineTransform:transform];
                                     }];
    } else if (fromType == FLOValueTypeTransform3D) {
        CATransform3D f = [self.fromValue CATransform3DValue];
        CATransform3D t = [self.toValue CATransform3DValue];
        
        values = [self valuesFromNumbers:@[@(f.m11), @(f.m12), @(f.m13), @(f.m14), @(f.m21), @(f.m22), @(f.m23), @(f.m24), @(f.m31), @(f.m32), @(f.m33), @(f.m34), @(f.m41), @(f.m42), @(f.m43), @(f.m44) ]
                               toNumbers:@[@(t.m11), @(t.m12), @(t.m13), @(t.m14), @(t.m21), @(t.m22), @(t.m23), @(t.m24), @(t.m31), @(t.m32), @(t.m33), @(t.m34), @(t.m41), @(t.m42), @(t.m43), @(t.m44) ]
                                     map:^id(CGFloat *values, NSUInteger count) {
                                         CATransform3D transform = CATransform3DIdentity;
                                         transform.m11 = values[0];
                                         transform.m12 = values[1];
                                         transform.m13 = values[2];
                                         transform.m14 = values[3];
                                         transform.m21 = values[4];
                                         transform.m22 = values[5];
                                         transform.m23 = values[6];
                                         transform.m24 = values[7];
                                         transform.m31 = values[8];
                                         transform.m32 = values[9];
                                         transform.m33 = values[10];
                                         transform.m34 = values[11];
                                         transform.m41 = values[12];
                                         transform.m42 = values[13];
                                         transform.m43 = values[14];
                                         transform.m44 = values[15];
                                         
                                         return [NSValue valueWithCATransform3D:transform];
                                     }];
    }
    
    self.interpolatedValues = values;
    self.needsRecalculation = NO;
}

- (NSArray *)valuesFromNumbers:(NSArray *)fromNumbers toNumbers:(NSArray *)toNumbers map:(id (^)(CGFloat *values, NSUInteger count))map {
    NSAssert(fromNumbers.count == toNumbers.count, @"count of from and to numbers must be equal");
    
    NSUInteger count = fromNumbers.count;
    
    // This will never happen, but this is peformed in order to shush the analyzer.
    if (count < 1) {
        return [NSArray array];
    }
    
    CGFloat *distances = calloc(count, sizeof(CGFloat));
    CGFloat *thresholds = calloc(count, sizeof(CGFloat));
    
    for (NSInteger i = 0; i < count; i++) {
        distances[i] = [toNumbers[i] floatValue] - [fromNumbers[i] floatValue];
        thresholds[i] = FLOExtensionsCAKeyframeAnimationThreshold(fabs(distances[i]));
    }
    
    CFTimeInterval step = FLOAnimationKeyframeStep;
    CFTimeInterval elapsed = 0;
    
    CGFloat *stepValues = calloc(count, sizeof(CGFloat));
    CGFloat *stepProposedValues = calloc(count, sizeof(CGFloat));
    
    NSMutableArray *valuesMapped = [NSMutableArray array];
    while (YES) {
        BOOL thresholdReached = YES;
        
        for (NSInteger i = 0; i < count; i++) {
            stepProposedValues[i] = FLOExtensionsCAKeyframeAbsolutePosition(distances[i], elapsed, 0, self.damping, self.mass, self.stiffness, [fromNumbers[i] floatValue]);
            
            if (thresholdReached)
                thresholdReached = FLOExtensionsCAKeyframeThresholdReached(stepValues[i], stepProposedValues[i], [toNumbers[i] floatValue], thresholds[i]);
        }
        
        if (thresholdReached)
            break;
        
        for (NSInteger i = 0; i < count; i++) {
            stepValues[i] = stepProposedValues[i];
        }
        
        [valuesMapped addObject:map(stepValues, count)];
        elapsed += step;
    }
    
    free(distances);
    free(thresholds);
    free(stepValues);
    free(stepProposedValues);
    
    return valuesMapped;
}

BOOL FLOExtensionsCAKeyframeThresholdReached(CGFloat previousValue, CGFloat proposedValue, CGFloat finalValue, CGFloat threshold) {
    CGFloat previousDifference = fabs(proposedValue - previousValue);
    CGFloat finalDifference = fabs(previousValue - finalValue);
    
    if (previousDifference <= threshold && finalDifference <= threshold) {
        return YES;
    }
    
    return NO;
}

BOOL FLOExtensionsCAKeyframeCalculationsAreComplete(CGFloat value1, CGFloat proposedValue1, CGFloat to1, CGFloat value2, CGFloat proposedValue2, CGFloat to2, CGFloat value3, CGFloat proposedValue3, CGFloat to3) {
    return ((fabs(proposedValue1 - value1) < FLOAnimationKeyframeStep) && (fabs(value1 - to1) < FLOAnimationKeyframeStep)
            && (fabs(proposedValue2 - value2) < FLOAnimationKeyframeStep) && (fabs(value2 - to2) < FLOAnimationKeyframeStep)
            && (fabs(proposedValue3 - value3) < FLOAnimationKeyframeStep) && (fabs(value3 - to3) < FLOAnimationKeyframeStep));
}

#pragma mark -
#pragma mark - Damped Harmonic Oscillation
#pragma mark -
CGFloat FLOExtensionsCAKeyframeAngularFrequency(CGFloat k, CGFloat m, CGFloat b) {
    CGFloat w0 = sqrt(k / m);
    CGFloat frequency = sqrt(pow(w0, 2) - (pow(b, 2) / (4 * pow(m, 2))));
    if (isnan(frequency)) frequency = 0;
    
    return frequency;
}

CGFloat FLOExtensionsCAKeyframeRelativePosition(CGFloat A, CGFloat t, CGFloat phi, CGFloat b, CGFloat m, CGFloat k) {
    if (A == 0) return A;
    CGFloat ex = (-b / (2 * m) * t);
    CGFloat freq = FLOExtensionsCAKeyframeAngularFrequency(k, m, b);
    
    return A * exp(ex) * cos(freq * t + phi);
}

CGFloat FLOExtensionsCAKeyframeAbsolutePosition(CGFloat A, CGFloat t, CGFloat phi, CGFloat b, CGFloat m, CGFloat k, CGFloat from) {
    return from + A - FLOExtensionsCAKeyframeRelativePosition(A, t, phi, b, m, k);
}

// This feels a bit hacky. I'm sure there's a better way to accomplish this.
CGFloat FLOExtensionsCAKeyframeAnimationThreshold(CGFloat magnitude) {
    return FLOAnimationMinimumThreshold * magnitude;
}

#pragma mark Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> mass: %f, damping: %f, stiffness: %f, keyPath: %@, toValue: %@, fromValue %@", self.class, self, self.mass, self.damping, self.stiffness, self.keyPath, self.toValue, self.fromValue];
}

@end
