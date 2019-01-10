//
//  AbstractPresenter.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractPresenterProtocols.h"

#import "AbstractViewProtocols.h"

@protocol AbstractViewProtocols;

@interface AbstractPresenter : NSObject <AbstractPresenterProtocols>

@end
