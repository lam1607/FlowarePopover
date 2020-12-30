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
#import "AbstractWindowController.h"

@interface WindowListApplierData : NSObject
{
}

@property (nonatomic, strong) NSMutableArray *windowsData;

@property (nonatomic, assign) pid_t pid;

@end

@implementation WindowListApplierData

- (instancetype)initWindowListData:(NSMutableArray *)array
{
    if (self = [super init])
    {
        self.windowsData = array;
    }
    
    return self;
}

@end

@implementation ScriptCommand

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _applicationDidClose = NO;
        _countRetry = 0;
        _windowID = -1;
    }
    
    return self;
}

- (void)setApplicationDidClose:(BOOL)applicationDidClose
{
    @synchronized (self)
    {
        _applicationDidClose = applicationDidClose;
    }
}

@end


@interface EntitlementsManager ()
{
    NSMutableDictionary *_entitlementAppStates;
    NSMutableArray<NSString *> *_openedBundleIdentifiers;
    NSString *_lastBundleIdentifier;
    NSMutableArray<NSString *>  *_otherBundleIdentifiers;
    
    BOOL _authorizingSystemEvents;
    
    NSMutableDictionary<id, ScriptCommand *> *_scriptCommands;
    NSOperationQueue *_arrangeAppQueue, *_arrangeDocQueue;
    NSMutableDictionary<id, ScriptCommand *> *_runningAppScriptArgs, *_runningDocScriptArgs;
    
    NSEvent *_globalMonitor, *_localMonitor;
    NSRunningApplication *_dockApplication;
    NSInteger _eventWindowNumber, _dockWindowNumber;
    NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *_windowInfos;
}

@end

void WindowListApplierFunction(const void *inputDictionary, void *context)
{
    NSDictionary *entry = (__bridge NSDictionary *)inputDictionary;
    WindowListApplierData *applierData = (__bridge WindowListApplierData *)context;
    
    // The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
    // However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
    NSString *windowLevel = entry[(id)kCGWindowLayer];
    NSString *processName = entry[(id)kCGWindowOwnerName];
    
    if ((processName != NULL) && ([windowLevel intValue] == kCGNormalWindowLevel))
    {
        NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
        
        // Grab the application name, but since it's optional we need to check before we can use it.
        // PID is required so we assume it's present.
        outputEntry[kAppProcessNameKey] = processName;
        outputEntry[kAppPIDKey] = entry[(id)kCGWindowOwnerPID];
        
        // Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
        CGRect bounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)entry[(id)kCGWindowBounds], &bounds);
        
        if ((bounds.size.width >= kWindowBoundsMinWidth) && (bounds.size.height >= kWindowBoundsMinHeight))
        {
            outputEntry[kWindowName] = entry[(id)kCGWindowName];
            outputEntry[kWindowBoundsKey] = [NSValue valueWithRect:bounds];
            
            // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
            outputEntry[kWindowIDKey] = entry[(id)kCGWindowNumber];
            outputEntry[kWindowLevelKey] = windowLevel;
            outputEntry[kWindowIsOnscreen] = entry[(id)kCGWindowIsOnscreen];
            
            [applierData.windowsData addObject:outputEntry];
        }
    }
}

void DockApplierFunction(const void *inputDictionary, void *context)
{
    NSDictionary *entry = (__bridge NSDictionary *)inputDictionary;
    WindowListApplierData *applierData = (__bridge WindowListApplierData *)context;
    
    // The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
    // However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
    NSString *windowLevel = entry[(id)kCGWindowLayer];
    NSString *processName = entry[(id)kCGWindowOwnerName];
    NSString *pid = entry[(id)kCGWindowOwnerPID];
    
    if ((processName != NULL) && ([pid intValue] == applierData.pid) && ([windowLevel intValue] == kCGDockWindowLevel))
    {
        NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
        
        // Grab the application name, but since it's optional we need to check before we can use it.
        // PID is required so we assume it's present.
        outputEntry[kAppProcessNameKey] = processName;
        outputEntry[kAppPIDKey] = pid;
        
        // Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
        CGRect bounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)entry[(id)kCGWindowBounds], &bounds);
        outputEntry[kWindowBoundsKey] = [NSValue valueWithRect:bounds];
        
        // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
        outputEntry[kWindowIDKey] = entry[(id)kCGWindowNumber];
        outputEntry[kWindowLevelKey] = windowLevel;
        
        [applierData.windowsData addObject:outputEntry];
    }
}

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
        [self getWindowInfos];
        [self getDockApplication];
        [self observeDockTerminatedMonitor];
        [self getDockWindowNumber];
        [self observeEventsMonitor];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeDockTerminatedMonitor];
    [self resetDockApplication];
    [self removeObserveEventsMonitor];
}

#pragma mark - Getter/Setter

- (NSMutableArray<NSString *> *)openedBundleIdentifiers
{
    return _openedBundleIdentifiers;
}

- (NSInteger)eventWindowNumber
{
    return _eventWindowNumber;
}

- (void)setEventWindowNumber:(NSInteger)eventWindowNumber
{
    _eventWindowNumber = eventWindowNumber;
}

#pragma mark - Local methods

