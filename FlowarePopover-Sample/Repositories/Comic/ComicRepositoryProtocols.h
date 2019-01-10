//
//  ComicRepositoryProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractRepositoryProtocols.h"

@class Comic;

@protocol ComicRepositoryProtocols <AbstractRepositoryProtocols>

- (NSArray<Comic *> *)fetchComics;

@end
