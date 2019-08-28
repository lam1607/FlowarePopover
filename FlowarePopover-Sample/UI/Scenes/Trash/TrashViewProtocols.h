//
//  TrashViewProtocols.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef TrashViewProtocols_h
#define TrashViewProtocols_h

#import "AbstractViewProtocols.h"
#import "AbstractPresenterProtocols.h"

///
/// View
@protocol TrashViewProtocols <AbstractViewProtocols>

@end

///
/// Presenter
@protocol TrashPresenterProtocols <AbstractPresenterProtocols>

@optional

/// @property
///

/// Methods
///
- (void)trashObject:(id)object notify:(BOOL)notify;
- (void)trashObject:(id)object forRow:(NSInteger)row notify:(BOOL)notify;

@end

#endif /* TrashViewProtocols_h */
