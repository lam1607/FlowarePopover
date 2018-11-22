//
//  ComicsPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ComicsViewProtocols.h"
#import "ComicRepositoryProtocols.h"

@class Comic;

@protocol ComicsPresenterProtocols <NSObject>

@property (nonatomic, strong) id<ComicsViewProtocols> view;
@property (nonatomic, strong) id<ComicRepositoryProtocols> repository;

- (void)attachView:(id<ComicsViewProtocols>)view repository:(id<ComicRepositoryProtocols>)repository;
- (void)detachView;

- (void)fetchData;
- (NSArray<Comic *> *)data;

@end
