//
//  DataCellPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataCellViewProtocols.h"
#import "ComicRepositoryProtocols.h"

@class Comic;

@protocol DataCellPresenterProtocols <NSObject>

@property (nonatomic, strong) id<DataCellViewProtocols> view;
@property (nonatomic, strong) id<ComicRepositoryProtocols> repository;

- (void)attachView:(id<DataCellViewProtocols>)view repository:(id<ComicRepositoryProtocols>)repository;
- (void)detachView;

- (NSImage *)getComicImage;
- (void)fetchImageFromDataObject:(Comic *)obj;

@end
