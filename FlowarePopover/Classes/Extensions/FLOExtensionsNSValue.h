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

- (CGRect)flo_rectValue;
- (CGSize)flo_sizeValue;
- (CGPoint)flo_pointValue;
- (CGAffineTransform)flo_affineTransformValue;

+ (NSValue *)flo_valueWithRect:(CGRect)rect;
+ (NSValue *)flo_valueWithSize:(CGSize)size;
+ (NSValue *)flo_valueWithPoint:(CGPoint)point;
+ (NSValue *)flo_valueWithAffineTransform:(CGAffineTransform)transform;

- (FLOValueType)flo_type;

@end
