//
//  AbstractPresenter.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractViewProtocols.h"
#import "AbstractPresenterProtocols.h"

@protocol AbstractViewProtocols;

@interface AbstractPresenter : NSObject <AbstractPresenterProtocols>

@end
