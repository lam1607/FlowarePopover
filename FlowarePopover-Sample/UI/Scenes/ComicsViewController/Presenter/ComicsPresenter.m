//
//  ComicsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicsPresenter.h"

#import "ComicsViewProtocols.h"
#import "ComicRepositoryProtocols.h"

#import "Comic.h"

@interface ComicsPresenter ()

@property (nonatomic, strong) NSMutableArray<Comic *> *comics;

@end

@implementation ComicsPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData {
    if ([self.repository conformsToProtocol:@protocol(ComicRepositoryProtocols)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            self.comics = [[NSMutableArray alloc] init];
            NSArray<Comic *> *comics = [(id<ComicRepositoryProtocols>)self.repository fetchComics];
            
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
                [self.view reloadViewData];
            });
        });
    }
}

- (NSArray<Comic *> *)data {
    return self.comics;
}

@end
