//
//  AbstractRepositoryProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef AbstractRepositoryProtocols_h
#define AbstractRepositoryProtocols_h

#import <Foundation/Foundation.h>

@protocol AbstractRepositoryProtocols <NSObject>

- (void)fetchImageFromUrl:(NSURL *)url completion:(void (^)(NSImage *image))complete;

@end

#endif /* AbstractRepositoryProtocols_h */
