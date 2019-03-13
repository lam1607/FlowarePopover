//
//  NSObject+Extensions.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/8/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extensions)

/**
 * Return an array of property names of given class.
 */
- (NSArray<NSString *> *)properties;

/**
 * Set all property values of given object related to info dictionary.
 *
 * @param info an NSDictionary contains (key, value) that parsed to the object.
 * @warning all property names of object @b MUST @b BE @b THE @b SAME @b WITH NSDictionary keys.
 */
- (void)setPropertiesWithInfoValues:(NSDictionary *)info;

/**
 * Decode all properties of given object.
 */
- (void)decode:(NSCoder *)decoder;

/**
 * Encode all properties of given object.
 */
- (void)encode:(NSCoder *)encoder;

/**
 * Make a copy from an object with zone.
 *
 * @param object the source object using for copying.
 * @param zone the NSZone used in copying.
 * @note the @b TYPE of copy & object parameters @b MUST @b BE @b THE @b SAME.
 */
- (void)copy:(NSObject *)object zone:(NSZone *)zone;

- (void)mutableCopy:(NSObject *)object zone:(NSZone *)zone;

#pragma mark - Object validation

+ (BOOL)isEmpty:(id)object;

@end
