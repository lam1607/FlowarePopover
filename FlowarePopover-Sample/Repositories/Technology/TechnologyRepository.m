//
//  TechnologyRepository.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologyRepository.h"

#import "TechnologyService.h"

#import "Technology.h"

@interface TechnologyRepository ()
{
    TechnologyService *_service;
}

/// @property
///

@end

@implementation TechnologyRepository

- (instancetype)init
{
    if (self = [super init])
    {
        _service = [[TechnologyService alloc] init];
    }
    
    return self;
}

#pragma mark - TechnologyRepositoryProtocols implementation

- (NSArray<Technology *> *)fetchTechnologies
{
    NSMutableArray *technologies = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *technologyDicts = [_service getMockupDataType:@"technology"];
    
    for (NSDictionary *contentDict in technologyDicts)
    {
        @autoreleasepool
        {
            Technology *item = [[Technology alloc] initWithContent:contentDict];
            [technologies addObject:item];
        }
    }
    
    return technologies;
}

@end
