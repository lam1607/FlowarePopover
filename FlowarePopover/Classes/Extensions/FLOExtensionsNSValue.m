//
//  FLOExtensionsNSValue.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOExtensionsNSValue.h"

@implementation NSValue (FLOExtensionsNSValue)

- (CGRect)floRectValue {
    return [self rectValue];
}

- (CGSize)floSizeValue {
    return [self sizeValue];
}

- (CGPoint)floPointValue {
    return [self pointValue];
}

- (CGAffineTransform)floAffineTransformValue {
    CGAffineTransform transform;
    [self getValue:&transform];
    return transform;
}

+ (NSValue *)floValueWithRect:(CGRect)rect {
    return [self valueWithRect:rect];
}

+ (NSValue *)floValueWithPoint:(CGPoint)point {
    return [self valueWithPoint:point];
}

+ (NSValue *)floValueWithSize:(CGSize)size {
    return [self valueWithSize:size];
}

+ (NSValue *)floValueWithAffineTransform:(CGAffineTransform)transform {
    return [NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)];
}

- (FLOValueType)floType {
    const char *type = self.objCType;
    
    static const NSInteger numberofNumberTypes = 10;
    static const char *numberTypes[numberofNumberTypes] = { "i", "s", "l", "q", "I", "S", "L", "Q", "f", "d" };
    
    for (NSInteger i = 0; i < numberofNumberTypes; i++) {
        if (strcmp(type, numberTypes[i]) == 0) {
            return FLOValueTypeNumber;
        }
    }
    if (strcmp(type, @encode(CGPoint)) == 0) {
        return FLOValueTypePoint;
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        return FLOValueTypeSize;
    } else if (strcmp(type, @encode(CGRect)) == 0) {
        return FLOValueTypeRect;
    } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
        return FLOValueTypeAffineTransform;
    } else if (strcmp(type, @encode(CATransform3D)) == 0) {
        return FLOValueTypeTransform3D;
    } else {
        return FLOValueTypeUnknown;
    }
}

@end
