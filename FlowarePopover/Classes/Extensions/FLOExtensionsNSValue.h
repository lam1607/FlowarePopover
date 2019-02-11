//
//  FLOExtensionsNSValue.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, FLOValueType) {
    FLOValueTypeNumber,
    FLOValueTypePoint,
    FLOValueTypeSize,
    FLOValueTypeRect,
    FLOValueTypeAffineTransform,
    FLOValueTypeTransform3D,
    FLOValueTypeUnknown
};

@interface NSValue (FLOExtensionsNSValue)

- (CGRect)floRectValue;
- (CGSize)floSizeValue;
- (CGPoint)floPointValue;
- (CGAffineTransform)floAffineTransformValue;

+ (NSValue *)floValueWithRect:(CGRect)rect;
+ (NSValue *)floValueWithSize:(CGSize)size;
+ (NSValue *)floValueWithPoint:(CGPoint)point;
+ (NSValue *)floValueWithAffineTransform:(CGAffineTransform)transform;

- (FLOValueType)floType;

@end
