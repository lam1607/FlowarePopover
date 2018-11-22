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

@property (nonatomic, strong) NSArray<Film *> *films;

@end

@implementation FilmsPresenter

@synthesize view;
@synthesize repository;

#pragma mark - DataPresenterProtocols implementation

- (void)attachView:(id<FilmsViewProtocols>)view repository:(id<FilmRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
    self.repository = nil;
}

- (void)fetchData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray<Film *> *film = [self.repository fetchFilms];
        self.films = [[NSArray alloc] initWithArray:film];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view reloadDataCollectionView];
        });
    });
}

- (NSArray<Film *> *)data {
    return self.films;
}

@end
