//
//  AppDelegate.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "BaseWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSMutableDictionary *_entitlementAppStatuses;
@property (nonatomic, strong) NSString *_lastBundleIdentifier;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    if (self._entitlementAppStatuses == nil) {
        self._entitlementAppStatuses = [[NSMutableDictionary alloc] init];
    }
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification *notif) {
        NSRunningApplication *app = [notif.userInfo objectForKey:NSWorkspaceApplicationKey];
        
        if (![app.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            if ([[BaseWindowController sharedInstance] windowInDesktopMode]) {
                self._lastBundleIdentifier = app.bundleIdentifier;
                
                [[BaseWindowController sharedInstance] hideChildenWindowsOnDeactivate];
                
                if ([self isEntitlementAppFocused]) {
                    [[BaseWindowController sharedInstance] hideOtherAppsExceptThoseInside];
                }
            }
        }
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    if ([[BaseWindowController sharedInstance] windowInDesktopMode]) {
        [[BaseWindowController sharedInstance] hideChildenWindowsOnDeactivate];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if ([[BaseWindowController sharedInstance] windowInDesktopMode]) {
        [[BaseWindowController sharedInstance] showChildenWindowsOnActivate];
    }
    
    [[BaseWindowController sharedInstance] activate];
    
    if ([[BaseWindowController sharedInstance] windowInDesktopMode] && ![self isEntitlementAppFocused]) {
        [[BaseWindowController sharedInstance] hideOtherAppsExceptThoseInside];
    }
}

#pragma mark - BundleIdentifier from entitlement apps

- (void)addEntitlementBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    // Yes: entitlement app has been activated
    // NO: entitlemnt app has been inactivated
    if (self._entitlementAppStatuses == nil) {
        self._entitlementAppStatuses = [[NSMutableDictionary alloc] init];
    }
    
    [self._entitlementAppStatuses setObject:[NSNumber numberWithBool:NO] forKey:bundleId];
}

- (void)removeEntitlementBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    
    [self._entitlementAppStatuses removeObjectForKey:bundleId];
}

- (void)activateEntitlementForBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    
    NSNumber *obj = [self._entitlementAppStatuses objectForKey:bundleId];
    
    if (obj != nil) {
        BOOL status = [obj boolValue];
        
        if (status == NO) {
            [self._entitlementAppStatuses setObject:[NSNumber numberWithBool:YES] forKey:bundleId];
        }
    }
}

- (void)inactivateEntitlementForBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    
    NSNumber *obj = [self._entitlementAppStatuses objectForKey:bundleId];
    
    if (obj != nil) {
        BOOL status = [obj boolValue];
        
        if (status == YES) {
            [self._entitlementAppStatuses setObject:[NSNumber numberWithBool:NO] forKey:bundleId];
        }
    }
}

- (BOOL)isEntitlementAppForBundleId:(NSString *)bundleId {
    if (!bundleId.length) return NO;
    
    return ([self._entitlementAppStatuses objectForKey:bundleId] != nil) ? YES : NO;
}

- (BOOL)isEntitlementAppFocusedForBundleId:(NSString *)bundleId {
    BOOL result = [self isEntitlementAppForBundleId:bundleId];
    
    if (!result) return NO;
    
    NSNumber *obj = [self._entitlementAppStatuses objectForKey:bundleId];
    
    if (obj != nil) {
        result = [obj boolValue];
    }
    
    return result;
}

- (BOOL)isEntitlementAppFocused {
    return [self isEntitlementAppFocusedForBundleId:self._lastBundleIdentifier];
}

- (BOOL)isFinderAppFocused {
    return [self._lastBundleIdentifier isEqualToString:FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER];
}

@end
