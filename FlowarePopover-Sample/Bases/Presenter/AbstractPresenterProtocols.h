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
@class DataProvider;
@protocol ListSupplierProtocol;

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
- (void)registerNotificationObservers;
- (void)setupProvider;
- (DataProvider *)provider;
- (void)fetchData;
- (void)clearData;
- (NSArray<AbstractData *> *)data;
- (NSImage *)fetchedImage;
- (void)fetchImageFromData:(AbstractData *)obj;

/// Find object that the represented item is mapped to.
///
- (Class)targetObjectClass;
- (id<ListSupplierProtocol>)findObjectForRepresentedItem:(AbstractData *)representedItem;
- (NSArray<id<ListSupplierProtocol>> *)findObjectsForRepresentedItems:(NSArray *)items;
- (NSArray<id<ListSupplierProtocol>> *)findObjectsForItem:(id)item;

/// Drag/Drop handler
///
- (BOOL)couldDropObject:(id)object;
- (BOOL)couldDropObjects:(NSArray *)objects;
- (void)dropObject:(id)object forRow:(NSInteger)row target:(id<ListSupplierProtocol>)target completion:(void(^)(BOOL finished))complete;

/// Notification observers handler
///
- (void)handleNotificationObserversObjectInserted:(id)object;
- (void)handleNotificationObserversObjectUpdated:(id)object;
- (void)handleNotificationObserversObjectDeleted:(id)object;
- (void)handleNotificationObserversObjectTrashed:(id)object;

@end

#endif /* AbstractPresenterProtocols_h */
