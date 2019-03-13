//
//  NewsRepository.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsRepository.h"

#import "NewsService.h"

#import "News.h"

@interface NewsRepository ()
{
    NewsService *_service;
}

/// @property
///

@end

@implementation NewsRepository

- (instancetype)init
{
    if (self = [super init])
    {
        _service = [[NewsService alloc] init];
    }
    
    return self;
}

#pragma mark - NewsRepositoryProtocols implementation

- (NSArray<News *> *)fetchNews
{
    NSMutableArray *news = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *newsDicts = [_service getMockupDataType:@"news"];
    
    for (NSDictionary *contentDict in newsDicts)
    {
        @autoreleasepool
        {
            News *item = [[News alloc] initWithContent:contentDict];
            [news addObject:item];
        }
    }
    
    return news;
}

@end
