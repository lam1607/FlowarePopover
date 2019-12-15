//
//  NotificationServiceProtocols.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef NotificationServiceProtocols_h
#define NotificationServiceProtocols_h

@protocol NotificationServiceProtocols <NSObject>

@optional
- (void)registerNotificationObserver:(id)source keyPath:(NSString *)keyPath;
- (void)removeNotificationObserver:(id)source keyPath:(NSString *)keyPath;
- (void)removeAllNotificationObservers;

@end

#endif /* NotificationServiceProtocols_h */
