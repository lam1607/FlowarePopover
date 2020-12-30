//
//  WindowManager.m
//  FLOPopupPrototypes
//
//  Created by Lam Nguyen on 9/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "WindowManager.h"

#import "AppDelegate.h"
#import "AbstractWindowController.h"

@interface WindowManager () <NSAppearanceExtensionsProtocols>
{
    AbstractWindowController *_windowController;
    
    BOOL _userInteractionEnabled;
    BOOL _menuItemsEnabled;
    
    NSMutableArray *_excludeDisableWindows;
    NSColor *_disabledColor;
}

@end

@implementation WindowManager

#pragma mark - Singleton

+ (WindowManager *)sharedInstance
{
    static WindowManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WindowManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        _windowController = [AbstractWindowController sharedInstance];
        _userInteractionEnabled = YES;
        _menuItemsEnabled = YES;
        _excludeDisableWindows = [[NSMutableArray alloc] init];
        _disabledColor = nil;
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (BOOL)userInteractionEnabled
{
    return _userInteractionEnabled;
}

- (BOOL)menuItemsEnabled
{
    return _menuItemsEnabled;
}

#pragma mark - Local methods

+ (NSWindowLevel)windowLevelDesktop
{
    return ((NSWindowLevel)WindowLevelGroupTagDesktop);
}

+ (NSWindowLevel)windowLevelNormal
{
    return ((NSWindowLevel)WindowLevelGroupTagNormal);
}

+ (NSWindowLevel)windowLevelFloat
{
    return ((NSWindowLevel)WindowLevelGroupTagFloat);
}

+ (NSWindowLevel)windowLevelMiddle
{
    return ((NSWindowLevel)WindowLevelGroupTagMiddle);
}

+ (NSWindowLevel)windowLevelSetting
{
    return ((NSWindowLevel)WindowLevelGroupTagSetting);
}

+ (NSWindowLevel)windowLevelMenu
{
    return ((NSWindowLevel)WindowLevelGroupTagMenu);
}

+ (NSWindowLevel)windowLevelAlert
{
    return ((NSWindowLevel)WindowLevelGroupTagAlert);
}

+ (NSWindowLevel)windowLevelTop
{
    return ((NSWindowLevel)WindowLevelGroupTagTop);
}

+ (void)hideChildWindowsForWindow:(NSWindow *)window
{
    BOOL shouldChildWindowsFloat = [WindowManager shouldChildWindowsFloat];
    NSWindowLevel levelNormal = [WindowManager levelForTag:WindowLevelGroupTagNormal];
    
    for (NSWindow *childWindow in [window childWindows])
    {
        if (childWindow.level != levelNormal)
        {
            [childWindow setLevel:levelNormal];
            // Should keep the line below, to make sure that the child window will 'sink' successfully.
            // Otherwise, the child window still floats even the level is NSNormalWindowLevel.
            [childWindow orderFront:window];
            
            if ([childWindow childWindows].count > 0)
            {
                [WindowManager hideChildWindowsForWindow:childWindow];
            }
        }
    }
    
    if (shouldChildWindowsFloat)
    {
        for (NSWindow *childWindow in [window childWindows])
        {
            if ([childWindow isKindOfClass:[FLOPopoverWindow class]] && ((FLOPopoverWindow *)childWindow).floatsWhenAppResignsActive)
            {
                [childWindow setLevel:[WindowManager levelForTag:((FLOPopoverWindow *)childWindow).tag floatsWhenAppResignsActive:((FLOPopoverWindow *)childWindow).floatsWhenAppResignsActive]];
            }
        }
    }
}

+ (void)showChildWindowsForWindow:(NSWindow *)window
{
    for (NSWindow *childWindow in [window childWindows])
    {
        NSWindowLevel level = [WindowManager levelForTag:WindowLevelGroupTagFloat];
        
        if ([childWindow isKindOfClass:[FLOPopoverWindow class]])
        {
            level = [WindowManager levelForTag:((FLOPopoverWindow *)childWindow).tag floatsWhenAppResignsActive:((FLOPopoverWindow *)childWindow).floatsWhenAppResignsActive];
        }
        
        [childWindow setLevel:level];
        [[childWindow attachedSheet] setLevel:(childWindow.level + 1)];
        
        if ([childWindow childWindows].count > 0)
        {
            [WindowManager showChildWindowsForWindow:childWindow];
        }
    }
}

+ (void)setWindow:(NSWindow *)window userInteractionEnable:(BOOL)isEnabled
{
    BOOL isDarkAppearance = [NSAppearance isDarkAppearance];
    NSColor *disabledColor = isDarkAppearance ? [[NSColor black] colorWithAlphaComponent:0.6] : [[NSColor black] colorWithAlphaComponent:0.5];
    
    [[self class] setWindow:window userInteractionEnable:isEnabled disabledColor:disabledColor];
}

+ (void)setWindow:(NSWindow *)window userInteractionEnable:(BOOL)isEnabled disabledColor:(NSColor *)disabledColor
{
    WindowManager *this = [WindowManager sharedInstance];
    
    if ([window isKindOfClass:[FLOPopoverWindow class]])
    {
        isEnabled = isEnabled || (!isEnabled && [this->_excludeDisableWindows containsObject:window]);
        
        [(FLOPopoverWindow *)window setUserInteractionEnable:isEnabled];
        [(FLOPopoverWindow *)window setDisabledColor:(isEnabled ? nil : disabledColor)];
    }
    
    NSArray *childWindows = [window childWindows];
    
    if (childWindows.count > 0)
    {
        for (NSWindow *childWindow in childWindows)
        {
            [WindowManager setWindow:childWindow userInteractionEnable:isEnabled disabledColor:disabledColor];
        }
    }
}

#pragma mark - WindowManager methods

- (void)setNSAppearanceProtocolOwner
{
    NSAppearance.protocolOwner = self;
}

#pragma mark - WindowManager class methods

+ (void)changeEffectiveAppearanceForWindow:(NSWindow *)window
{
    [[window contentView] changeEffectiveAppearance];
    
    for (NSWindow *childWindow in [window childWindows])
    {
        [WindowManager changeEffectiveAppearanceForWindow:childWindow];
    }
}

+ (void)changeWindowsEffectiveAppearance
{
    WindowManager *this = [WindowManager sharedInstance];
    NSWindow *window = this->_windowController.window;
    
    [WindowManager changeEffectiveAppearanceForWindow:window];
}

/// Children Popup Windows
///
+ (BOOL)shouldChildWindowsFloat
{
    EntitlementsManager *entitlementsManager = [EntitlementsManager sharedInstance];
    NSArray *openedBundleIdentifiers = entitlementsManager.openedBundleIdentifiers;
    
    return ((openedBundleIdentifiers.count > 0) && [entitlementsManager isEntitlementAppFocused] && [[openedBundleIdentifiers firstObject] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]);
}

+ (void)hideChildWindows
{
    WindowManager *this = [WindowManager sharedInstance];
    NSWindow *window = this->_windowController.window;
    
    if ([[NSApplication sharedApplication] isHidden] || [window isMiniaturized]) return;
    
    [WindowManager floatUpdateWindowsIfNeeded];
    [WindowManager hideChildWindowsForWindow:window];
}

+ (void)showChildWindows
{
    WindowManager *this = [WindowManager sharedInstance];
    NSWindow *window = this->_windowController.window;
    
    [WindowManager floatUpdateWindowsIfNeeded];
    [WindowManager showChildWindowsForWindow:window];
}

+ (FLOVirtualView *)setUserInteractionEnabled:(BOOL)isEnabled withMenuItemsEnabled:(BOOL)isMenuItemsEnabled
{
    BOOL isDarkAppearance = [NSAppearance isDarkAppearance];
    WindowManager *this = [WindowManager sharedInstance];
    NSColor *disabledColor = (this->_disabledColor != nil) ? this->_disabledColor : (isDarkAppearance ? [[NSColor black] colorWithAlphaComponent:0.6] : [[NSColor black] colorWithAlphaComponent:0.5]);
    
    return [[self class] setUserInteractionEnabled:isEnabled withMenuItemsEnabled:isMenuItemsEnabled disabledColor:disabledColor];
}

+ (FLOVirtualView *)setUserInteractionEnabled:(BOOL)isEnabled withMenuItemsEnabled:(BOOL)isMenuItemsEnabled disabledColor:(NSColor *)disabledColor
{
    WindowManager *this = [WindowManager sharedInstance];
    NSWindow *window = this->_windowController.window;
    
    @synchronized (this->_excludeDisableWindows)
    {
        this->_userInteractionEnabled = isEnabled;
        this->_menuItemsEnabled = isMenuItemsEnabled;
        this->_disabledColor = disabledColor;
        
        AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [appDelegate setMenuItemsEnabled:isMenuItemsEnabled];
        
        FLOVirtualView *dimView = [this->_windowController setUserInteractionEnabled:isEnabled];
        [dimView setWantsLayer:!isEnabled];
        [[dimView layer] setBackgroundColor:[disabledColor CGColor]];
        
        [WindowManager setWindow:window userInteractionEnable:isEnabled disabledColor:disabledColor];
        
        if (isEnabled)
        {
            [this->_excludeDisableWindows removeAllObjects];
        }
        
        return dimView;
    }
}

+ (void)excludeDisableForWindow:(NSWindow *)window
{
    if ([window isKindOfClass:[NSWindow class]])
    {
        WindowManager *this = [WindowManager sharedInstance];
        
        @synchronized (this->_excludeDisableWindows)
        {
            if (![this->_excludeDisableWindows containsObject:window])
            {
                [this->_excludeDisableWindows addObject:window];
            }
            
            [[self class] setUserInteractionEnable:this.userInteractionEnabled withMenuItemsEnable:this.menuItemsEnabled];
        }
    }
}

+ (void)floatUpdateWindowsIfNeeded
{
    WindowManager *this = [WindowManager sharedInstance];
    NSWindow *window = this->_windowController.window;
    
    if ([[NSApplication sharedApplication] isHidden] || [window isMiniaturized]) return;
    
    BOOL isApplicationActive = [[EntitlementsManager sharedInstance] isApplicationActive];
    NSArray *windows = [[NSApplication sharedApplication] windows];
    
    if (windows.count > 1)
    {
        BOOL shouldChildWindowsFloat = [WindowManager shouldChildWindowsFloat];
        NSWindowLevel levelNormal = [WindowManager levelForTag:WindowLevelGroupTagNormal];
        NSWindowLevel levelTop = [WindowManager levelForTag:WindowLevelGroupTagTop floatsWhenAppResignsActive:shouldChildWindowsFloat];
        
        for (NSWindow *item in windows)
        {
            if (item == window) continue;
            
            if ([WindowManager isUpdateWindow:item])
            {
                [item setHidesOnDeactivate:NO];
                [item setLevel:(isApplicationActive ? levelTop : (shouldChildWindowsFloat ? levelTop : levelNormal))];
                
                if (!isApplicationActive)
                {
                    // Should keep the line below, to make sure that the child window will 'sink' successfully.
                    // Otherwise, the child window still floats even the level is NSNormalWindowLevel.
                    [item orderFront:window];
                }
            }
        }
    }
}

+ (BOOL)isUpdateWindow:(NSWindow *)window
{
    if (![window isKindOfClass:[NSWindow class]]) return NO;
    
    NSResponder *responder = [window nextResponder];
    
    if ([responder isKindOfClass:[NSResponder class]] && ([NSStringFromClass([responder class]) isEqualToString:@"SUStatusController"] || [NSStringFromClass([responder class]) isEqualToString:@"SUUpdateAlert"] || [NSStringFromClass([responder class]) isEqualToString:@"SUUpdatePermissionPrompt"] || [NSStringFromClass([responder class]) isEqualToString:@"SUUpdateSettingsWindowController"]))
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isUpdateAlert:(NSWindow *)window
{
    if (![window isKindOfClass:[NSWindow class]]) return NO;
    
    NSResponder *responder = [window nextResponder];
    
    if ([responder isKindOfClass:[NSResponder class]] && [NSStringFromClass([responder class]) isEqualToString:@"SUUpdateAlert"])
    {
        return YES;
    }
    
    return NO;
}

+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag
{
    return [WindowManager levelForTag:tag floatsWhenAppResignsActive:NO];
}

+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag floatsWhenAppResignsActive:(BOOL)floatsWhenAppResignsActive
{
    NSWindowLevel level = NSNormalWindowLevel;
    BOOL isDesktopMode = [[SettingsManager sharedInstance] isDesktopMode];
    BOOL isActive = [[EntitlementsManager sharedInstance] isApplicationActive];
    BOOL shouldChildWindowsFloat = [WindowManager shouldChildWindowsFloat];
    
    switch (tag)
    {
        case WindowLevelGroupTagDesktop:
            level = [WindowManager windowLevelDesktop];
            break;
        case WindowLevelGroupTagNormal:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelNormal] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 1)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        case WindowLevelGroupTagFloat:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelFloat] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 2)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        case WindowLevelGroupTagMiddle:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelMiddle] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 3)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        case WindowLevelGroupTagSetting:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelSetting] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 4)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        case WindowLevelGroupTagMenu:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelMenu] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 6)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        case WindowLevelGroupTagAlert:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelAlert] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 9)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        case WindowLevelGroupTagTop:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelTop] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 10)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
            break;
        default:
            break;
    }
    
    return level;
}

+ (NSRect)fitFrame:(NSRect)frame toContainer:(NSRect)containerFrame
{
    NSRect proposedFrame = frame;
    NSUInteger tryNumber = 0;
    
    while (!NSContainsRect(containerFrame, proposedFrame))
    {
        if (tryNumber > 1000) break;
        
        ++tryNumber;
        
        if (proposedFrame.origin.y < NSMinY(containerFrame))
        {
            proposedFrame.origin.y = NSMinY(containerFrame);
        }
        
        if (proposedFrame.origin.x < NSMinX(containerFrame))
        {
            proposedFrame.origin.x = NSMinX(containerFrame);
        }
        
        if (NSMaxY(proposedFrame) > NSMaxY(containerFrame))
        {
            proposedFrame.origin.y = NSMaxY(containerFrame) - NSHeight(proposedFrame);
        }
        
        if (NSMaxX(proposedFrame) > NSMaxX(containerFrame))
        {
            proposedFrame.origin.x = NSMaxX(containerFrame) - NSWidth(proposedFrame);
        }
    }
    
    return proposedFrame;
}

@end
