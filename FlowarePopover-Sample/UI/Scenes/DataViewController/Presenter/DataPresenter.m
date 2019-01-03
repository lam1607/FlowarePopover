//
//  DataPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "DataPresenter.h"

#import "DataViewProtocols.h"
#import "ComicRepositoryProtocols.h"

#import "Comic.h"

@interface DataPresenter ()

@property (nonatomic, strong) NSArray<Comic *> *comics;

@end

@implementation DataPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData {
    if ([self.repository conformsToProtocol:@protocol(ComicRepositoryProtocols)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray<Comic *> *comics = [(id<ComicRepositoryProtocols>)self.repository fetchComics];
            self.comics = [[NSArray alloc] initWithArray:comics];
            
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
