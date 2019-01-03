//
//  HomePresenter.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomeViewProtocols.h"
#import "HomePresenterProtocols.h"

#import "AbstractPresenter.h"

@protocol HomeViewProtocols;

@interface HomePresenter : AbstractPresenter <HomePresenterProtocols>

@end

