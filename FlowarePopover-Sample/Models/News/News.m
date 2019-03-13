//
//  News.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "News.h"

@implementation News

#pragma mark - Initialize

- (instancetype)initWithContent:(NSDictionary *)contentDict
{
    if (self = [super init])
    {
        if ([contentDict isKindOfClass:[NSDictionary class]])
        {
            NSString *title = [contentDict objectForKey:@"title"];
            NSString *content = [contentDict objectForKey:@"content"];
            NSString *imageUrl = [contentDict objectForKey:@"imageUrl"];
            NSString *pageUrl = [contentDict objectForKey:@"pageUrl"];
            
            self = [self initWithTitle:title imageUrl:imageUrl pageUrl:pageUrl];
            self.content = content;
        }
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl
{
    if (self = [super init])
    {
        self.title = title;
        self.content = content;
        self.imageUrl = imageUrl;
        self.pageUrl = pageUrl;
    }
    
    return self;
}

#pragma mark - Override methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n\t<%@: %p>,\n\ttitle: \"%@\",\n\timageUrl: \"%@\",\n\tpageUrl: \"%@\"\n}", NSStringFromClass([self class]), self, self.title, self.imageUrl, self.pageUrl];
}

@end
