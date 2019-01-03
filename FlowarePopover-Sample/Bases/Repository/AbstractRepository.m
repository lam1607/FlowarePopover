//
//  AbstractRepository.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractRepository.h"

#import "AbstractService.h"

@interface AbstractRepository ()

@property (nonatomic, strong) AbstractService *service;

@end

@implementation AbstractRepository

- (instancetype)init {
    if (self = [super init]) {
        self.service = [[AbstractService alloc] init];
    }
    
    return self;
}

#pragma mark - AbstractRepositoryProtocols implementation

- (void)fetchImageFromUrl:(NSURL *)url completion:(void (^)(NSImage *image))complete {
    [self.service fetchDataFromUrl:url completion:^(NSData *data) {
        if (complete) {
            complete((data != nil) ? [[NSImage alloc] initWithData:data] : nil);
        }
    }];
}

@end
