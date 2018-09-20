//
//  NewsCellPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsCellPresenter.h"

#import "News.h"

@interface NewsCellPresenter ()

@property (nonatomic, strong) NSImage *_image;

@end

@implementation NewsCellPresenter

@synthesize view;
@synthesize repository;

#pragma mark -
#pragma mark - DataCellPresenterProtocols implementation
#pragma mark -
- (void)attachView:(id<NewsCellViewProtocols>)view repository:(id<NewsRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
}

- (NSImage *)getNewsImage {
    return self._image;
}

- (void)fetchImageFromDataObject:(News *)obj {
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
