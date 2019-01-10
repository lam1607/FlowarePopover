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

/// @property
///
@property (nonatomic, strong) TechnologyService *service;

@end

@implementation TechnologyRepository

- (instancetype)init {
    if (self = [super init]) {
        self.service = [[TechnologyService alloc] init];
    }
    
    return self;
}

#pragma mark - TechnologyRepositoryProtocols implementation

- (NSArray<Technology *> *)fetchTechnologies {
    NSMutableArray *technologies = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *technologyDicts = [self.service getMockupDataType:@"technology"];
    
    for (NSDictionary *contentDict in technologyDicts) {
        @autoreleasepool {
            Technology *item = [[Technology alloc] initWithContent:contentDict];
            [technologies addObject:item];
        }
    }
    
    return technologies;
}

@end
