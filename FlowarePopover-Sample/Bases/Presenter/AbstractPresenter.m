//
//  AbstractPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractPresenter.h"

#import "AbstractData.h"

@interface AbstractPresenter ()

/// @property
///
@property (nonatomic, strong) NSImage *image;

@end

@implementation AbstractPresenter

@synthesize view;
@synthesize repository;

#pragma mark - AbstractPresenterProtocols implementation

- (void)attachView:(id<AbstractViewProtocols>)view {
    self.view = view;
}

- (void)attachView:(id<AbstractViewProtocols>)view repository:(id<AbstractRepositoryProtocols>)repository {
    self.view = view;
    self.repository = repository;
}

- (void)detachView {
    self.view = nil;
}

- (void)detachViewRepository {
    self.view = nil;
    self.repository = nil;
}

- (NSImage *)fetchedImage {
    return self.image;
}

- (void)fetchImageFromData:(AbstractData *)obj {
    __block AbstractData *object = obj;
    
    if ([obj getImageForURL:obj.imageUrl] == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.repository fetchImageFromUrl:object.imageUrl completion:^(NSImage *image) {
                self.image = image;
                
                [object setImage:image forURL:object.imageUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view updateViewImage];
                });
            }];
        });
    } else {
        self.image = [obj getImageForURL:obj.imageUrl];
        [self.view updateViewImage];
    }
}

@end
