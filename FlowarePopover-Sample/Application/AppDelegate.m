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

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[EntitlementsManager sharedInstance] observeActivationForEntitlementApps];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ([[SettingsManager sharedInstance] isDesktopMode] && ![[EntitlementsManager sharedInstance] isEntitlementAppFocused])
    {
        [EntitlementsManager hideOtherAppsExceptThoseInWorkspace];
    }
    
    [[AbstractWindowController sharedInstance] activate];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

#pragma mark - AppDelegate methods

- (void)setMenuItemsEnabled:(BOOL)isEnabled
{
    NSMenu *menu = [NSApplication sharedApplication].menu;
    NSArray<NSMenuItem *> *itemArray = menu.itemArray;
}

@end
