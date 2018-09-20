//
//  BaseRepositoryProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseRepositoryProtocols <NSObject>

- (void)fetchImageFromUrl:(NSURL *)url completion:(void (^)(NSImage *image))complete;

@end
