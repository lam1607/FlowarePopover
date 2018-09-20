//
//  AppDelegate.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

#pragma mark -
#pragma mark - BundleIdentifier from entitlement apps
#pragma mark -
- (void)addEntitlementBundleId:(NSString *)bundleId;
- (void)removeEntitlementBundleId:(NSString *)bundleId;
- (void)activateEntitlementForBundleId:(NSString *)bundleId;
- (void)inactivateEntitlementForBundleId:(NSString *)bundleId;
- (BOOL)isEntitlementAppForBundleId:(NSString *)bundleId;
- (BOOL)isEntitlementAppFocusedForBundleId:(NSString *)bundleId;
- (BOOL)isEntitlementAppFocused;
- (BOOL)isFinderAppFocused;

@end

