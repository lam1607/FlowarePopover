//
//  NewsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsPresenter.h"

#import "NewsViewProtocols.h"
#import "NewsRepositoryProtocols.h"

#import "News.h"

@interface NewsPresenter ()

@property (nonatomic, strong) NSArray<News *> *news;

@end

@implementation NewsPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData {
    if ([self.repository conformsToProtocol:@protocol(NewsRepositoryProtocols)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray<News *> *news = [(id<NewsRepositoryProtocols>)self.repository fetchNews];
            self.news = [[NSArray alloc] initWithArray:news];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view reloadViewData];
            });
        });
    }
}

- (NSArray<News *> *)data {
    return self.news;
}

@end
