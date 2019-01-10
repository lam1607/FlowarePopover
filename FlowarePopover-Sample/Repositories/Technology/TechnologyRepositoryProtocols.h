//
//  TechnologyRepositoryProtocols.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef TechnologyRepositoryProtocols_h
#define TechnologyRepositoryProtocols_h

#import "AbstractRepositoryProtocols.h"

@class Technology;

@protocol TechnologyRepositoryProtocols <AbstractRepositoryProtocols>

- (NSArray<Technology *> *)fetchTechnologies;

@end

#endif /* TechnologyRepositoryProtocols_h */
