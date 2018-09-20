//
//  Utils.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "Utils.h"

#import <objc/runtime.h>

@implementation Utils

#pragma mark -
#pragma mark - Model object parsing
#pragma mark -
+ (NSArray *)propertyNamesOfClass:(Class)class {
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    
    free(properties);
    
    return propertyNames;
}

+ (void)setValuesToPropertiesOfObject:(id<NSObject>)object withInfo:(NSDictionary *)info {
    if ([self isEmptyObject:info] || [self isEmptyObject:object]) {
        return;
    }
    
    NSArray *propertyNames = [self propertyNamesOfClass:[object class]];
    NSObject *_object = (NSObject *) object;
    
    for (NSString *property in propertyNames) {
        if (![self isEmptyObject:[info valueForKey:property]]) {
            id value = [info valueForKey:property];
            
            if (![self isEmptyObject:value]) {
                [_object setValue:value forKey:property];
            }
        }
    }
}

+ (void)decode:(NSCoder *)decoder object:(id<NSObject>)object {
    if ([self isEmptyObject:decoder] || [self isEmptyObject:object]) {
        return;
    }
    
    NSArray *propertyNames = [self propertyNamesOfClass:[object class]];
    NSObject *_object = (NSObject *) object;
    
    for (NSString *property in propertyNames) {
        [_object setValue:[decoder decodeObjectForKey:property] forKey:property];
    }
}

+ (void)encode:(NSCoder *)encoder object:(id<NSObject>)object {
    if ([self isEmptyObject:encoder] || [self isEmptyObject:object]) {
        return;
    }
    
    NSArray *propertyNames = [self propertyNamesOfClass:[object class]];
    NSObject *_object = (NSObject *) object;
    
    for (NSString *property in propertyNames) {
        [encoder encodeObject:[_object valueForKey:property] forKey:property];
    }
}

+ (void)copy:(NSObject *)copy from:(NSObject *)object withZone:(NSZone *)zone {
    if ([self isEmptyObject:copy] || [self isEmptyObject:object]) {
        return;
    }
    
    if ([copy class] != [object class]) {
        return;
    }
    
    NSArray *propertyNames = [self propertyNamesOfClass:[copy class]];
    
    for (NSString *property in propertyNames) {
        [copy setValue:[[object valueForKey:property] copyWithZone:zone] forKey:property];
    }
}

#pragma mark -
#pragma mark - Localizable & language
#pragma mark -
+ (BOOL)isEnglishLanguage {
        // Format is Lang - Region
    NSString *fullString = [[NSLocale preferredLanguages] firstObject];
    NSMutableArray *langAndRegion = [NSMutableArray arrayWithArray:[fullString componentsSeparatedByString:DASH]];
    NSString *language = fullString;
    
    if (langAndRegion.count > 0) {
            // Language is the first item - Region is the last item
        language = [langAndRegion objectAtIndex:0];
    }
    
    return [language isEqualToString:LANGUAGE_CODE_ENGLISH];
}

#pragma mark -
#pragma mark - Format view
#pragma mark -
+ (void)setViewTransparent:(NSView *)view withBackgroundColor:(NSColor *)color {
    view.layer.backgroundColor = [[color colorWithAlphaComponent:COLOR_ALPHA] CGColor];
}

+ (void)setShadowForView:(NSView *)view {
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:[NSColor lightGrayColor]];
    [dropShadow setShadowOffset:NSMakeSize(-1.0f, 1.0f)];
    [dropShadow setShadowBlurRadius:[CORNER_RADIUSES[0] doubleValue]];
    
    [view setWantsLayer:YES];
    [view setShadow:dropShadow];
}

