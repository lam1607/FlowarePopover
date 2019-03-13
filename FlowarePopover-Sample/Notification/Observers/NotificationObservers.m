//
//  NotificationObservers.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "NotificationObservers.h"

#import "Notification.h"

@implementation NotificationObservers

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        [self registerForNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Local methods

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_objectInserted:) name:dataChangeNotification.insertNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_objectUpdated:) name:dataChangeNotification.updateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_objectDeleted:) name:dataChangeNotification.deleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_objectTrashed:) name:dataChangeNotification.trashNotification object:nil];
}

#pragma mark - Notifications

- (void)notification_objectInserted:(NSNotification *)notification
{
    if (self.onChangeObservers)
    {
        self.onChangeObservers(@selector(notificationObservers_objectInserted:), notification);
    }
}

- (void)notification_objectUpdated:(NSNotification *)notification
{
    if (self.onChangeObservers)
    {
        self.onChangeObservers(@selector(notificationObservers_objectUpdated:), notification);
    }
}

- (void)notification_objectDeleted:(NSNotification *)notification
{
    if (self.onChangeObservers)
    {
        self.onChangeObservers(@selector(notificationObservers_objectDeleted:), notification);
    }
}

- (void)notification_objectTrashed:(NSNotification *)notification
{
    if (self.onChangeObservers)
    {
        self.onChangeObservers(@selector(notificationObservers_objectTrashed:), notification);
    }
}

@end
