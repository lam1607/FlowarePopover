//
//  FilmCellPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmCellPresenter.h"

#import "Film.h"

@interface FilmCellPresenter ()

@property (nonatomic, strong) NSImage *_image;

@end

@implementation FilmCellPresenter

@synthesize view;
@synthesize repository;

#pragma mark - FilmCellPresenterProtocols implementation

- (void)attachView:(id<FilmCellViewProtocols>)view repository:(id<FilmRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
}

- (NSImage *)getFilmImage {
    return self._image;
}

- (void)fetchImageFromDataObject:(Film *)obj {
    if ([obj getImage] == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.repository fetchImageFromUrl:obj.imageUrl completion:^(NSImage *image) {
                self._image = image;
                [obj setImage:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view updateCellViewImage];
                });
            }];
        });
    } else {
        self._image = [obj getImage];
        [self.view updateCellViewImage];
    }
}

@end
