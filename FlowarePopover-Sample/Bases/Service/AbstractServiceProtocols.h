//
//  AbstractServiceProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef AbstractServiceProtocols_h
#define AbstractServiceProtocols_h

#import <Foundation/Foundation.h>

@protocol AbstractServiceProtocols <NSObject>

@optional
- (void)fetchDataFromUrl:(NSURL *)url completion:(void (^)(NSData *data))complete;
- (NSArray<NSDictionary *> *)getMockupDataType:(NSString *)mockType;

@end

#endif /* AbstractServiceProtocols_h */
