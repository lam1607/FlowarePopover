//
//  CollectionViewRow.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "CollectionViewRow.h"

@interface CollectionViewRow () {
    NSSize _estimatedItemSize;
}

@end

@implementation CollectionViewRow

#pragma mark - CollectionViewRowProtocols implementation

- (void)setEstimatedItemSize:(NSSize)estimatedItemSize {
    _estimatedItemSize = estimatedItemSize;
}

- (NSSize)estimatedItemSize {
    return _estimatedItemSize;
}

@end
