//
//  TrashPresenterProtocols.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef TrashPresenterProtocols_h
#define TrashPresenterProtocols_h

#import "AbstractPresenterProtocols.h"

@protocol TrashPresenterProtocols <AbstractPresenterProtocols>

@optional

/// @property
///

/// Methods
///
- (void)trashObject:(id)object notify:(BOOL)notify;
- (void)trashObject:(id)object forRow:(NSInteger)row notify:(BOOL)notify;

@end

#endif /* TrashPresenterProtocols_h */
