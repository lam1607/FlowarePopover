//
//  HomePresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HomeViewProtocols.h"

@protocol HomePresenterProtocols <NSObject>

@property (nonatomic, strong) id<HomeViewProtocols> view;

- (void)attachView:(id<HomeViewProtocols>)view;
- (void)detachView;

- (void)doSelectSender:(NSDictionary *)senderInfo;

@end
