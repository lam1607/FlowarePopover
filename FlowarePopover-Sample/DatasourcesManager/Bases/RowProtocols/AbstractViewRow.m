//
//  AbstractViewRow.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractViewRow.h"

@interface AbstractViewRow () {
    __weak id<ViewRowProtocols> _instance;
    
    NSString *_identifier;
    
    __weak NSObject *_model;
    NSInteger _index;
    
    CGFloat _rowHeight;
}

/// @property
///

@end

@implementation AbstractViewRow

#pragma mark - AbstractViewRowProtocols implementation

/**
 * Create and return an row instance by idenfitier of the view (NSTableCellView, NSCollectionViewItem, or NSView) that conformed to ViewRowProtocols protocol.
 *
 * @param identifier the identifier of the target view. It's also a nib name of the view.
 * @return an row object (CollectionViewRow, TableViewRow, or OutlineViewRow).
 */
- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        _identifier = identifier;
    }
    
    return self;
}

/**
 * Create and return an row instance by idenfitier of the view (NSTableCellView, NSCollectionViewItem, or NSView) that conformed to ViewRowProtocols protocol and its data model.
 *
 * @param identifier the identifier of the target view. It's also a nib name of the view.
 * @param data model used for the target view.
 * @return an row object (CollectionViewRow, TableViewRow, or OutlineViewRow).
 */
- (instancetype)initWithIdentifier:(NSString *)identifier data:(NSObject * _Nonnull)data {
    if (self = [super init]) {
        _identifier = identifier;
        _model = data;
    }
    
    return self;
}

- (id<ViewRowProtocols>)view {
    return _instance;
}

- (NSObject *)data {
    return _model;
}

- (NSString *)identifier {
    return _identifier;
}

- (NSString *)reuseIdentifier {
    return _identifier ? _identifier : NSStringFromClass([_instance class]);
}

- (Class)cellType {
    return [_instance class] ? [_instance class] : NSClassFromString(_identifier);
}

- (NSInteger)index {
    return _index;
}

- (void)setRowHeight:(CGFloat)rowHeight {
    _rowHeight = rowHeight;
}

- (CGFloat)rowHeight {
    return _rowHeight;
}

/// Methods
///
- (void)configure:(id<ViewRowProtocols>)view atIndex:(NSInteger)index {
    _instance = view;
    _index = index;
    
    if (_model && self.view && [self.view respondsToSelector:@selector(updateData:atIndex:)]) {
        [self.view updateData:_model atIndex:index];
    }
}

@end
