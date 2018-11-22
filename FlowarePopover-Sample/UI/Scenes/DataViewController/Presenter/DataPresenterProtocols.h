//
//  DataPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataViewProtocols.h"
#import "ComicRepositoryProtocols.h"

@class Comic;

@protocol DataPresenterProtocols <NSObject>

@property (nonatomic, strong) id<DataViewProtocols> view;
@property (nonatomic, strong) id<ComicRepositoryProtocols> repository;

- (void)attachView:(id<DataViewProtocols>)view repository:(id<ComicRepositoryProtocols>)repository;
- (void)detachView;

- (void)fetchData;
- (NSArray<Comic *> *)data;

@end
