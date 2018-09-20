//
//  NewsPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NewsViewProtocols.h"
#import "NewsRepositoryProtocols.h"

@class News;

@protocol NewsPresenterProtocols <NSObject>

@property (nonatomic, strong) id<NewsViewProtocols> view;
@property (nonatomic, strong) id<NewsRepositoryProtocols> repository;

- (void)attachView:(id<NewsViewProtocols>)view repository:(id<NewsRepositoryProtocols>)repository;
- (void)detachView;

- (void)fetchData;
- (NSArray<News *> *)news;

@end
