//
//  FilmCellPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FilmCellViewProtocols.h"
#import "FilmRepositoryProtocols.h"

@protocol FilmCellPresenterProtocols <NSObject>

@property (nonatomic, strong) id<FilmCellViewProtocols> view;
@property (nonatomic, strong) id<FilmRepositoryProtocols> repository;

- (void)attachView:(id<FilmCellViewProtocols>)view repository:(id<FilmRepositoryProtocols>)repository;
- (void)detachView;

- (NSImage *)getFilmImage;
- (void)fetchImageFromDataObject:(Film *)obj;

@end
