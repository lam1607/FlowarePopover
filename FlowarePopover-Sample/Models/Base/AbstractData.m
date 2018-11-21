//
//  AbstractData.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface AbstractData ()

@property (nonatomic, strong) NSImage *_dataImage;

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

#pragma mark - Processes

- (void)setImage:(NSImage *)image {
    self._dataImage = image;
}

- (NSImage *)getImage {
    return self._dataImage;
}

@end
