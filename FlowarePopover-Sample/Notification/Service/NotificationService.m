//
//  NotificationService.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "NotificationService.h"

#import "NotificationObservers.h"

@interface NotificationService ()
{
    NotificationObservers *_observers;
    NSMutableDictionary *_notifyObservers;
}

@end

@implementation NotificationService

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        _observers = [[NotificationObservers alloc] init];
        _notifyObservers = [[NSMutableDictionary alloc] init];
        
        [self listenNotificationEvents];
    }
    
    return self;
}

#pragma mark - Local methods

- (void)listenNotificationEvents
{
    __weak typeof(self) wself = self;
    
    _observers.onChangeObservers = ^(SEL selector, NSNotification *notification) {
        [wself notifyChangeForSelector:selector notification:notification];
    };
}

- (void)notifyChangeForSelector:(SEL)selector notification:(NSNotification *)notification
{
    [_notifyObservers enumerateKeysAndObjectsUsingBlock:^(id key, NSValue *obj, BOOL *stop) {
        @try
        {
            id owner = [obj nonretainedObjectValue];
            
            if ([owner conformsToProtocol:@protocol(NotificationObserversProtocols)] && [(id<NotificationObserversProtocols>)owner respondsToSelector:selector])
            {
                [(id<NotificationObserversProtocols>)owner performSelector:selector withObject:notification];
            }
        }
        @catch (NSException *exception)
        {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }];
}

#pragma mark - NotificationServiceProtocols implementation

- (void)registerNotificationObserver:(id)source keyPath:(NSString *)keyPath
{
    if ([source isKindOfClass:[NSObject class]] && ([_notifyObservers objectForKey:keyPath] == nil))
    {
        NSValue *value = [NSValue valueWithNonretainedObject:source];
        
        [_notifyObservers setObject:value forKey:keyPath];
    }
}

- (void)removeNotificationObserver:(id)source keyPath:(NSString *)keyPath
{
    if ([source isKindOfClass:[NSObject class]] && (source == [[_notifyObservers objectForKey:keyPath] nonretainedObjectValue]))
    {
        [_notifyObservers removeObjectForKey:keyPath];
    }
}

- (void)removeAllNotificationObservers
{
    [_notifyObservers removeAllObjects];
}

@end