- (void)initialize
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    
    if (_entitlementAppStates == nil)
    {
        _entitlementAppStates = [[NSMutableDictionary alloc] init];
    }
    
    _openedBundleIdentifiers = [[NSMutableArray alloc] init];
    [_openedBundleIdentifiers addObject:[[NSBundle mainBundle] bundleIdentifier]];
    
    _otherBundleIdentifiers = [[NSMutableArray alloc] init];
    
    _authorizingSystemEvents = NO;
    
    _arrangeAppQueue = [[NSOperationQueue alloc] init];
    _arrangeAppQueue.name = [NSString stringWithFormat:@"%@.%@.ArrangeAppQueue", [[NSBundle mainBundle] bundleIdentifier], NSStringFromClass([self class])];
    _arrangeAppQueue.maxConcurrentOperationCount = 1;
    
    _arrangeDocQueue = [[NSOperationQueue alloc] init];
    _arrangeDocQueue.name = [NSString stringWithFormat:@"%@.%@.ArrangeDocQueue", [[NSBundle mainBundle] bundleIdentifier], NSStringFromClass([self class])];
    _arrangeDocQueue.maxConcurrentOperationCount = 1;
    
    _scriptCommands = [[NSMutableDictionary alloc] init];
    _runningAppScriptArgs = [[NSMutableDictionary alloc] init];
    _runningDocScriptArgs = [[NSMutableDictionary alloc] init];
    
    _dockWindowNumber = NSNotFound;
}

- (NSRunningApplication *)getDockApplication
{
    if (_dockApplication == nil)
    {
        _dockApplication = [[self class] getRunningApplicationForIdentifier:EntitlementsIdentifier_Dock];
    }
    
    return _dockApplication;
}

- (void)resetDockApplication
{
    _dockApplication = nil;
}

- (NSInteger)getDockWindowNumber
{
    if (_dockWindowNumber == NSNotFound)
    {
        NSRunningApplication *dockApplication = [self getDockApplication];
        
        if (dockApplication != nil)
        {
            // Ask the window server for the list of windows.
            CFArrayRef windowList = CGWindowListCopyWindowInfo((kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements), kCGNullWindowID);
            
            // Copy the returned list, further pruned, to another list. This also adds some bookkeeping
            // information to the list as well as
            NSMutableArray *prunedWindowList = [NSMutableArray array];
            WindowListApplierData *windowListData = [[WindowListApplierData alloc] initWindowListData:prunedWindowList];
            windowListData.pid = dockApplication.processIdentifier;
            
            CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &DockApplierFunction, (__bridge void *)(windowListData));
            CFRelease(windowList);

            if ([[windowListData.windowsData firstObject] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dockWindowInfos = (NSDictionary *)[windowListData.windowsData firstObject];
                
                if ([dockWindowInfos objectForKey:kWindowIDKey] != nil)
                {
                    _dockWindowNumber = [[dockWindowInfos objectForKey:kWindowIDKey] intValue];
                }
            }
        }
    }
    
    return _dockWindowNumber;
}

- (void)resetDockWindowNumber
{
    _dockWindowNumber = NSNotFound;
}

- (void)observeDockTerminatedMonitor
{
    if (_dockApplication != nil)
    {
        [_dockApplication addObserver:self forKeyPath:@"terminated" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
    }
}

- (void)removeDockTerminatedMonitor
{
    if (_dockApplication != nil)
    {
        [_dockApplication removeObserver:self forKeyPath:@"terminated"];
    }
}

- (void)resetDockMonitors
{
    if ([[self class] getRunningApplicationForIdentifier:EntitlementsIdentifier_Dock] != nil)
    {
        [self removeDockTerminatedMonitor];
        [self resetDockApplication];
        [self resetDockWindowNumber];
        [self getDockApplication];
        [self observeDockTerminatedMonitor];
        [self getDockWindowNumber];
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetDockMonitors) object:nil];
        [self performSelector:@selector(resetDockMonitors) withObject:nil afterDelay:0.35];
    }
}

- (void)observeEventsMonitor
{
    __weak typeof(self) wself = self;
    
    if (_globalMonitor == nil)
    {
        _globalMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown handler:^(NSEvent *event) {
            if (wself == nil) return;
            
            typeof(self) this = wself;
            
            NSInteger eventWindowNumber = [this eventWindowNumber];
            
            [this setEventWindowNumber:event.windowNumber];
            
            if (event.windowNumber != eventWindowNumber)
            {
                [this getWindowInfos];
            }
        }];
    }
    
    if (_localMonitor == nil)
    {
        _localMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown) handler:^(NSEvent *event) {
            if (wself == nil) return event;
            
            typeof(self) this = wself;
            
            NSInteger eventWindowNumber = [this eventWindowNumber];
            
            [this setEventWindowNumber:event.windowNumber];
            
            if (event.windowNumber != eventWindowNumber)
            {
                [this getWindowInfos];
            }
            
            return event;
        }];
    }
}

- (void)removeObserveEventsMonitor
{
    if (_globalMonitor != nil)
    {
        [NSEvent removeMonitor:_globalMonitor];
        _globalMonitor = nil;
    }
    
    if (_localMonitor != nil)
    {
        [NSEvent removeMonitor:_localMonitor];
        _localMonitor = nil;
    }
}

- (void)setWindowInfos:(NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *)windowInfos
{
    @synchronized (_windowInfos)
    {
        _windowInfos = windowInfos;
    }
}

- (NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *)windowInfos
{
    return [[NSMutableDictionary alloc] initWithDictionary:_windowInfos];
}

- (void)getWindowInfos
{
    [self setWindowInfos:[[self class] getWindowInfosWithOption:(kCGWindowListOptionAll | kCGWindowListExcludeDesktopElements)]];
}

#pragma mark - EntitlementsManager methods

