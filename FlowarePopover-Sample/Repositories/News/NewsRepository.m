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

/// @property
///
@property (nonatomic, strong) NewsService *service;

@end

@implementation NewsRepository

- (instancetype)init {
    if (self = [super init]) {
        self.service = [[NewsService alloc] init];
    }
    
    return self;
}

#pragma mark - NewsRepositoryProtocols implementation

- (NSArray<News *> *)fetchNews {
    NSMutableArray *news = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *newsDicts = [self.service getMockupDataType:@"news"];
    
    for (NSDictionary *contentDict in newsDicts) {
        @autoreleasepool {
            News *item = [[News alloc] initWithContent:contentDict];
            [news addObject:item];
        }
    }
    
    return news;
}

@end
