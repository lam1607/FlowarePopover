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

/// @property
///
@property (nonatomic, assign) BOOL isApplicationActive;
@property (nonatomic, assign) BOOL shouldChildWindowsFloat;

/// Methods
///
#pragma mark - Singleton

+ (Utils *)sharedInstance;

#pragma mark - Model object parsing

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

#pragma mark - Formats

+ (void)setViewTransparent:(NSView *)view withBackgroundColor:(NSColor *)color;
+ (void)setShadowForView:(NSView *)view;
+ (void)setBackgroundColor:(NSColor *)color forView:(NSView *)view;
+ (void)setBackgroundColor:(NSColor *)color cornerRadius:(CGFloat)radius forView:(NSView *)view;
+ (void)setTitle:(NSString *)title attributes:(NSDictionary *)attributes forControl:(NSControl *)control;
+ (void)setTitle:(NSString *)title color:(NSColor *)color fontSize:(CGFloat)fontSize forControl:(NSControl *)control;
+ (void)setTitle:(NSString *)title color:(NSColor *)color forControl:(NSControl *)control;

#pragma mark - Checking

+ (BOOL)isEmptyObject:(id)obj;

#pragma mark - String

+ (NSSize)sizeOfControl:(NSControl *)control;
+ (NSSize)sizeOfControl:(NSControl *)control withWidth:(CGFloat)width;
+ (CGFloat)heightForWidth:(CGFloat)width string:(NSAttributedString*)string;
+ (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height string:(NSAttributedString*)string;

#pragma mark - Device

+ (NSSize)screenSize;
+ (BOOL)isDarkMode;

#pragma mark - Application utilities

+ (NSString *)getAppPathWithIdentifier:(NSString *)bundleIdentifier;
+ (NSString *)getAppNameWithIdentifier:(NSString *)bundleIdentifier;

#pragma mark - Window utilities

+ (CGWindowLevel)windowLevelDesktop;
+ (CGWindowLevel)windowLevelBase;
+ (CGWindowLevel)windowLevelNormal;
+ (CGWindowLevel)windowLevelSetting;
+ (CGWindowLevel)windowLevelUtility;
+ (CGWindowLevel)windowLevelHigh;
+ (CGWindowLevel)windowLevelAlert;

@end