- (void)observeActivationForEntitlementApps
{
    __weak typeof(self) wself = self;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        if (wself == nil) return;
        
        typeof(self) this = wself;
        
        NSRunningApplication *application = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
        NSString *bundleIdentifier = application.bundleIdentifier;
        
        if ([application activationPolicy] != NSApplicationActivationPolicyRegular) return;
        if ([NSObject isEmpty:bundleIdentifier]) return;
        
        if (![bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
        {
            if (![this isEntitlementAppForBundleIdentifier:bundleIdentifier])
            {
                [this->_openedBundleIdentifiers removeAllObjects];
                [this setEventWindowNumber:NSNotFound];
                
                [this->_otherBundleIdentifiers addObject:bundleIdentifier];
            }
            else
            {
                if ([[this->_openedBundleIdentifiers firstObject] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
                {
                    [this->_openedBundleIdentifiers addObject:bundleIdentifier];
                }
                
                NSInteger eventWindowNumber = [this eventWindowNumber];
                BOOL isDockClicked = [[self class] isDockWindowNumber:eventWindowNumber];
                
                if (isDockClicked)
                {
                }
            }
            
            this->_lastBundleIdentifier = bundleIdentifier;
            
            [WindowManager performSelectorOnMainThread:@selector(hideChildWindows) withObject:nil waitUntilDone:YES];
        }
        else
        {
            [this setEventWindowNumber:NSNotFound];
            
            if (![this->_openedBundleIdentifiers containsObject:bundleIdentifier])
            {
                [this->_openedBundleIdentifiers addObject:bundleIdentifier];
            }
        }
        
        [this getWindowInfos];
    }];
}

/// Other running applications handling
///
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

- (ScriptCommand *)scriptCommandForKey:(id)key
{
    return [_scriptCommands objectForKey:key];
}

- (void)setScriptCommand:(ScriptCommand *)scriptArgs forKey:(id)key
{
    [_scriptCommands setObject:scriptArgs forKey:key];
}

- (void)removeScriptCommandForKey:(id)key
{
    [_scriptCommands removeObjectForKey:key];
}

- (void)removeScriptCommand:(ScriptCommand *)scriptArgs
{
    if ((scriptArgs != nil) && scriptArgs.applicationDidClose)
    {
        [self stopRunningApplication:scriptArgs];
        [self stopRunningDocument:scriptArgs];
        [self removeScriptCommandForKey:scriptArgs.objectKey];
        
        if (scriptArgs.siblingTitle == nil)
        {
            [[self class] hideApplicationWithIdentifier:scriptArgs.bundleIdentifier];
        }
    }
}

- (void)setRunningApplication:(ScriptCommand *)scriptArgs
{
    [_runningAppScriptArgs setObject:scriptArgs forKey:scriptArgs.objectKey];
}

- (ScriptCommand *)runningAppScriptArgForKey:(id)key
{
    return [_runningAppScriptArgs objectForKey:key];
}

- (void)removeRunningAppScriptArgForKey:(id)key
{
    [_runningAppScriptArgs removeObjectForKey:key];
}

- (void)stopRunningApplication:(ScriptCommand *)scriptArgs
{
    ScriptCommand *runningScript = [self runningAppScriptArgForKey:scriptArgs.objectKey];
    
    if (runningScript != nil)
    {
        NSArray<AsynchronousOperation *> *operations = _arrangeAppQueue.operations;
        
        if (operations.count > 0)
        {
            for (AsynchronousOperation *operation in operations)
            {
                if ([operation.name isEqualToString:runningScript.objectKey])
                {
                    if ([operation isKindOfClass:[AsynchronousOperation class]])
                    {
                        [operation finish];
                    }
                    
                    [operation cancel];
                }
            }
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resizeApplication:) object:runningScript];
        [self removeRunningAppScriptArgForKey:runningScript.objectKey];
    }
}

- (void)setRunningDocument:(ScriptCommand *)scriptArgs
{
    [_runningDocScriptArgs setObject:scriptArgs forKey:scriptArgs.objectKey];
}

- (ScriptCommand *)runningDocScriptArgForKey:(id)key
{
    return [_runningDocScriptArgs objectForKey:key];
}

- (void)removeRunningDocScriptArgForKey:(id)key
{
    [_runningDocScriptArgs removeObjectForKey:key];
}

- (void)stopRunningDocument:(ScriptCommand *)scriptArgs
{
    ScriptCommand *runningScript = [self runningDocScriptArgForKey:scriptArgs.objectKey];
    
    if (runningScript != nil)
    {
        NSArray<AsynchronousOperation *> *operations = _arrangeDocQueue.operations;
        
        if (operations.count > 0)
        {
            for (AsynchronousOperation *operation in operations)
            {
                if ([operation.name isEqualToString:runningScript.objectKey])
                {
                    if ([operation isKindOfClass:[AsynchronousOperation class]])
                    {
                        [operation finish];
                    }
                    
                    [operation cancel];
                }
            }
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resizeDocument:) object:runningScript];
        [self removeRunningDocScriptArgForKey:runningScript.objectKey];
    }
}

- (void)stopArrangeOperation:(ScriptCommand *)scriptArgs
{
    [self stopRunningApplication:scriptArgs];
    [self stopRunningDocument:scriptArgs];
}

