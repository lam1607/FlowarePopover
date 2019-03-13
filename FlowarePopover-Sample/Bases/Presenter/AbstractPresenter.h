//
//  AbstractPresenter.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractPresenterProtocols.h"

#import "AbstractViewProtocols.h"

#import "NotificationObserversProtocols.h"
#import "NotificationService.h"

#import "DataProvider.h"
#import "ListSupplierProtocol.h"

@interface AbstractPresenter : NSObject <AbstractPresenterProtocols, NotificationObserversProtocols, DataProviderProtocols>

@end
