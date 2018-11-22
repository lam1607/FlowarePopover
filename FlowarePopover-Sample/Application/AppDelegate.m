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

@property (nonatomic, strong) NSMutableDictionary *entitlementAppStatuses;
@property (nonatomic, strong) NSString *lastBundleIdentifier;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    if (self.entitlementAppStatuses == nil) {
        self.entitlementAppStatuses = [[NSMutableDictionary alloc] init];
    }
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification *notif) {
        NSRunningApplication *app = [notif.userInfo objectForKey:NSWorkspaceApplicationKey];
        
        if (![app.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            if ([[BaseWindowController sharedInstance] windowInDesktopMode]) {
                self.lastBundleIdentifier = app.bundleIdentifier;
                
                [[BaseWindowController sharedInstance] hideChildWindowsOnDeactivate];
                
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
        [[BaseWindowController sharedInstance] hideChildWindowsOnDeactivate];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if ([[BaseWindowController sharedInstance] windowInDesktopMode]) {
        [[BaseWindowController sharedInstance] showChildWindowsOnActivate];
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
    if (self.entitlementAppStatuses == nil) {
        self.entitlementAppStatuses = [[NSMutableDictionary alloc] init];
    }
    
    [self.entitlementAppStatuses setObject:[NSNumber numberWithBool:NO] forKey:bundleId];
}

- (void)removeEntitlementBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    
    [self.entitlementAppStatuses removeObjectForKey:bundleId];
}

- (void)activateEntitlementForBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    
    NSNumber *obj = [self.entitlementAppStatuses objectForKey:bundleId];
    
    if (obj != nil) {
        BOOL status = [obj boolValue];
        
        if (status == NO) {
            [self.entitlementAppStatuses setObject:[NSNumber numberWithBool:YES] forKey:bundleId];
        }
    }
}

- (void)inactivateEntitlementForBundleId:(NSString *)bundleId {
    if (!bundleId.length) return;
    
    NSNumber *obj = [self.entitlementAppStatuses objectForKey:bundleId];
    
    if (obj != nil) {
        BOOL status = [obj boolValue];
        
        if (status == YES) {
            [self.entitlementAppStatuses setObject:[NSNumber numberWithBool:NO] forKey:bundleId];
        }
    }
}

- (BOOL)isEntitlementAppForBundleId:(NSString *)bundleId {
    if (!bundleId.length) return NO;
    
    return ([self.entitlementAppStatuses objectForKey:bundleId] != nil) ? YES : NO;
}

- (BOOL)isEntitlementAppFocusedForBundleId:(NSString *)bundleId {
    BOOL result = [self isEntitlementAppForBundleId:bundleId];
    
    if (!result) return NO;
    
    NSNumber *obj = [self.entitlementAppStatuses objectForKey:bundleId];
    
    if (obj != nil) {
        result = [obj boolValue];
    }
    
    return result;
}

- (BOOL)isEntitlementAppFocused {
    return [self isEntitlementAppFocusedForBundleId:self.lastBundleIdentifier];
}

- (BOOL)isFinderAppFocused {
    return [self.lastBundleIdentifier isEqualToString:FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER];
}

@end
