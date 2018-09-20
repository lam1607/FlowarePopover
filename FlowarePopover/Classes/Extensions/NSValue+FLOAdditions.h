//
//  NSValue (FLOAdditions)
//  FlowarePopover
//
//  Created by Floware Team on 11/23/17.
//  Copyright © 2017 Floware Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

typedef NS_ENUM(NSInteger, FLOValueType) {
	FLOValueTypeNumber,
	FLOValueTypePoint,
	FLOValueTypeSize,
	FLOValueTypeRect,
	FLOValueTypeAffineTransform,
	FLOValueTypeTransform3D,
	FLOValueTypeUnknown
};

@interface NSValue (FLOAdditions)

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
