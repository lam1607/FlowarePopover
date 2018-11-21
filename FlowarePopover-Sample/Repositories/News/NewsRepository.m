//
//  NewsRepository.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsRepository.h"

#import "News.h"
#import "NewsService.h"

@interface NewsRepository ()

@property (nonatomic, strong) NewsService *_service;

@end

@implementation NewsRepository

- (instancetype)init {
    if (self = [super init]) {
        self._service = [[NewsService alloc] init];
    }
    
    return self;
}

#pragma mark - NewsRepositoryProtocols implementation

- (NSArray<News *> *)fetchNews {
    NSMutableArray *news = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *newsDicts = [self._service getMockupDataType:@"news"];
    
    [newsDicts enumerateObjectsUsingBlock:^(NSDictionary *contentDict, NSUInteger idx, BOOL *stop) {
        News *item = [[News alloc] initWithContent:contentDict];
        [news addObject:item];
    }];
    
    return news;
}

@end
