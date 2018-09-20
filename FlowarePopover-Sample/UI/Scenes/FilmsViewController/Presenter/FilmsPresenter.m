//
//  FilmsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmsPresenter.h"

#import "Film.h"

@interface FilmsPresenter ()

@property (nonatomic, strong) NSArray<Film *> *_films;

@end

@implementation FilmsPresenter

@synthesize view;
@synthesize repository;

#pragma mark -
#pragma mark - DataPresenterProtocols implementation
#pragma mark -
- (void)attachView:(id<FilmsViewProtocols>)view repository:(id<FilmRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
}

- (void)fetchData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray<Film *> *film = [self.repository fetchFilms];
        self._films = [[NSArray alloc] initWithArray:film];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view reloadDataCollectionView];
        });
    });
}

- (NSArray<Film *> *)films {
    return self._films;
}

@end