- (void)resizeApplication:(ScriptCommand *)scriptArgs
{
    __weak typeof(self) wself = self;
    
    AsynchronousOperation *op = [AsynchronousOperation asynchronousOperationWithBlock:^(AsynchronousOperation *op) {
        __strong typeof(self) this = wself;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            ScriptCommand *runningScript = [self runningAppScriptArgForKey:scriptArgs.objectKey];
            
            int ret = ((runningScript != nil) && !(op.isFinished || scriptArgs.applicationDidClose)) ? script_resizeApplication(scriptArgs.processName, scriptArgs.bundleIdentifier, scriptArgs.assignedFrame.origin.x, scriptArgs.assignedFrame.origin.y, scriptArgs.assignedFrame.size.width, scriptArgs.assignedFrame.size.height, scriptArgs.autoArrange) : 0;
            

            // ret == 2: first window not found
            // ret == 4: no window found
            if ((ret == 1) || (runningScript == nil) || op.isFinished || scriptArgs.applicationDidClose)
            {
                // Application is already resized with correct position and size -> finish
            }
            else
            {
                scriptArgs.countRetry += 1;
                
                // Only try to resize maximum for 3 times
                if (scriptArgs.countRetry < EntitlementsMaximumTryCount)
                {
                    if (((ret == 2) || (ret == 4)) && ![scriptArgs.bundleIdentifier isEqualToString:EntitlementsIdentifier_Preview])
                    {
                        [NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(resizeApplication:) object:scriptArgs];
                        [this performSelector:@selector(resizeApplication:) withObject:scriptArgs afterDelay:EntitlementsResizeDelayIntervalLong];
                    }
                    else
                    {
                        [NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(resizeApplication:) object:scriptArgs];
                        [this performSelector:@selector(resizeApplication:) withObject:scriptArgs afterDelay:EntitlementsResizeDelayIntervalDefault];
                    }
                }
            }
            
            [this removeScriptCommand:scriptArgs];
            [op finish];
        }];
    }];
    
    [op setName:scriptArgs.objectKey];
    
    [_arrangeAppQueue addOperation:op];
}

- (void)resizeDocument:(ScriptCommand *)scriptArgs
{
    __weak typeof(self) wself = self;
    
    AsynchronousOperation *op = [AsynchronousOperation asynchronousOperationWithBlock:^(AsynchronousOperation *op) {
        __strong typeof(self) this = wself;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            ScriptCommand *runningScript = [self runningDocScriptArgForKey:scriptArgs.objectKey];

            int ret = ((runningScript != nil) && !(op.isFinished || scriptArgs.applicationDidClose)) ? script_resizeDocument(scriptArgs.processName, scriptArgs.path, scriptArgs.siblingTitle, scriptArgs.assignedFrame.origin.x, scriptArgs.assignedFrame.origin.y, scriptArgs.assignedFrame.size.width, scriptArgs.assignedFrame.size.height, scriptArgs.autoArrange) : 0;
            
            // ret == 2: first window not found
            // ret == 4: no window found
            if ((ret == 1) || (runningScript == nil) || op.isFinished || scriptArgs.applicationDidClose)
            {
                // Document is already resized with correct position and size -> finish
            }
            else
            {
                scriptArgs.countRetry += 1;
                
                // Only try to resize maximum for 3 times
                if (scriptArgs.countRetry < EntitlementsMaximumTryCount)
                {
                    if (((ret == 2) || (ret == 4)) && ![scriptArgs.bundleIdentifier isEqualToString:EntitlementsIdentifier_Preview])
                    {
                        [NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(resizeDocument:) object:scriptArgs];
                        [this performSelector:@selector(resizeDocument:) withObject:scriptArgs afterDelay:EntitlementsResizeDelayIntervalLong];
                    }
                    else
                    {
                        [NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(resizeDocument:) object:scriptArgs];
                        [this performSelector:@selector(resizeDocument:) withObject:scriptArgs afterDelay:EntitlementsResizeDelayIntervalDefault];
                    }
                }
            }
            
            [this removeScriptCommand:scriptArgs];
            [op finish];
        }];
    }];
    
    [op setName:scriptArgs.objectKey];
    
    [_arrangeDocQueue addOperation:op];
}

#pragma mark - EntitlementsManager class methods

+ (BOOL)isExceptionApplicationBundle:(NSString *)bundleIdentifier
{
    return [bundleIdentifier isEqualToString:EntitlementsIdentifier_Preview];
}

+ (BOOL)isDockWindowNumber:(NSInteger)windowNumber
{
    NSInteger dockWindowNumber = [[EntitlementsManager sharedInstance] getDockWindowNumber];
    
    if ((windowNumber != NSNotFound) && (dockWindowNumber != NSNotFound))
    {
        return (windowNumber == dockWindowNumber);
    }
    
    return NO;
}

/**
 * Get list of CGWindow dictionary with given windowOption.
 *
 * @param windowOption is the CGWindowListOption option that we want to get the CGWindow dictionary respectively.
 * @return A dictionary of specific states of found CGWindow info as following:
 * @{"windowOnscreen": @{@(pid): value, processName: value}, "windowOffScreen": @{@(pid): value, processName: value}}
 */
