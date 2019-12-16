//
//  EntitlementsManager.h
//  FLOPopupPrototypes
//
//  Created by Lam Nguyen on 9/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EntitlementsManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *openedBundleIdentifiers;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *entitlementAppBundles;

#pragma mark - Singleton

+ (EntitlementsManager *)sharedInstance;

#pragma mark - Methods

- (void)observeActivationForEntitlementApps;
- (void)handleOtherAppStatesWithArranged:(BOOL)isArranged;

- (BOOL)isApplicationActive;

- (BOOL)isFrontMostBundleIdentifier:(NSString *)bundleIdentifier;
- (void)clearFrontMost:(NSString *)bundleIdentifier;
- (void)addWithBundleIdentifier:(NSString *)bundleIdentifier;
- (void)removeWithBundleIdentifier:(NSString *)bundleIdentifier;
- (void)activateWithBundleIdentifier:(NSString *)bundleIdentifier;
- (void)deactivateWithBundleIdentifier:(NSString *)bundleIdentifier;
- (BOOL)isEntitlementAppForBundleIdentifier:(NSString *)bundleIdentifier;
- (BOOL)isEntitlementAppFocusedForBundleIdentifier:(NSString *)bundleIdentifier;
- (BOOL)isEntitlementAppFocused;
- (BOOL)isFinderAppFocused;

- (void)hideOtherAppsExceptThoseInside;

+ (NSString *)getAppPathWithIdentifier:(NSString *)bundleIdentifier;
+ (NSString *)getAppNameWithIdentifier:(NSString *)bundleIdentifier;
+ (NSString *)getBundleIdentifierForFilePath:(NSString *)path;

@end
