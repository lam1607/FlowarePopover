//
//  NewsRepositoryProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractRepositoryProtocols.h"

@class News;

@protocol NewsRepositoryProtocols <AbstractRepositoryProtocols>

- (NSArray<News *> *)fetchNews;

@end
