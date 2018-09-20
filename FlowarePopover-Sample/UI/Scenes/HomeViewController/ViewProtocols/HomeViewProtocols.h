//
//  HomeViewProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HomeViewProtocols <NSObject>
@optional
- (void)showPopoverAtSender:(NSDictionary *)senderInfo;

@end
