//
//  BaseRepository.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "BaseRepository.h"

#import "BaseService.h"

@interface BaseRepository ()

@property (nonatomic, strong) BaseService *_service;

@end

@implementation BaseRepository

- (instancetype)init {
    if (self = [super init]) {
        self._service = [[BaseService alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark - BaseRepositoryProtocols implementation
#pragma mark -
- (void)fetchImageFromUrl:(NSURL *)url completion:(void (^)(NSImage *image))complete {
    [self._service fetchDataFromUrl:url completion:^(NSData *data) {
        if (complete) {
            complete((data != nil) ? [[NSImage alloc] initWithData:data] : nil);
        }
    }];
}

@end
