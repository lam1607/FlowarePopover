//
//  ComicsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicsPresenter.h"

#import "Comic.h"

@interface ComicsPresenter ()

@property (nonatomic, strong) NSMutableArray<Comic *> *comics;

@end

@implementation ComicsPresenter

@synthesize view;
@synthesize repository;

#pragma mark - ComicsPresenterProtocols implementation

- (void)attachView:(id<ComicsViewProtocols>)view repository:(id<ComicRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
    self.repository = nil;
}

- (void)fetchData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.comics = [[NSMutableArray alloc] init];
        NSArray<Comic *> *comics = [self.repository fetchComics];
        
        [comics enumerateObjectsUsingBlock:^(Comic *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx % 5 == 0) {
                obj.subComics = [[NSMutableArray alloc] init];
                [self.comics addObject:obj];
            } else {
                Comic *comic = [self.comics lastObject];
                [comic.subComics addObject:obj];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view reloadDataOutlineView];
        });
    });
}

- (NSArray<Comic *> *)data {
    return self.comics;
}

@end
