//
//  FilmRepository.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmRepository.h"

#import "FilmService.h"

#import "Film.h"

@interface FilmRepository ()
{
    FilmService *_service;
}

/// @property
///

@end

@implementation FilmRepository

- (instancetype)init
{
    if (self = [super init])
    {
        _service = [[FilmService alloc] init];
    }
    
    return self;
}

#pragma mark - FilmRepositoryProtocols implementation

- (NSArray<Film *> *)fetchFilms
{
    NSMutableArray *films = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *filmDicts = [_service getMockupDataType:@"films"];
    
    for (NSDictionary *contentDict in filmDicts)
    {
        @autoreleasepool
        {
            Film *item = [[Film alloc] initWithContent:contentDict];
            [films addObject:item];
        }
    }
    
    return films;
}

@end
