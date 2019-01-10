//
//  AbstractPresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef AbstractPresenterProtocols_h
#define AbstractPresenterProtocols_h

#import <Foundation/Foundation.h>

#import "AbstractViewProtocols.h"
#import "AbstractRepositoryProtocols.h"

@class AbstractData;

@protocol AbstractPresenterProtocols <NSObject>

@optional

/// @property
///
@property (nonatomic, strong) id<AbstractViewProtocols> view;
@property (nonatomic, strong) id<AbstractRepositoryProtocols> repository;

/// View attachment/detachment
///
- (void)attachView:(id<AbstractViewProtocols>)view;
- (void)attachView:(id<AbstractViewProtocols>)view repository:(id<AbstractRepositoryProtocols>)repository;
- (void)detachView;
- (void)detachViewRepository;

/// Methods
///
- (void)fetchData;
- (NSArray<AbstractData *> *)data;
- (NSImage *)fetchedImage;
- (void)fetchImageFromData:(AbstractData *)obj;

@end

#endif /* AbstractPresenterProtocols_h */
