//
//  EntitlementsManager.m
//  FLOPopupPrototypes
//
//  Created by Lam Nguyen on 9/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <AppleScriptObjC/AppleScriptObjC.h>

#import "EntitlementsManager.h"

#import "WindowManager.h"


@interface EntitlementsManager ()
{
    NSArray<NSString *> *_entitlementAppBundles;
    
    NSMutableDictionary *_entitlementAppStates;
    NSMutableArray<NSString *> *_openedBundleIdentifiers;
    NSMutableArray<NSString *> *_otherBundleIdentifiers;
    
    NSString *_lastBundleIdentifier;
}

@end

@implementation EntitlementsManager

#pragma mark - Singleton

+ (EntitlementsManager *)sharedInstance
{
    static EntitlementsManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[EntitlementsManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (NSMutableArray<NSString *> *)openedBundleIdentifiers
{
    return _openedBundleIdentifiers;
}

- (NSArray *)entitlementAppBundles
{
    if (_entitlementAppBundles == nil)
    {
        _entitlementAppBundles = [[NSArray alloc] initWithObjects:kFlowarePopover_BundleIdentifier_Finder, kFlowarePopover_BundleIdentifier_Safari, nil];
    }
    
    return _entitlementAppBundles;
}

#pragma mark - Local methods

- (void)initialize
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    
    _entitlementAppBundles = [[NSArray alloc] initWithObjects:kFlowarePopover_BundleIdentifier_Finder, kFlowarePopover_BundleIdentifier_Safari, nil];
    
    if (_entitlementAppStates == nil)
    {
        _entitlementAppStates = [[NSMutableDictionary alloc] init];
    }
    
    _openedBundleIdentifiers = [[NSMutableArray alloc] init];
    [_openedBundleIdentifiers addObject:[[NSBundle mainBundle] bundleIdentifier]];
    
    [self setupEntitlementAppBundles];
}

- (void)setupEntitlementAppBundles
{
    for (NSString *bundleIdentifier in _entitlementAppBundles)
    {
        [self addWithBundleIdentifier:bundleIdentifier];
    }
}

#pragma mark - EntitlementsManager methods

- (void)observeActivationForEntitlementApps
{
    __weak typeof(self) wself = self;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        if (wself == nil) return;
        
        typeof(self) this = wself;
        
        NSRunningApplication *app = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
        NSString *bundleIdentifier = app.bundleIdentifier;
        
        if ([NSObject isEmpty:bundleIdentifier]) return;
        if ([bundleIdentifier isEqualToString:@"com.apple.TMHelperAgent"]) return;
        
        if (![bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
        {
            this->_lastBundleIdentifier = bundleIdentifier;
            
            if (![self isEntitlementAppForBundleIdentifier:bundleIdentifier])
            {
                [this->_openedBundleIdentifiers removeAllObjects];
            }
            else
            {
                if ([[this->_openedBundleIdentifiers firstObject] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
                {
                    [this->_openedBundleIdentifiers addObject:bundleIdentifier];
                }
            }
            
            [[WindowManager sharedInstance] performSelectorOnMainThread:@selector(hideChildWindows) withObject:nil waitUntilDone:YES];
        }
        else
        {
            if (![this->_openedBundleIdentifiers containsObject:bundleIdentifier])
            {
                [this->_openedBundleIdentifiers addObject:bundleIdentifier];
            }
        }
    }];
}

/// Other running applications handling
///
- (void)handleOtherAppStatesWithArranged:(BOOL)isArranged
{
    @synchronized (_otherBundleIdentifiers)
    {
        if (_otherBundleIdentifiers == nil)
        {
            _otherBundleIdentifiers = [[NSMutableArray alloc] init];
        }
        
        if (isArranged && (_otherBundleIdentifiers.count == 0)) return;
        
        // An easy way to only grab processes which have icons in the Dock is by doing
        // a simple fast enumeration loop and checking each NSRunningApplication's activationPolicy,
        // like so: https://stackoverflow.com/a/26002033
        for (NSRunningApplication *application in [[NSWorkspace sharedWorkspace] runningApplications])
        {
            NSString *bundleIdentifier = [application bundleIdentifier];
            
            if ([application activationPolicy] == NSApplicationActivationPolicyRegular)
            {
                if (!isArranged)
                {
                    if (![application isHidden] && ![bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
                    {
                        if (![self isEntitlementAppFocusedForBundleIdentifier:bundleIdentifier])
                        {
                            [_otherBundleIdentifiers addObject:bundleIdentifier];
                        }
                    }
                }
                else
                {
                    if ([application isHidden] && [_otherBundleIdentifiers containsObject:bundleIdentifier])
                    {
                        [application unhide];
                    }
                }
            }
        }
        
        if (isArranged)
        {
            [_otherBundleIdentifiers removeAllObjects];
        }
    }
}

- (BOOL)isApplicationActive
{
    return ([[NSApplication sharedApplication] isActive] && [[[[NSWorkspace sharedWorkspace] frontmostApplication] bundleIdentifier] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]);
}

/// Entitlement applications handling
///
- (BOOL)isFrontMostBundleIdentifier:(NSString *)bundleIdentifier
{
    return _lastBundleIdentifier != nil && [bundleIdentifier isEqualToString:_lastBundleIdentifier];
}

- (void)clearFrontMost:(NSString *)bundleIdentifier
{
    if ((bundleIdentifier == nil) || [self isFrontMostBundleIdentifier:bundleIdentifier])
    {
        _lastBundleIdentifier = nil;
    }
}

- (void)addWithBundleIdentifier:(NSString *)bundleIdentifier
{
    if (bundleIdentifier.length == 0) return;
    
    // Yes: entitlement app has been activated
    // NO: entitlement app has been inactivated
    if (_entitlementAppStates == nil)
    {
        _entitlementAppStates = [[NSMutableDictionary alloc] init];
    }
    
    [_entitlementAppStates setObject:[NSNumber numberWithBool:NO] forKey:bundleIdentifier];
}

- (void)removeWithBundleIdentifier:(NSString *)bundleIdentifier
{
    if (bundleIdentifier.length == 0) return;
    
    [_entitlementAppStates removeObjectForKey:bundleIdentifier];
}

- (void)activateWithBundleIdentifier:(NSString *)bundleIdentifier
{
    if (bundleIdentifier.length == 0) return;
    
    NSNumber *state = [_entitlementAppStates objectForKey:bundleIdentifier];
    
    if (state != nil)
    {
        BOOL isActive = [state boolValue];
        
        if (!isActive)
        {
            [_entitlementAppStates setObject:[NSNumber numberWithBool:YES] forKey:bundleIdentifier];
        }
    }
}

- (void)deactivateWithBundleIdentifier:(NSString *)bundleIdentifier
{
    if (bundleIdentifier.length == 0) return;
    
    NSNumber *state = [_entitlementAppStates objectForKey:bundleIdentifier];
    
    if (state != nil)
    {
        BOOL isActive = [state boolValue];
        
        if (isActive)
        {
            [_entitlementAppStates setObject:[NSNumber numberWithBool:NO] forKey:bundleIdentifier];
        }
    }
}

- (BOOL)isEntitlementAppForBundleIdentifier:(NSString *)bundleIdentifier
{
    if (bundleIdentifier.length == 0) return NO;
    
    return ([_entitlementAppStates objectForKey:bundleIdentifier] != nil) ? YES : NO;
}

- (BOOL)isEntitlementAppFocusedForBundleIdentifier:(NSString *)bundleIdentifier
{
    BOOL isEntitlementAppFocused = [self isEntitlementAppForBundleIdentifier:bundleIdentifier];
    
    if (!isEntitlementAppFocused) return NO;
    
    NSNumber *state = [_entitlementAppStates objectForKey:bundleIdentifier];
    
    if (state != nil)
    {
        isEntitlementAppFocused = [state boolValue];
    }
    
    return isEntitlementAppFocused;
}

- (BOOL)isEntitlementAppFocused
{
    return [self isEntitlementAppFocusedForBundleIdentifier:_lastBundleIdentifier];
}

- (BOOL)isFinderAppFocused
{
    return [_lastBundleIdentifier isEqualToString:@"com.apple.finder"];
}

- (void)hideOtherAppsExceptThoseInside
{
    script_hideAllAppsExcept(kFlowarePopover_BundleIdentifier_Finder, kFlowarePopover_BundleIdentifier_Safari);
}

#pragma mark - EntitlementsManager class methods

+ (NSString *)getAppPathWithIdentifier:(NSString *)bundleIdentifier
{
    NSString *path = nil;
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask];
    NSArray *properties = [NSArray arrayWithObjects:NSURLLocalizedNameKey, NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
    NSError *error = nil;
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[urls firstObject]
                                                   includingPropertiesForKeys:properties
                                                                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
                                                                        error:&error];
    
    if (array != nil)
    {
        for (NSURL *appUrl in array)
        {
            NSString *appPath = [appUrl path];
            NSBundle *appBundle = [NSBundle bundleWithPath:appPath];
            
            if ([bundleIdentifier isEqualToString:[appBundle bundleIdentifier]])
            {
                path = appPath;
                break;
            }
        }
    }
    
    if (path == nil)
    {
        path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
    }
    
    return path;
}

+ (NSString *)getAppNameWithIdentifier:(NSString *)bundleIdentifier
{
    if ([bundleIdentifier trim].length > 0)
    {
        NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
        path = [EntitlementsManager getAppPathWithIdentifier:bundleIdentifier];
        
        return [[NSFileManager defaultManager] displayNameAtPath:path];
    }
    
    return nil;
}

+ (NSString *)getBundleIdentifierForFilePath:(NSString *)path
{
    @try
    {
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:fileURL];
        NSString *bundleIdentifier = [[NSBundle bundleWithURL:appURL] bundleIdentifier];
        
        return bundleIdentifier;
    }
    @catch (NSException *exception)
    {
        NSLog(@"[DebugLog]-->%s-[%d] exception - reason = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason);
    }
    
    return nil;
}

@end
