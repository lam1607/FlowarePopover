//
//  BaseServiceProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseServiceProtocols <NSObject>

@optional
- (void)fetchDataFromUrl:(NSURL *)url completion:(void (^)(NSData *data))complete;
- (NSArray<NSDictionary *> *)getMockupDataType:(NSString *)mockType;

@end
