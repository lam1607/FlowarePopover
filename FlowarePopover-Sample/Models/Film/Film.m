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

- (instancetype)initWithContent:(NSDictionary *)contentDict
{
    if (self = [super init])
    {
        if ([contentDict isKindOfClass:[NSDictionary class]])
        {
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
                    imageUrl:(NSString *)imageUrl trailerUrl:(NSString *)trailerUrl
{
    if (self = [super init])
    {
        self.name = name;
        self.releaseDate = releaseDate;
        self.synopsis = synopsis;
        self.imageUrl = imageUrl;
        self.trailerUrl = trailerUrl;
    }
    
    return self;
}

#pragma mark - Override methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n\t<%@: %p>,\n\tname: \"%@\",\n\treleaseDate: %@,\n\timageUrl: \"%@\",\n\ttrailerUrl: \"%@\"\n}", NSStringFromClass([self class]), self, self.name, self.releaseDate, self.imageUrl, self.trailerUrl];
}

@end