+ (NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *)getWindowInfosWithOption:(CGWindowListOption)windowOption
{
    // Ask the window server for the list of windows.
    CFArrayRef windowList = CGWindowListCopyWindowInfo(windowOption, kCGNullWindowID);
    
    // Copy the returned list, further pruned, to another list. This also adds some bookkeeping
    // information to the list as well as
    NSMutableArray *prunedWindowList = [NSMutableArray array];
    WindowListApplierData *windowListData = [[WindowListApplierData alloc] initWindowListData:prunedWindowList];
    
    CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, (__bridge void *)(windowListData));
    CFRelease(windowList);
    
    NSArray *windowInfos = windowListData.windowsData;
    NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *windowStatesDictionary = [NSMutableDictionary dictionary];
    
    for (NSDictionary *windowInfo in windowInfos)
    {
        BOOL isOnscreen = ([[windowInfo objectForKey:kWindowIsOnscreen] intValue] == 1);
        id statusKey = isOnscreen ? kWindowIsOnscreen : kWindowIsOffScreen;
        NSMutableDictionary<id, NSArray<NSDictionary *> *> *windowsData = [windowStatesDictionary objectForKey:statusKey];
        
        if (windowsData == nil)
        {
            windowsData = [NSMutableDictionary dictionary];
            [windowStatesDictionary setObject:windowsData forKey:statusKey];
        }
        
        // For Application Process Name
        {
            id key = [windowInfo objectForKey:kAppProcessNameKey];
            NSMutableArray<NSDictionary *> *values = (NSMutableArray<NSDictionary *> *)[windowsData objectForKey:key];
            
            if (values == nil)
            {
                values = [NSMutableArray array];
                [windowsData setObject:values forKey:key];
            }
            
            if (![values containsObject:windowInfo])
            {
                [values addObject:windowInfo];
            }
        }
        
        // For Application PID
        {
            id key = [NSString stringWithFormat:@"%d", [[windowInfo objectForKey:kAppPIDKey] intValue]];
            NSMutableArray<NSDictionary *> *values = (NSMutableArray<NSDictionary *> *)[windowsData objectForKey:key];
            
            if (values == nil)
            {
                values = [NSMutableArray array];
                [windowsData setObject:values forKey:key];
            }
            
            if (![values containsObject:windowInfo])
            {
                [values addObject:windowInfo];
            }
        }
    }
    
    return windowStatesDictionary;
}

/**
 * Get CGWindow dictionary info for specific application by a given CGWindowListOption.
 *
 * @param processName is the process name or process identifier (pid) of application.
 * @param windowOption is the CGWindowListOption option that want to get CGWindow dictionary for.
 */
+ (NSDictionary *)getWindowInfosForProcess:(NSString *)processName withOption:(CGWindowListOption)windowOption
{
    if ([NSObject isEmpty:processName]) return nil;
    
    if ([processName containsString:EntitlementsApplicationExtension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - EntitlementsApplicationExtension.length)];
    }
    
    // Ask the window server for the list of windows.
    CFArrayRef windowList = CGWindowListCopyWindowInfo(windowOption, kCGNullWindowID);
    
    // Copy the returned list, further pruned, to another list. This also adds some bookkeeping
    // information to the list as well as
    NSMutableArray *prunedWindowList = [NSMutableArray array];
    WindowListApplierData *windowListData = [[WindowListApplierData alloc] initWindowListData:prunedWindowList];
    
    CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, (__bridge void *)(windowListData));
    CFRelease(windowList);
    
    NSArray *windowInfos = windowListData.windowsData;
    
    for (NSDictionary *windowInfo in windowInfos)
    {
        if ([[windowInfo objectForKey:kAppProcessNameKey] isEqualToString:processName] || ([[windowInfo objectForKey:kAppPIDKey] intValue] == [processName intValue]))
        {
            return [[NSMutableDictionary alloc] initWithDictionary:windowInfo];
        }
    }
    
    return nil;
}

/**
 * Check the specific application whose windows are NOT on screen.
 *
 * @param processName is the process name or process identifier (pid) of application.
 */
+ (BOOL)isApplicationWindowsEmpty:(NSString *)processName
{
    if ([processName containsString:EntitlementsApplicationExtension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - EntitlementsApplicationExtension.length)];
    }
    
    NSMutableDictionary<id, NSMutableDictionary<id, NSArray<NSDictionary *> *> *> *windowStatesDictionary = [[EntitlementsManager sharedInstance] windowInfos];
    
    // For windowOnscreen
    {
        NSMutableDictionary<id, NSArray<NSDictionary *> *> *windowInfos = [windowStatesDictionary objectForKey:kWindowIsOnscreen];
        NSDictionary *windowInfo = [[windowInfos objectForKey:processName] lastObject];
        
        if ((windowInfo != nil) && ([[windowInfo objectForKey:kAppProcessNameKey] isEqualToString:processName] || ([[windowInfo objectForKey:kAppPIDKey] intValue] == [processName intValue])))
        {
            return NO;
        }
    }
    
    // For windowOffScreen
    {
        NSMutableDictionary<id, NSArray<NSDictionary *> *> *windowInfos = [windowStatesDictionary objectForKey:kWindowIsOffScreen];
        NSDictionary *windowInfo = [[windowInfos objectForKey:processName] lastObject];
        
        if ((windowInfo != nil) && ([[windowInfo objectForKey:kAppProcessNameKey] isEqualToString:processName] || ([[windowInfo objectForKey:kAppPIDKey] intValue] == [processName intValue])))
        {
            return NO;
        }
    }
    
    return YES;
}

/**
 * Check the specific application whose windows are on screen.
 *
 * @param processName is the process name or process identifier (pid) of application.
 */
