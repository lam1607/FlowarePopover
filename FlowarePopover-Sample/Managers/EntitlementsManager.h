//
//  EntitlementsManager.h
//  FLOPopupPrototypes
//
//  Created by Lam Nguyen on 9/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static const NSInteger EntitlementsMaximumTryCount                  = 4;
static const NSTimeInterval EntitlementsResizeDelayIntervalDefault  = 0.5;
static const NSTimeInterval EntitlementsResizeDelayIntervalLong     = 1.5;

static const NSString *kAppProcessNameKey                           = @"processName";       // Application Process Name
static const NSString *kAppPIDKey                                   = @"pid";               // Application PID
static const NSString *kWindowName                                  = @"windowName";        // Window name
static const NSString *kWindowBoundsKey                             = @"windowBounds";      // Window Bounds as a string
static const NSString *kWindowIDKey                                 = @"windowID";          // Window ID
static const NSString *kWindowLevelKey                              = @"windowLevel";       // Window Level
static const NSString *kWindowOrderKey                              = @"windowOrder";       // The overall front-to-back ordering of the windows as returned by the window server
static const NSString *kWindowIsOnscreen                            = @"windowOnscreen";
static const NSString *kWindowIsOffScreen                           = @"windowOffScreen";
static const CGFloat kWindowBoundsMinWidth                          = 73.0;
static const CGFloat kWindowBoundsMinHeight                         = 23.0;


@interface ScriptCommand : NSObject

@property (nonatomic, assign) NSRect assignedFrame;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSString *siblingTitle;
@property (nonatomic, strong) NSString *processName;
@property (nonatomic, assign) BOOL autoArrange;

@property (nonatomic, strong) NSString *objectKey;
@property (nonatomic, assign) BOOL applicationDidClose;
@property (nonatomic, assign) NSInteger countRetry;
@property (nonatomic, assign) NSInteger windowID;

@end

@interface EntitlementsManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *openedBundleIdentifiers;

#pragma mark - Singleton

+ (EntitlementsManager *)sharedInstance;

#pragma mark - Methods

- (void)observeActivationForEntitlementApps;

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

- (ScriptCommand *)scriptCommandForKey:(id)key;
- (void)setScriptCommand:(ScriptCommand *)scriptArgs forKey:(id)key;
- (void)removeScriptCommandForKey:(id)key;
- (void)removeScriptCommand:(ScriptCommand *)scriptArgs;
- (void)resizeApplication:(ScriptCommand *)scriptArgs;
- (void)resizeDocument:(ScriptCommand *)scriptArgs;

+ (BOOL)isExceptionApplicationBundle:(NSString *)bundleIdentifier;
/**
 * Get list of CGWindow dictionary with given windowOption.
 *
 * @param windowOption is the CGWindowListOption option that we want to get the CGWindow dictionary respectively.
 * @return A dictionary of specific states of found CGWindow info as following:
 * @{"windowOnscreen": @{@(pid): value, processName: value}, "windowOffScreen": @{@(pid): value, processName: value}}
 */
+ (NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *)getWindowInfosWithOption:(CGWindowListOption)windowOption;
/**
 * Get CGWindow dictionary info for specific application by a given CGWindowListOption.
 *
 * @param processName is the process name or process identifier (pid) of application.
 * @param windowOption is the CGWindowListOption option that want to get CGWindow dictionary for.
 */
+ (NSDictionary *)getWindowInfosForProcess:(NSString *)processName withOption:(CGWindowListOption)windowOption;
/**
 * Check the specific application whose windows are NOT on screen.
 *
 * @param processName is the process name or process identifier (pid) of application.
 */
+ (BOOL)isApplicationWindowsEmpty:(NSString *)processName;
/**
 * Check the specific application whose windows are on screen.
 *
 * @param processName is the process name or process identifier (pid) of application
 */
+ (BOOL)isApplicationWindowOnscreen:(NSString *)processName;
+ (BOOL)shouldResizeEntitledApp:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier onRect:(NSRect)onRect;
+ (NSRect)getFrameForEntitledApp:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier;
+ (void)presentEntitledApp:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier onRect:(NSRect)onRect;
+ (void)presentDocument:(NSString *)path processName:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier onRect:(NSRect)onRect;

+ (void)hideApplication:(NSRunningApplication *)application;
+ (void)hideApplicationWithIdentifier:(NSString *)bundleIdentifier;
+ (void)hideOtherAppsExceptThoseInWorkspace;

+ (NSRunningApplication *)openApplication:(NSString *)processName bundleIdentifier:(NSString *)bundleIdentifier fullPath:(NSString *)fullPath;
+ (BOOL)openApplicationAtPath:(NSString *)fullPath;
+ (NSRunningApplication *)openSystemPreferencesWithSelectedPrivacyTab:(NSString *)privacyTab;
+ (NSRunningApplication *)getRunningApplicationForIdentifier:(NSString *)bundleIdentifier;

+ (NSString *)getAppPathWithIdentifier:(NSString *)bundleIdentifier;
+ (NSString *)getAppNameWithIdentifier:(NSString *)bundleIdentifier;
+ (NSString *)getBundleIdentifierForFilePath:(NSString *)path;

+ (OSStatus)checkAEDeterminePermissionForIdentifier:(NSString *)bundleIdentifier;
+ (OSStatus)checkAEDeterminePermissionForIdentifier:(NSString *)bundleIdentifier withAuthorizationPrompt:(BOOL)shouldPrompt;
+ (BOOL)isSystemEventsPrompted;
+ (BOOL)checkSystemEventsEnabled;
+ (BOOL)checkSystemEventsEnabledWithAuthorizationPrompt:(BOOL)shouldPrompt;
+ (BOOL)checkAccessibilityEnabled;
+ (BOOL)checkIfAccessibilityAutomationEnabled;

@end
