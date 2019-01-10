//
//  TechnologiesPresenter.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologiesPresenter.h"

#import "TechnologiesViewProtocols.h"
#import "TechnologyRepositoryProtocols.h"

#import "Technology.h"

@interface TechnologiesPresenter ()

/// @property
///
@property (nonatomic, strong) NSArray<Technology *> *technologies;

@end

@implementation TechnologiesPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData {
    if ([self.repository conformsToProtocol:@protocol(TechnologyRepositoryProtocols)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray<Technology *> *technologies = [(id<TechnologyRepositoryProtocols>)self.repository fetchTechnologies];
            self.technologies = [[NSArray alloc] initWithArray:technologies];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view reloadViewData];
            });
        });
    }
}

- (NSArray<Technology *> *)data {
    return self.technologies;
}

@end
