//
//  NSObject+Extensions.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/8/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+Extensions.h"

@implementation NSObject (Extensions)

#pragma mark - Local methods

- (NSArray<NSString *> *)propertiesOfClass:(Class)class
{
    @autoreleasepool
    {
        NSMutableArray<NSString *> *propertyList = [[NSMutableArray alloc] init];
        
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; ++i)
        {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            [propertyList addObject:[NSString stringWithUTF8String:name]];
        }
        
        free(properties);
        
        return propertyList;
    }
}

- (void)properties:(NSMutableArray **)propertyList ofClass:(Class)class
{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i)
    {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [*propertyList addObject:[NSString stringWithUTF8String:name]];
    }
    
    free(properties);
}

#pragma mark - Model object parsing

- (NSArray<NSString *> *)properties
{
    @autoreleasepool
    {
        NSMutableArray<NSString *> *propertyList = [[NSMutableArray alloc] init];
        
        Class observed = [self class];
        
        while ([observed class] != [NSObject class])
        {
            [self properties:&propertyList ofClass:observed];
            
            observed = [observed superclass];
        }
        
        [propertyList removeObjectsInArray:[self propertiesOfClass:[NSObject class]]];
        
        return propertyList;
    }
}

- (void)setPropertiesWithInfoValues:(NSDictionary *)info
{
    if (![self isKindOfClass:[NSObject class]] || ![info isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    NSArray *properties = [self properties];
    NSObject *object = (NSObject *)self;
    
    for (NSString *property in properties)
    {
        @try
        {
            [object setValue:[info valueForKey:property] forKey:property];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }
}

- (void)decode:(NSCoder *)decoder
{
    if (![decoder isKindOfClass:[NSCoder class]] || ![self isKindOfClass:[NSObject class]])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    NSArray *properties = [self properties];
    NSObject *object = (NSObject *)self;
    
    for (NSString *property in properties)
    {
        @try
        {
            [object setValue:[decoder decodeObjectForKey:property] forKey:property];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }
}

- (void)encode:(NSCoder *)encoder
{
    if (![encoder isKindOfClass:[NSCoder class]] || ![self isKindOfClass:[NSObject class]])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    NSArray *properties = [self properties];
    NSObject *object = (NSObject *)self;
    
    for (NSString *property in properties)
    {
        @try
        {
            [encoder encodeObject:[object valueForKey:property] forKey:property];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }
}

- (void)copy:(NSObject *)object zone:(NSZone *)zone
{
    if (![self isKindOfClass:[NSObject class]] || ![object isKindOfClass:[NSObject class]])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    if ([self class] != [object class])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    NSArray *properties = [self properties];
    
    for (NSString *property in properties)
    {
        @try
        {
            if ([[object valueForKey:property] respondsToSelector:@selector(copyWithZone:)])
            {
                [self setValue:[[object valueForKey:property] copyWithZone:zone] forKey:property];
            }
            else
            {
                [self setValue:[object valueForKey:property] forKey:property];
            }
        }
        @catch (NSException *exception)
        {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }
}

- (void)mutableCopy:(NSObject *)object zone:(NSZone *)zone
{
    if (![self isKindOfClass:[NSObject class]] || ![object isKindOfClass:[NSObject class]])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    if ([self class] != [object class])
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    NSArray *properties = [self properties];
    
    for (NSString *property in properties)
    {
        @try
        {
            if ([[object valueForKey:property] respondsToSelector:@selector(mutableCopyWithZone:)])
            {
                [self setValue:[[object valueForKey:property] mutableCopyWithZone:zone] forKey:property];
            }
            else
            {
                [self setValue:[object valueForKey:property] forKey:property];
            }
        }
        @catch (NSException *exception)
        {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }
}

#pragma mark - Object validation

+ (BOOL)isEmpty:(id)object
{
    if (([object isKindOfClass:[NSNull class]]) || ([object isEqual:[NSNull null]]) || (object == nil))
    {
        return YES;
    }
    else
    {
        if ([object isKindOfClass:[NSString class]])
        {
            NSString *string = (NSString *)object;
            
            if (string.length == 0 || [string isKindOfClass:[NSNull class]] || (string == nil) ||
                [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>" ] || [string isEqualToString:@"null"] ||
                [string isEqualToString:@""] ||
                [[string stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
