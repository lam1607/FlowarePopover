//
//  NSString+Extensions.m
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)isEmpty
{
    if (([self isKindOfClass:[NSNull class]]) || ([self isEqual:[NSNull null]]) || (self == nil))
    {
        return YES;
    }
    else
    {
        if ([self isKindOfClass:[NSString class]])
        {
            NSString *string = (NSString *)self;
            
            if (string.length == 0 ||
                [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>" ] || [string isEqualToString:@"null"] ||
                [[string stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

/**
 * Remove all whitespace and newline characters contained in string.
 *
 * @return the result without any whitespace and newline characters.
 */
- (NSString *)trimAll
{
    NSString *result = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *parts = [result componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *filtered = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    result = [filtered componentsJoinedByString:@""];
    
    return (result.length == 0) ? @"" : result;
}

/**
 * Remove all unnecessary whitespace and newline characters contained in string.
 *
 * @return the result without any unnecessary whitespace and newline characters.
 */
- (NSString *)trim
{
    NSString *result = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *parts = [result componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *filtered = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    result = [filtered componentsJoinedByString:@" "];
    
    return (result.length == 0) ? @"" : result;
}

/**
 * Remove all unnecessary whitespace characters and newline characters contained in string.
 * Keep the maximum newline characters are two in case of more than two newline characters in string.
 *
 * @return Remove all whitespace characters and unnecessary newline characters contained in string.
 */
- (NSString *)trimWithNewLine
{
    NSString *result = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *parts = [result componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *filtered = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    result = [filtered componentsJoinedByString:@" "];
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    result = [[NSRegularExpression regularExpressionWithPattern:@"[\r\n]{2,}" options:0 error:NULL] stringByReplacingMatchesInString:result
                                                                                                                             options:0
                                                                                                                               range:NSMakeRange(0, [result length])
                                                                                                                        withTemplate:@"\n\n"];
    
    return (result.length == 0) ? @"" : result;
}

@end
