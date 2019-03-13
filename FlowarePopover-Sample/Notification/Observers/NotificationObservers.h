//
//  NotificationObservers.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "NotificationObserversProtocols.h"

@interface NotificationObservers : NSObject <NotificationObserversProtocols>

@property (nonatomic, copy) void(^onChangeObservers)(SEL selector, NSNotification *notification);

@end
