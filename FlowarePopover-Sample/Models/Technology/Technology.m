//
//  Technology.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "Technology.h"

@implementation Technology

#pragma mark - Initialize

- (instancetype)initWithContent:(NSDictionary *)contentDict
{
    if (self = [super init])
    {
        if ([contentDict isKindOfClass:[NSDictionary class]])
        {
            NSString *name = [contentDict objectForKey:@"name"];
            NSString *shortDesc = [contentDict objectForKey:@"shortDesc"];
            NSString *longDesc = [contentDict objectForKey:@"longDesc"];
            NSString *imageUrl = [contentDict objectForKey:@"imageUrl"];
            NSString *pageUrl = [contentDict objectForKey:@"pageUrl"];
            
            self = [self initWithName:name imageUrl:imageUrl pageUrl:pageUrl];
            self.shortDesc = shortDesc;
            self.longDesc = longDesc;
        }
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name shortDesc:(NSString *)shortDesc longDesc:(NSString *)longDesc
                    imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl
{
    if (self = [super init])
    {
        self.name = name;
        self.shortDesc = shortDesc;
        self.longDesc = longDesc;
        self.imageUrl = imageUrl;
        self.pageUrl = pageUrl;
    }
    
    return self;
}

#pragma mark - Override methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n\t<%@: %p>,\n\tname: \"%@\",\n\timageUrl: \"%@\",\n\tpageUrl: \"%@\"\n}", NSStringFromClass([self class]), self, self.name, self.imageUrl, self.pageUrl];
}

@end
