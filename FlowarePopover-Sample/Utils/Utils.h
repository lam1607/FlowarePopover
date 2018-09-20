//
//  Utils.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Utils : NSObject

#pragma mark -
#pragma mark - Model object parsing
#pragma mark -
/**
 * Return an array of property names of given class.
 *
 * @param class that we need getting all property names.
 * @return NSArray of the class's property names.
 */
+ (NSArray *)propertyNamesOfClass:(Class)class;

/**
 * Set all property values of given object related to info dictionary.
 *
 * @param object the object that used for getting all its properties.
 * @param info an NSDictionary contains (key, value) that parsed to the object.
 * @warning all property names of object @b MUST @b BE @b THE @b SAME @b WITH NSDictionary keys.
 */
+ (void)setValuesToPropertiesOfObject:(id<NSObject>)object withInfo:(NSDictionary *)info;

/**
 * Decode all properties of given object.
 */
+ (void)decode:(NSCoder *)decoder object:(id<NSObject>)object;

/**
 * Encode all properties of given object.
 */
+ (void)encode:(NSCoder *)encoder object:(id<NSObject>)object;

/**
 * Make a copy from an object with zone.
 *
 * @param copy the destination object need copied.
 * @param object the source object using for copying.
 * @param zone the NSZone used in copying.
 * @note the @b TYPE of copy & object parameters @b MUST @b BE @b THE @b SAME.
 */
+ (void)copy:(NSObject *)copy from:(NSObject *)object withZone:(NSZone *)zone;

#pragma mark -
#pragma mark - Localizable & language
#pragma mark -
+ (BOOL)isEnglishLanguage;

#pragma mark -
#pragma mark - Format view
#pragma mark -
+ (void)setViewTransparent:(NSView *)view withBackgroundColor:(NSColor *)color;
+ (void)setShadowForView:(NSView *)view;

#pragma mark -
#pragma mark - Checking
#pragma mark -
+ (BOOL)isEmptyObject:(id)obj;

#pragma mark -
#pragma mark - Validations
#pragma mark -
+ (BOOL)isValidEmail:(NSString *)email;
+ (BOOL)isValidPassword:(NSString *)password;

#pragma mark -
#pragma mark - Date time
#pragma mark -
+ (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)dateFormat;
+ (NSString *)stringFromCurrentTimeZoneDate:(NSDate *)currentTimeZoneDate withFormat:(NSString *)dateFormat;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)dateFormat;

#pragma mark -
#pragma mark - String
#pragma mark -
+ (NSString *)uniqueString;
+ (NSString *)trimOfString:(NSString *)str;
+ (NSSize)sizeOfControl:(NSControl *)control;
+ (NSSize)sizeOfControl:(NSControl *)control withWidth:(CGFloat)width;
+ (CGFloat)heightForWidth:(CGFloat)width string:(NSAttributedString*)string;
+ (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height string:(NSAttributedString*)string;

#pragma mark -
#pragma mark - Device
#pragma mark -
+ (NSSize)screenSize;

#pragma mark -
#pragma mark - Application utilities
#pragma mark -
+ (NSString *)getAppPathWithIdentifier:(NSString *)bundleIdentifier;
+ (NSString *)getAppNameWithIdentifier:(NSString *)bundleIdentifier;

@end
