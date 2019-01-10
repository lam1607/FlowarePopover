//
//  AppDelegate.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "AbstractWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSMutableDictionary *entitlementAppStatuses;
@property (nonatomic, strong) NSMutableArray<NSString *> *openedBundleIdentifiers;
@property (nonatomic, strong) NSString *lastBundleIdentifier;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    if (self.entitlementAppStatuses == nil) {
        self.entitlementAppStatuses = [[NSMutableDictionary alloc] init];
    }
    
    self.openedBundleIdentifiers = [[NSMutableArray alloc] init];
    [self.openedBundleIdentifiers addObject:[[NSBundle mainBundle] bundleIdentifier]];
    
    [self observerActivateApplicationNotification];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    [Utils sharedInstance].isApplicationActive = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if ([[AbstractWindowController sharedInstance] windowInDesktopMode]) {
    }
    
    if ([[AbstractWindowController sharedInstance] windowInDesktopMode] && ![self isEntitlementAppFocused]) {
        [[AbstractWindowController sharedInstance] hideOtherAppsExceptThoseInside];
    }
    
    [[AbstractWindowController sharedInstance] activate];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [Utils sharedInstance].isApplicationActive = NO;
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    if ([[AbstractWindowController sharedInstance] windowInDesktopMode]) {
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Observers

- (void)observerActivateApplicationNotification {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification *notif) {
        NSRunningApplication *app = [notif.userInfo objectForKey:NSWorkspaceApplicationKey];
        
        if (![app.bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            if (![self isEntitlementAppForBundleId:app.bundleIdentifier])
            {
                [self.openedBundleIdentifiers removeAllObjects];
            }
            
            self.lastBundleIdentifier = app.bundleIdentifier;
            
            [self validateChildWindowsFloating];
            
            [[AbstractWindowController sharedInstance] performSelectorOnMainThread:@selector(hideChildWindowsOnDeactivate) withObject:nil waitUntilDone:YES];
        }
        else {
            if ([self.openedBundleIdentifiers containsObject:app.bundleIdentifier] == NO) {
                [self.openedBundleIdentifiers addObject:app.bundleIdentifier];
            }
        }
    }];
}

#pragma mark - Entitlement apps handlers

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

- (void)validateChildWindowsFloating {
    BOOL isApplicationOpenedFirst = [[self.openedBundleIdentifiers firstObject] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]];
    BOOL shouldChildWindowsFloat = ((self.openedBundleIdentifiers.count > 0) && [self isEntitlementAppFocused] && isApplicationOpenedFirst);
    
    [Utils sharedInstance].shouldChildWindowsFloat = shouldChildWindowsFloat;
}

@end
