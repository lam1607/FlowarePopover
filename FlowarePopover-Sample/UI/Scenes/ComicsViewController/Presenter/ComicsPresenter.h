//
//  ComicsPresenter.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ComicsViewProtocols.h"
#import "ComicsPresenterProtocols.h"
#import "ComicRepositoryProtocols.h"

@protocol ComicsViewProtocols;
@protocol ComicRepositoryProtocols;

@interface ComicsPresenter : NSObject <ComicsPresenterProtocols>

@end
