//
//  FilmRepositoryProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractRepositoryProtocols.h"

@class Film;

@protocol FilmRepositoryProtocols <AbstractRepositoryProtocols>

- (NSArray<Film *> *)fetchFilms;

@end
