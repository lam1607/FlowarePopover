//
//  HomePresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomePresenter.h"

@implementation HomePresenter

@synthesize view;

#pragma mark -
#pragma mark - HomePresenterProtocols implementation
#pragma mark -
- (void)attachView:(id<HomeViewProtocols>)view {
    self.view = view;
}

- (void)detachView {
    self.view = nil;
}

- (void)doSelectSender:(NSDictionary *)senderInfo {
    [self.view showPopoverAtSender:senderInfo];
}

@end
