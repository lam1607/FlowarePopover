//
//  Film.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "Film.h"

@implementation Film

#pragma mark - Initialize

- (instancetype)initWithContent:(NSDictionary *)contentDict {
    if (self = [super init]) {
        if (![Utils isEmptyObject:contentDict]) {
            NSString *name = [contentDict objectForKey:@"name"];
            NSString *releaseDate = [contentDict objectForKey:@"releaseDate"];
            NSString *synopsis = [contentDict objectForKey:@"synopsis"];
            NSString *imageUrl = [contentDict objectForKey:@"imageUrl"];
            NSString *trailerUrl = [contentDict objectForKey:@"trailerUrl"];
            
            return [self initWithName:name releaseDate:releaseDate synopsis:synopsis imageUrl:imageUrl trailerUrl:trailerUrl];
        }
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name releaseDate:(NSString *)releaseDate synopsis:(NSString *)synopsis
                    imageUrl:(NSString *)imageUrl trailerUrl:(NSString *)trailerUrl {
    if (self = [super init]) {
        self.name = name;
        self.releaseDate = releaseDate;
        self.synopsis = synopsis;
        self.imageUrl = [NSURL URLWithString:imageUrl];
        self.trailerUrl = [NSURL URLWithString:trailerUrl];
    }
    
    return self;
}

@end
