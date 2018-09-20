//
//  FilmsPresenter.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FilmsViewProtocols.h"
#import "FilmsPresenterProtocols.h"
#import "FilmRepositoryProtocols.h"

@protocol FilmsViewProtocols;
@protocol FilmRepositoryProtocols;

@interface FilmsPresenter : NSObject <FilmsPresenterProtocols>

@end
