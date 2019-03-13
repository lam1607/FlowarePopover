//
//  ComicRepository.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicRepository.h"

#import "ComicService.h"

#import "Comic.h"

@interface ComicRepository ()
{
    ComicService *_service;
}

/// @property
///

@end

@implementation ComicRepository

- (instancetype)init
{
    if (self = [super init])
    {
        _service = [[ComicService alloc] init];
    }
    
    return self;
}

#pragma mark - ComicRepositoryProtocols implementation

- (NSArray<Comic *> *)fetchComics
{
    NSMutableArray *comics = [[NSMutableArray alloc] init];
    NSArray<NSDictionary *> *comicDicts = [_service getMockupDataType:@"comics"];
    
    for (NSDictionary *contentDict in comicDicts)
    {
        @autoreleasepool
        {
            Comic *item = [[Comic alloc] initWithContent:contentDict];
            [comics addObject:item];
        }
    }
    
    return comics;
}

@end
