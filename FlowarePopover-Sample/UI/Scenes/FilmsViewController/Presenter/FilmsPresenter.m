//
//  FilmsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmsPresenter.h"

#import "FilmsViewProtocols.h"
#import "FilmRepositoryProtocols.h"

#import "Film.h"

@interface FilmsPresenter ()

@property (nonatomic, strong) NSArray<Film *> *films;

@end

@implementation FilmsPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData {
    if ([self.repository conformsToProtocol:@protocol(FilmRepositoryProtocols)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray<Film *> *film = [(id<FilmRepositoryProtocols>)self.repository fetchFilms];
            self.films = [[NSArray alloc] initWithArray:film];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view reloadViewData];
            });
        });
    }
}

- (NSArray<Film *> *)data {
    return self.films;
}

@end
