//
//  WindowManager.m
//  FLOPopupPrototypes
//
//  Created by Lam Nguyen on 9/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "WindowManager.h"

#import "AbstractWindowController.h"

@interface WindowManager ()
{
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
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (BOOL)shouldChildWindowsFloat
{
    EntitlementsManager *entitlementsManager = [EntitlementsManager sharedInstance];
    NSArray *openedBundleIdentifiers = entitlementsManager.openedBundleIdentifiers;
    
    return ((openedBundleIdentifiers.count > 0) && [entitlementsManager isEntitlementAppFocused] && [[openedBundleIdentifiers firstObject] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]);
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

+ (NSWindowLevel)windowLevelSetting
{
    return ((NSWindowLevel)WindowLevelGroupTagSetting);
}

+ (NSWindowLevel)windowLevelAlert
{
    return ((NSWindowLevel)WindowLevelGroupTagAlert);
}

+ (NSWindowLevel)windowLevelTop
{
    return ((NSWindowLevel)WindowLevelGroupTagTop);
}

#pragma mark - WindowManager methods

/// Children Popup Windows
///
- (void)hideChildWindows
{
    NSWindow *window = [AbstractWindowController sharedInstance].window;
    
    // If the application window is set as hide/show at Dock, do nothing here.
    // Fix issue 0030047: Open any view, hide FLOM and open again will show UI incorrectly.
    if ([[NSApplication sharedApplication] isHidden] || [window isMiniaturized]) return;
    
    BOOL shouldChildWindowsFloat = [self shouldChildWindowsFloat];
    NSWindowLevel levelNormal = [WindowManager levelForTag:WindowLevelGroupTagNormal];
    
    for (NSWindow *childWindow in [window childWindows])
    {
        if (childWindow.level != levelNormal)
        {
            [childWindow setLevel:levelNormal];
            // Should keep the line below, to make sure that the child window will 'sink' successfully.
            // Otherwise, the child window still floats even the level is NSNormalWindowLevel.
            [childWindow orderFront:window];
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

- (void)showChildWindows
{
    NSWindow *window = [AbstractWindowController sharedInstance].window;
    
    for (NSWindow *childWindow in [window childWindows])
    {
        NSWindowLevel level = [WindowManager levelForTag:WindowLevelGroupTagFloat];
        
        if ([childWindow isKindOfClass:[FLOPopoverWindow class]])
        {
            level = [WindowManager levelForTag:((FLOPopoverWindow *)childWindow).tag floatsWhenAppResignsActive:((FLOPopoverWindow *)childWindow).floatsWhenAppResignsActive];
        }
        
        [childWindow setLevel:level];
        [[childWindow attachedSheet] setLevel:(childWindow.level + 1)];
    }
}

#pragma mark - WindowManager class methods

+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag
{
    return [WindowManager levelForTag:tag floatsWhenAppResignsActive:NO];
}

+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag floatsWhenAppResignsActive:(BOOL)floatsWhenAppResignsActive
{
    NSWindowLevel level = NSNormalWindowLevel;
    BOOL isDesktopMode = [[SettingsManager sharedInstance] isDesktopMode];
    BOOL isActive = [[EntitlementsManager sharedInstance] isApplicationActive];
    BOOL shouldChildWindowsFloat = [WindowManager sharedInstance].shouldChildWindowsFloat;
    
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
        case WindowLevelGroupTagSetting:
            level = (isActive || (shouldChildWindowsFloat && floatsWhenAppResignsActive)) ? [WindowManager windowLevelSetting] : (isDesktopMode ? ((NSWindowLevel)(WindowLevelGroupTagDesktop + 3)) : ((NSWindowLevel)WindowLevelGroupTagNormal));
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
