//
//  Notification.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef Notification_h
#define Notification_h

#import <Foundation/Foundation.h>

typedef struct DataChangeNotification
{
    __unsafe_unretained NSString *insertNotification;
    __unsafe_unretained NSString *updateNotification;
    __unsafe_unretained NSString *deleteNotification;
    __unsafe_unretained NSString *trashNotification;
} DataChangeNotification;

extern struct DataChangeNotification dataChangeNotification;

@interface Notification : NSObject

+ (void)postNotificationName:(NSString *)name object:(id)object;
+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end

#endif /* Notification_h */
