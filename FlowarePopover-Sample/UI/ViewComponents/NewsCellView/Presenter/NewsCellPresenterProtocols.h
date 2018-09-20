//
//  NewsCellPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NewsCellViewProtocols.h"
#import "NewsRepositoryProtocols.h"

@protocol NewsCellPresenterProtocols <NSObject>

@property (nonatomic, strong) id<NewsCellViewProtocols> view;
@property (nonatomic, strong) id<NewsRepositoryProtocols> repository;

- (void)attachView:(id<NewsCellViewProtocols>)view repository:(id<NewsRepositoryProtocols>)repository;
- (void)detachView;

- (NSImage *)getNewsImage;
- (void)fetchImageFromDataObject:(News *)obj;

@end
