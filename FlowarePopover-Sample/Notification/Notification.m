//
//  Notification.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "Notification.h"

struct DataChangeNotification dataChangeNotification =
{
    .insertNotification = @"dataChangeNotification.insert",
    .updateNotification = @"dataChangeNotification.update",
    .deleteNotification = @"dataChangeNotification.delete",
    .trashNotification = @"dataChangeNotification.trash"
};

@implementation Notification

+ (void)postNotificationName:(NSString *)name object:(id)object
{
    NSNotification *notification = [NSNotification notificationWithName:name object:object];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    NSNotification *notification = [NSNotification notificationWithName:name object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

@end
