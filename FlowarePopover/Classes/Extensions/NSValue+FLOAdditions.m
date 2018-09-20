//
//  NSValue (FLOAdditions)
//  FlowarePopover
//
//  Created by Floware Team on 11/23/17.
//  Copyright © 2017 Floware Inc. All rights reserved.
//

#import "NSValue+FLOAdditions.h"

@implementation NSValue (FLOAdditions)

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

- (CGRect)flo_rectValue {
	return [self CGRectValue];
}

- (CGSize)flo_sizeValue {
	return [self CGSizeValue];
}

- (CGPoint)flo_pointValue {
	return [self CGPointValue];
}

- (CGAffineTransform)flo_affineTransformValue {
	return [self CGAffineTransformValue];
}

+ (NSValue *)flo_valueWithRect:(CGRect)rect {
	return [self valueWithCGRect:rect];
}

+ (NSValue *)flo_valueWithPoint:(CGPoint)point {
	return [self valueWithCGPoint:point];
}

+ (NSValue *)flo_valueWithSize:(CGSize)size {
	return [self valueWithCGSize:size];
}

+ (NSValue *)flo_valueWithAffineTransform:(CGAffineTransform)transform {
	return [self valueWithCGAffineTransform:transform];
}

#elif TARGET_OS_MAC

- (CGRect)flo_rectValue {
	return [self rectValue];
}

- (CGSize)flo_sizeValue {
	return [self sizeValue];
}

- (CGPoint)flo_pointValue {
	return [self pointValue];
}

- (CGAffineTransform)flo_affineTransformValue {
	CGAffineTransform transform;
	[self getValue:&transform];
	return transform;
}

+ (NSValue *)flo_valueWithRect:(CGRect)rect {
	return [self valueWithRect:rect];
}

+ (NSValue *)flo_valueWithPoint:(CGPoint)point {
	return [self valueWithPoint:point];
}

+ (NSValue *)flo_valueWithSize:(CGSize)size {
	return [self valueWithSize:size];
}

+ (NSValue *)flo_valueWithAffineTransform:(CGAffineTransform)transform {
	return [NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)];
}

#endif

- (FLOValueType)flo_type {
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
