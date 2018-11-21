//
//  DataPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "DataPresenter.h"

#import "Comic.h"

@interface DataPresenter ()

@property (nonatomic, strong) NSArray<Comic *> *_comics;

@end

@implementation DataPresenter

@synthesize view;
@synthesize repository;

#pragma mark - DataPresenterProtocols implementation

- (void)attachView:(id<DataViewProtocols>)view repository:(id<ComicRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
}

- (void)fetchData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray<Comic *> *comics = [self.repository fetchComics];
        self._comics = [[NSArray alloc] initWithArray:comics];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view reloadDataOutlineView];
        });
    });
}

- (NSArray<Comic *> *)comics {
    return self._comics;
}

@end