+ (BOOL)isApplicationWindowOnscreen:(NSString *)processName
{
    if ([processName containsString:EntitlementsApplicationExtension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - EntitlementsApplicationExtension.length)];
    }
    
    NSMutableDictionary<id, NSArray<NSDictionary *> *> *windowInfos = [[[EntitlementsManager sharedInstance] windowInfos] objectForKey:kWindowIsOnscreen];
    NSDictionary *windowInfo = [[windowInfos objectForKey:processName] lastObject];
    
    if ((windowInfo != nil) && ([[windowInfo objectForKey:kAppProcessNameKey] isEqualToString:processName] || ([[windowInfo objectForKey:kAppPIDKey] intValue] == [processName intValue])))
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)shouldResizeEntitledApp:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier onRect:(NSRect)onRect
{
    if ([NSObject isEmpty:processName]) return NO;
    
    if ([processName containsString:EntitlementsApplicationExtension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - EntitlementsApplicationExtension.length)];
    }
    
    if ([[self class] checkIfAccessibilityAutomationEnabled])
    {
        EntitlementsManager *this = [EntitlementsManager sharedInstance];
        ScriptCommand *scriptArgs = [this scriptCommandForKey:processName];
        
        if ((scriptArgs != nil) && (scriptArgs.siblingTitle == nil))
        {
            NSMutableDictionary<id, NSArray<NSDictionary *> *> *windowInfos = [[this windowInfos] objectForKey:kWindowIsOnscreen];
            NSDictionary *windowInfo = [[windowInfos objectForKey:processName] lastObject];
            BOOL isOnscreen = ((windowInfo != nil) && [[windowInfo objectForKey:kAppProcessNameKey] isEqualToString:processName]);
            
            if (isOnscreen)
            {
                NSRect currentFrame = [[windowInfo objectForKey:kWindowBoundsKey] rectValue];
                
                if ((NSMinX(currentFrame) == NSMinX(onRect)) && (NSMinY(currentFrame) == NSMinY(onRect)) && (NSWidth(currentFrame) == NSWidth(onRect)) && (NSHeight(currentFrame) == NSHeight(onRect)))
                {
                    return NO;
                }
            }
        }
        
        return YES;
    }
    
    return NO;
}

/// Entitlement app handling
///
+ (NSRect)getFrameForEntitledApp:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier
{
    if ([NSObject isEmpty:processName]) return NSZeroRect;
    
    NSRect frame = NSZeroRect;
    
    if ([[SettingsManager sharedInstance] isDesktopMode])
    {
        NSWindow *window = [AbstractWindowController sharedInstance].window;
        NSRect windowFrame = [window frame];
        NSRect windowScreenFrame = [[window screen] frame];
        NSRect firstScreenFrame = [[[NSScreen screens] firstObject] frame];
        CGFloat menuBarHeight = NSHeight(windowScreenFrame) - NSMaxY(windowFrame);
        CGFloat monitorsValueDifference = NSHeight(firstScreenFrame) - NSHeight(windowScreenFrame);
        
        frame = windowFrame;
        frame.origin.x += 5.0 ;
        frame.origin.y = NSMaxY(windowFrame) - NSMaxY(frame) - 5.0 + menuBarHeight + monitorsValueDifference;
        frame.size.width -= 10.0;
        frame.size.height -= 10.0;
    }
    
    return frame;
}

+ (void)presentEntitledApp:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier onRect:(NSRect)onRect
{
    if ([NSObject isEmpty:processName] || [NSObject isEmpty:bundleIdentifier]) return;
    
    // **NOTE: AppleScript using the process name instead of application name,
    // therefor, we should apply the [-getProcessName] here instead of [-getAppName].
    BOOL autoArrange = NSEqualRects(onRect, NSZeroRect) ? NO : YES;
    EntitlementsManager *this = [EntitlementsManager sharedInstance];
    
    if ([processName containsString:EntitlementsApplicationExtension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - EntitlementsApplicationExtension.length)];
    }
    
    if (![[SettingsManager sharedInstance] isDesktopMode])
    {
        [this activateWithBundleIdentifier:bundleIdentifier];
        
        return;
    }
    
    BOOL shouldResize = [[self class] shouldResizeEntitledApp:processName withIdentifier:bundleIdentifier onRect:onRect];
    NSString *objectKey = processName;
    ScriptCommand *scriptArgs = [this scriptCommandForKey:objectKey];
    
    if ((scriptArgs != nil) && scriptArgs.applicationDidClose)
    {
        [this removeScriptCommand:scriptArgs];
    }
    else
    {
        if (scriptArgs == nil)
        {
            scriptArgs = [ScriptCommand new];
            [this setScriptCommand:scriptArgs forKey:objectKey];
        }
        
        scriptArgs.processName = processName;
        scriptArgs.autoArrange = autoArrange;
        scriptArgs.bundleIdentifier = bundleIdentifier;
        scriptArgs.objectKey = objectKey;
        
        if (shouldResize && !scriptArgs.applicationDidClose)
        {
            scriptArgs.countRetry = 0;
            scriptArgs.assignedFrame = onRect;
            
            [this stopRunningApplication:scriptArgs];
            [this setRunningApplication:scriptArgs];
            [this activateWithBundleIdentifier:scriptArgs.bundleIdentifier];
            [this resizeApplication:scriptArgs];
        }
    }
}