#pragma mark -
#pragma mark - Checking
#pragma mark -
+ (BOOL)isEmptyObject:(id)obj {
    if (([obj isKindOfClass:[NSNull class]]) || ([obj isEqual:[NSNull null]]) || (obj == nil)) {
        return YES;
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *) obj;
        
        if (string.length == 0 || [string isKindOfClass:[NSNull class]] || (string == nil) ||
            [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>" ] || [string isEqualToString:@"null"] ||
            [string isEqualToString:EMPTY_STRING] ||
            [[string stringByReplacingOccurrencesOfString:WHITESPACE withString:EMPTY_STRING] isEqualToString:EMPTY_STRING]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -
#pragma mark - Validations
#pragma mark -
+ (BOOL)isValidEmail:(NSString *)email {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *regex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:email];
}

+ (BOOL)isValidPassword:(NSString *)password {
    NSString *regex = @"^.*(?=.{6,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:password];
}

#pragma mark -
#pragma mark - Date time
#pragma mark -
+ (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *result = [dateFormatter dateFromString:dateStr];
    
    return result;
}

+ (NSString *)stringFromCurrentTimeZoneDate:(NSDate *)currentTimeZoneDate withFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *result = [dateFormatter stringFromDate:currentTimeZoneDate];
    
    return result;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *result = [dateFormatter stringFromDate:date];
    
    return result;
}

#pragma mark -
#pragma mark - String
#pragma mark -
+ (NSString *)uniqueString {
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

+ (NSString *)trimOfString:(NSString *)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSSize)sizeOfControl:(NSControl *)control {
    return [self sizeOfControl:control withWidth:control.frame.size.width];
}

+ (NSSize)sizeOfControl:(NSControl *)control withWidth:(CGFloat)width {
    return [control sizeThatFits:NSMakeSize(width, (CGFloat) SHRT_MAX)];
}

+ (CGFloat)heightForWidth:(CGFloat)width string:(NSAttributedString*)string {
    return [self sizeForWidth:width height:FLT_MAX string:string].height;
}

+ (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height string:(NSAttributedString*)string {
    NSInteger typesetterBehavior = NSTypesetterLatestBehavior;
    NSSize size = NSZeroSize;

    if ([string length] > 0) {
        // Checking for empty string is necessary since Layout Manager will give the nominal
        // height of one line if length is 0.  Our API specifies 0.0 for an empty string.
        NSSize dumpSize = NSMakeSize(width, height);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:dumpSize];
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:string];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        [layoutManager setHyphenationFactor:0.0f];

        if (typesetterBehavior != NSTypesetterLatestBehavior) {
            [layoutManager setTypesetterBehavior:typesetterBehavior];
        }

        // NSLayoutManager is lazy, so we need the following kludge to force layout:
        [layoutManager glyphRangeForTextContainer:textContainer];

        size = [layoutManager usedRectForTextContainer:textContainer].size;

        // Adjust if there is extra height for the cursor
        NSSize extraLineSize = [layoutManager extraLineFragmentRect].size;

        if (extraLineSize.height > 0) {
            size.height -= extraLineSize.height;
        }

        // In case we changed it above, set typesetterBehavior back
        // to the default value.
        typesetterBehavior = NSTypesetterLatestBehavior;
    }

    return size;
}

#pragma mark -
#pragma mark - Device
#pragma mark -
+ (NSSize)screenSize {
    return [[NSScreen mainScreen] frame].size;
}

#pragma mark -
#pragma mark - Application utilities
#pragma mark -
+ (NSString *)getAppPathWithIdentifier:(NSString *)bundleIdentifier {
    NSString *path = nil;
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask];
    NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey, NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
    NSError *error = nil;
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[urls objectAtIndex:0]
                                                   includingPropertiesForKeys:properties
                                                                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
                                                                        error:&error];
    
    if (array != nil) {
        for (NSURL *appUrl in array) {
            NSString *appPath = [appUrl path];
            NSBundle *appBundle = [NSBundle bundleWithPath:appPath];
            
            if ([bundleIdentifier isEqualToString:[appBundle bundleIdentifier]]) {
                path = appPath;
                break;
            }
        }
    }
    
    if (path == nil) {
        path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
    }
    
    return path;
}

+ (NSString *)getAppNameWithIdentifier:(NSString *)bundleIdentifier {
    if (![Utils isEmptyObject:bundleIdentifier]) {
        NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
        path = [Utils getAppPathWithIdentifier:bundleIdentifier];
        
        return [[NSFileManager defaultManager] displayNameAtPath:path];
    }
    
    return nil;
}

@end
