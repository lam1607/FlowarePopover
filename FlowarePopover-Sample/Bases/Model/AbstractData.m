//
//  AbstractData.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface AbstractData ()

/// @property
///
@property (nonatomic, strong) NSMutableDictionary *imageDictionary;

@end

@implementation AbstractData

#pragma mark - Initialize

- (instancetype)initWithContent:(NSDictionary *)contentDict {
    if (self = [super init]) {
        if (![Utils isEmptyObject:contentDict]) {
            NSString *name = [contentDict objectForKey:@"name"];
            NSString *title = [contentDict objectForKey:@"title"];
            NSString *imageUrl = [contentDict objectForKey:@"imageUrl"];
            NSString *pageUrl = [contentDict objectForKey:@"pageUrl"];
            
            if (![Utils isEmptyObject:name]) {
                return [self initWithName:name imageUrl:imageUrl pageUrl:pageUrl];
            }
            
            return [self initWithTitle:title imageUrl:imageUrl pageUrl:pageUrl];
        }
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl {
    if (self = [super init]) {
        self.name = name;
        self.imageUrl = [NSURL URLWithString:imageUrl];
        self.pageUrl = [NSURL URLWithString:pageUrl];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl {
    if (self = [super init]) {
        self.title = title;
        self.imageUrl = [NSURL URLWithString:imageUrl];
        self.pageUrl = [NSURL URLWithString:pageUrl];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)setImage:(NSImage *)image forURL:(NSURL *)url {
    if (self.imageDictionary == nil) {
        self.imageDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (image && ([self.imageDictionary objectForKey:url] == nil)) {
        [self.imageDictionary setObject:image forKey:url];
    }
}

- (NSImage *)getImageForURL:(NSURL *)url {
    return (self.imageDictionary && url) ? [self.imageDictionary objectForKey:url] : nil;
}

@end
