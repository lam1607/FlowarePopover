//
//  FilmsPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FilmsViewProtocols.h"
#import "FilmRepositoryProtocols.h"

@class Film;

@protocol FilmsPresenterProtocols <NSObject>

@property (nonatomic, strong) id<FilmsViewProtocols> view;
@property (nonatomic, strong) id<FilmRepositoryProtocols> repository;

- (void)attachView:(id<FilmsViewProtocols>)view repository:(id<FilmRepositoryProtocols>)repository;
- (void)detachView;

- (void)fetchData;
- (NSArray<Film *> *)films;

@end
