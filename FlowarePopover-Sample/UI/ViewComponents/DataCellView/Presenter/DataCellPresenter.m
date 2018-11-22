//
//  DataCellPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "DataCellPresenter.h"

#import "Comic.h"

@interface DataCellPresenter ()

@property (nonatomic, strong) NSImage *image;

@end

@implementation DataCellPresenter

@synthesize view;
@synthesize repository;

#pragma mark - DataCellPresenterProtocols implementation

- (void)attachView:(id<DataCellViewProtocols>)view repository:(id<ComicRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
    self.repository = nil;
}

- (NSImage *)getComicImage {
    return self.image;
}

- (void)fetchImageFromDataObject:(Comic *)obj {
    if ([obj getImage] == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.repository fetchImageFromUrl:obj.imageUrl completion:^(NSImage *image) {
                self.image = image;
                [obj setImage:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view updateCellViewImage];
                });
            }];
        });
    } else {
        self.image = [obj getImage];
        [self.view updateCellViewImage];
    }
}

@end
