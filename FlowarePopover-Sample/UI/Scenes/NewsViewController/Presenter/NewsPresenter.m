//
//  NewsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsPresenter.h"

#import "News.h"

@interface NewsPresenter ()

@property (nonatomic, strong) NSArray<News *> *news;

@end

@implementation NewsPresenter

@synthesize view;
@synthesize repository;

#pragma mark - DataPresenterProtocols implementation

- (void)attachView:(id<NewsViewProtocols>)view repository:(id<NewsRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
    self.repository = nil;
}

- (void)fetchData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray<News *> *news = [self.repository fetchNews];
        self.news = [[NSArray alloc] initWithArray:news];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view reloadDataTableView];
        });
    });
}

- (NSArray<News *> *)data {
    return self.news;
}

@end
