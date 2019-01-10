//
//  OutlineViewRow.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "OutlineViewRow.h"

@interface OutlineViewRow () {
    NSMutableArray<OutlineViewRow *> *_childRows;
}

/// @property
///

@end

@implementation OutlineViewRow

#pragma mark - OutlineViewRowProtocols implementation

- (BOOL)hasChildren {
    return _childRows.count > 0;
}

- (void)setChildRows:(NSMutableArray<OutlineViewRow *> *)childRows {
    _childRows = childRows;
}

- (NSMutableArray<OutlineViewRow *> *)childRows {
    if (_childRows == nil) {
        _childRows = [[NSMutableArray alloc] init];
    }
    
    return _childRows;
}

@end
