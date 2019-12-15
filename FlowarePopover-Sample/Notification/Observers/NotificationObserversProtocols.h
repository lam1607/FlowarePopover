//
//  NotificationObserversProtocols.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef NotificationObserversProtocols_h
#define NotificationObserversProtocols_h

@protocol NotificationObserversProtocols <NSObject>

@optional
- (void)notificationObservers_objectInserted:(NSNotification *)notification;
- (void)notificationObservers_objectUpdated:(NSNotification *)notification;
- (void)notificationObservers_objectDeleted:(NSNotification *)notification;
- (void)notificationObservers_objectTrashed:(NSNotification *)notification;

@end

#endif /* NotificationObserversProtocols_h */
