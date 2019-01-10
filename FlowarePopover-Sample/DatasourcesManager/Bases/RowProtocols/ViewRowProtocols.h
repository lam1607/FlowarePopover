
//
//  ViewRowProtocols.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef ViewRowProtocols_h
#define ViewRowProtocols_h

#import <Foundation/Foundation.h>

@protocol ViewRowProtocols <NSObject>

@optional
- (void)updateData:(NSObject * _Nonnull)obj atIndex:(NSInteger)index;

@end

#endif /* ViewRowProtocols_h */