+ (void)presentDocument:(NSString *)path processName:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier onRect:(NSRect)onRect
{
    if ([NSObject isEmpty:processName] || [NSObject isEmpty:bundleIdentifier]) return;
    
    // **NOTE: AppleScript using the process name instead of application name,
    // therefor, we should apply the [-getProcessName] here instead of [-getAppName].
    BOOL autoArrange = NSEqualRects(onRect, NSZeroRect) ? NO : YES;
    EntitlementsManager *this = [EntitlementsManager sharedInstance];
    
    if ([processName containsString:EntitlementsApplicationExtension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - EntitlementsApplicationExtension.length)];
    }
    
    if (![[SettingsManager sharedInstance] isDesktopMode])
    {
        [this activateWithBundleIdentifier:bundleIdentifier];
        
        return;
    }
    
    BOOL shouldResize = [[self class] shouldResizeEntitledApp:processName withIdentifier:bundleIdentifier onRect:onRect];
    NSString *objectKey = path;
    NSString *siblingTitle = nil;
    ScriptCommand *scriptArgs = [this scriptCommandForKey:objectKey];
    
    if ((scriptArgs != nil) && scriptArgs.applicationDidClose)
    {
        [this removeScriptCommand:scriptArgs];
    }
    else
    {
        if (scriptArgs == nil)
        {
            scriptArgs = [ScriptCommand new];
            [this setScriptCommand:scriptArgs forKey:objectKey];
        }
        
        scriptArgs.processName = processName;
        scriptArgs.siblingTitle = siblingTitle;
        scriptArgs.autoArrange = autoArrange;
        scriptArgs.path = path;
        scriptArgs.bundleIdentifier = bundleIdentifier;
        scriptArgs.objectKey = objectKey;
        
        if (shouldResize && !scriptArgs.applicationDidClose)
        {
            scriptArgs.countRetry = 0;
            scriptArgs.assignedFrame = onRect;
            
            [this stopRunningDocument:scriptArgs];
            [this setRunningDocument:scriptArgs];
            [this activateWithBundleIdentifier:scriptArgs.bundleIdentifier];
            [this resizeDocument:scriptArgs];
        }
    }
}

+ (void)hideApplication:(NSRunningApplication *)application
{
    if ([application isKindOfClass:[NSRunningApplication class]])
    {
        if ([[self class] isApplicationWindowOnscreen:[NSString stringWithFormat:@"%d", application.processIdentifier]])
        {
            [application hide];
        }
    }
}

+ (void)hideApplicationWithIdentifier:(NSString *)bundleIdentifier
{
    NSRunningApplication *application = [[self class] getRunningApplicationForIdentifier:bundleIdentifier];
    
    [[self class] hideApplication:application];
}

+ (void)hideOtherAppsExceptThoseInWorkspace
{
    NSArray<NSRunningApplication *> *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication *application in runningApplications)
    {
        if ([application activationPolicy] == NSApplicationActivationPolicyRegular)
        {
            NSString *bundleIdentifier = [application bundleIdentifier];
            
            if ([bundleIdentifier isEqualToString:kFlowarePopover_BundleIdentifier_Finder] || [bundleIdentifier isEqualToString:kFlowarePopover_BundleIdentifier_Safari])
            {
                // Do nothing here.
            }
            else if (![application isHidden] && ![bundleIdentifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
            {
                [[self class] hideApplication:application];
            }
        }
    }
}

+ (NSRunningApplication *)openApplication:(NSString *)processName bundleIdentifier:(NSString *)bundleIdentifier fullPath:(NSString *)fullPath
{
    NSRunningApplication *application = [[self class] getRunningApplicationForIdentifier:bundleIdentifier];

    if ((application != nil) && ![[self class] isApplicationWindowOnscreen:processName])
    {
        if ([[self class] isExceptionApplicationBundle:bundleIdentifier])
        {
            if (![[self class] isApplicationWindowsEmpty:processName])
            {
                application = nil;
            }
        }
        else
        {
            application = nil;
        }
    }
    
    if (application == nil)
    {
        if (![[self class] openApplicationAtPath:fullPath])
        {
            script_openApp(processName);
        }
    }
    
    return application;
}

+ (BOOL)openApplicationAtPath:(NSString *)fullPath
{
#if defined(__MAC_10_15) && __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_15
    if (@available(macOS 10.15, *))
    {
        NSWorkspaceOpenConfiguration *configuration = [NSWorkspaceOpenConfiguration configuration];
        [configuration setActivates:YES];
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:fullPath] configuration:configuration completionHandler:^(NSRunningApplication *_Nullable app, NSError *_Nullable error) {
        }];
    }
#else
    NSRunningApplication *application = [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:fullPath] options:NSWorkspaceLaunchDefault configuration:@{} error:nil];
    
    if (application == nil)
    {
        return NO;
    }
#endif
    
    return YES;
}

+ (NSRunningApplication *)openSystemPreferencesWithSelectedPrivacyTab:(NSString *)privacyTab
{
    if (![privacyTab containsString:@"Privacy_"]) return nil;
    
    NSString *bundleIdentifier = EntitlementsIdentifier_SystemPreferences;
    NSString *path = [NSString stringWithFormat:@"x-apple.systempreferences:com.apple.preference.security?%@", privacyTab];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:path]];
    
    NSRunningApplication *application = [[self class] getRunningApplicationForIdentifier:bundleIdentifier];
    
    if (application != nil)
    {
        [[self class] openApplicationAtPath:[[self class] getAppPathWithIdentifier:bundleIdentifier]];
        
        [application unhide];
    }
    
    return application;
}

+ (NSRunningApplication *)getRunningApplicationForIdentifier:(NSString *)bundleIdentifier
{
    NSArray<NSRunningApplication *> *runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    
    for (NSRunningApplication *application in runningApplications)
    {
        if ([[application bundleIdentifier] isEqualToString:bundleIdentifier])
        {
            return application;
        }
    }
    
    return nil;
}

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
        path = [[self class] getAppPathWithIdentifier:bundleIdentifier];
        
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

