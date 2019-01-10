//
//  AbstractViewRowProtocols.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef AbstractViewRowProtocols_h
#define AbstractViewRowProtocols_h

#import <Cocoa/Cocoa.h>

#import "ViewRowProtocols.h"

@protocol AbstractViewRowProtocols <NSObject>

@optional

/// @property
///
@property (nonatomic, strong, readonly) id<ViewRowProtocols> view;

@property (nonatomic, strong) NSObject *data;

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *reuseIdentifier;

@property (nonatomic, assign) Class cellType;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) CGFloat rowHeight;

/// Initializes
///
/**
 * Create and return an row instance by idenfitier of the view (NSTableCellView, NSCollectionViewItem, or NSView) that conformed to ViewRowProtocols protocol.
 *
 * @param identifier the identifier of the target view. It's also a nib name of the view.
 * @return an row object (CollectionViewRow, TableViewRow, or OutlineViewRow).
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 * Create and return an row instance by idenfitier of the view (NSTableCellView, NSCollectionViewItem, or NSView) that conformed to ViewRowProtocols protocol and its data model.
 *
 * @param identifier the identifier of the target view. It's also a nib name of the view.
 * @param data model used for the target view.
 * @return an row object (CollectionViewRow, TableViewRow, or OutlineViewRow).
 */
- (instancetype)initWithIdentifier:(NSString *)identifier data:(NSObject * _Nonnull)data;

/// Methods
///
- (void)configure:(id<ViewRowProtocols>)view atIndex:(NSInteger)index;

@end

#endif /* AbstractViewRowProtocols_h */
