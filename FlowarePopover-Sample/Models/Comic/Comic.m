//
//  Comic.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "Comic.h"

@implementation Comic

#pragma mark - Initialize

- (instancetype)initWithContent:(NSDictionary *)contentDict
{
    if (self = [super init])
    {
        if ([contentDict isKindOfClass:[NSDictionary class]])
        {
            NSString *name = [contentDict objectForKey:@"name"];
            NSString *shortDesc = [contentDict objectForKey:@"shortDesc"];
            NSString *longDesc = [contentDict objectForKey:@"longDesc"];
            NSString *imageUrl = [contentDict objectForKey:@"imageUrl"];
            NSString *pageUrl = [contentDict objectForKey:@"pageUrl"];
            
            self = [self initWithName:name imageUrl:imageUrl pageUrl:pageUrl];
            self.shortDesc = shortDesc;
            self.longDesc = longDesc;
        }
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name shortDesc:(NSString *)shortDesc longDesc:(NSString *)longDesc
                    imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl
{
    if (self = [super init])
    {
        self.name = name;
        self.shortDesc = shortDesc;
        self.longDesc = longDesc;
        self.imageUrl = imageUrl;
        self.pageUrl = pageUrl;
    }
    
    return self;
}

#pragma mark - ListSupplierProtocol implementation

- (__unsafe_unretained id<ListSupplierProtocol>)parent
{
    return (id<ListSupplierProtocol>)self.parentItem;
}

- (__unsafe_unretained NSMutableArray<id<ListSupplierProtocol>> *)childs
{
    return (NSMutableArray<id<ListSupplierProtocol>> *)self.subItems;
}

#pragma mark - Override methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n\t<%@: %p>,\n\tname: \"%@\",\n\timageUrl: \"%@\",\n\tpageUrl: \"%@\"\n}", NSStringFromClass([self class]), self, self.name, self.imageUrl, self.pageUrl];
}

@end