+ (NSRunningApplication *)presentApplication:(NSString *)processName withIdentifier:(NSString *)bundleIdentifier
{
    if ([NSObject isEmpty:processName] || [NSObject isEmpty:bundleIdentifier]) return nil;
    
    if ([processName isEqualToString:@"Contacts"] || [processName isEqualToString:@"Contacts.app"])
    {
        processName = @"Address Book";
    }
    
    [[self class] openApplicationAtPath:[[self class] getAppPathWithIdentifier:bundleIdentifier]];
    
    NSRunningApplication *application = [[self class] getRunningApplicationForIdentifier:bundleIdentifier];
    
    if (application != nil)
    {
        [application unhide];
        [application activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    }
    
    return application;
}

+ (void)presentDocumentAtPath:(NSString *)path
{
    if ([NSObject isEmpty:path]) return;
    
#if defined(__MAC_10_15) && __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_15
    if (@available(macOS 10.15, *))
    {
        NSWorkspaceOpenConfiguration *configuration = [NSWorkspaceOpenConfiguration configuration];
        [configuration setActivates:YES];
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path] configuration:configuration completionHandler:^(NSRunningApplication *_Nullable app, NSError *_Nullable error) {
        }];
    }
#else
    [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"" andDeactivate:YES];
#endif
}

+ (OSStatus)checkAEDeterminePermissionForIdentifier:(NSString *)bundleIdentifier
{
    return [[self class] checkAEDeterminePermissionForIdentifier:bundleIdentifier withAuthorizationPrompt:NO];
}

+ (OSStatus)checkAEDeterminePermissionForIdentifier:(NSString *)bundleIdentifier withAuthorizationPrompt:(BOOL)shouldPrompt
{
#if defined(__MAC_10_14) && __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_14
    if (@available(macOS 10.14, *))
    {
        NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithBundleIdentifier:bundleIdentifier];
        /*
         *  AEDeterminePermissionToAutomateTarget()
         *    target:
         *      A pointer to an address descriptor. Before calling AEDeterminePermissionToAutomateTarget, you set the descriptor to identify
         *      the target application for the Apple event.  The target address descriptor must refer to a running application.  If
         *      the target application is on another machine, then Remote AppleEvents must be enabled on that machine for the user.
         *
         *    theAEEventClass:
         *      The event class of the Apple event to determine permission for.
         *
         *    theAEEventID:
         *      The event ID of the Apple event to determine permission for.
         *
         *    askUserIfNeeded:
         *      a Boolean; if true, and if this application does not yet have permission to send events to the target application, then
         *        prompt the user to obtain permission.  If false, do not prompt the user.
         */
        Boolean askUserIfNeeded = false;
        OSStatus permission = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, askUserIfNeeded);
        
        switch (permission)
        {
            case noErr:
                // User has previously approved automation.
                break;
            case errAEEventNotPermitted:
                // No purpose string or user has previously denied automation.
                break;
            case -1744:
                // errAEEventWouldRequireUserConsent
                // Status unknown: would require authorization prompt.
                if (shouldPrompt)
                {
                    // If target app is not available in Privacy/Automation (for macOS >= 14.0),
                    // when using application, should run a scripting method to launch the target app authorization prompt.
                    permission = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true);
                    // In case of users don't response to the Authorization prompt System Alert in the long time.
                    // That time is larger than the idle time of the System Events application,
                    // after that idle time system will kill the System Events application, but the System Alert still shows.
                    // Therefor, we should recursively call this method again to make sure that the OSStatus permission value is set correctly.
                    // Otherwise, this method will be recursively called many times with the lifetime (idle time) of System Events application respectively.
                    // The Authorization prompt System Alert keep showing until users response to it.
                    permission = [[self class] checkAEDeterminePermissionForIdentifier:bundleIdentifier withAuthorizationPrompt:shouldPrompt];
                    
                    return permission;
                }
                
                break;
            case procNotFound:
                // Status unknown: target app not running.
                if ([[bundleIdentifier lowercaseString] isEqualToString:[EntitlementsIdentifier_SystemEvents lowercaseString]])
                {
                    // Should launch the System Events application here for checking the permission value correctly.
                    NSString *path = [[self class] getAppPathWithIdentifier:bundleIdentifier];
                    __unused BOOL succeeded = [[self class] openApplicationAtPath:path];
                    
                    permission = [[self class] checkAEDeterminePermissionForIdentifier:bundleIdentifier withAuthorizationPrompt:shouldPrompt];
                    
                    return permission;
                }
                
                break;
            default:
                break;
        }
        
        return permission;
    }
#endif
    
    return noErr;
}

+ (BOOL)isSystemEventsPrompted
{
    OSStatus permission = [[self class] checkAEDeterminePermissionForIdentifier:EntitlementsIdentifier_SystemEvents];
    
    return (permission != -1744);
}

+ (BOOL)checkSystemEventsEnabled
{
    OSStatus permission = [[self class] checkAEDeterminePermissionForIdentifier:EntitlementsIdentifier_SystemEvents];
    
    return (permission == noErr);
}

+ (BOOL)checkSystemEventsEnabledWithAuthorizationPrompt:(BOOL)shouldPrompt
{
    OSStatus permission = [[self class] checkAEDeterminePermissionForIdentifier:EntitlementsIdentifier_SystemEvents withAuthorizationPrompt:shouldPrompt];
    
    return (permission == noErr);
}

+ (BOOL)checkAccessibilityEnabled
{
    NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt:@NO};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    
    return accessibilityEnabled;
}

+ (BOOL)checkIfAccessibilityAutomationEnabled
{
    BOOL accessibilityEnabled = [[self class] checkAccessibilityEnabled];
    BOOL systemEventEnabled = [[self class] checkSystemEventsEnabled];
    
    return accessibilityEnabled && systemEventEnabled;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"terminated"] && [object isKindOfClass:[NSRunningApplication class]] && [((NSRunningApplication *)object).bundleIdentifier isEqualToString:EntitlementsIdentifier_Dock])
    {
        BOOL isTerminated = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        
        if (isTerminated)
        {
            [self resetDockMonitors];
        }
    }
}

@end
