//
//  AbstractWindowController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractWindowController.h"

#import "AppDelegate.h"

#import "AppleScript.h"

@interface AbstractWindowController ()
{
    FLOWindowMode _mode;
    BOOL _isDesktopMode;
    NSRect _normalFrame;
    CGFloat _titleBarHeight;
}

/// @property
///

@end

static AbstractWindowController *_sharedInstance = nil;

@implementation AbstractWindowController

#pragma mark - Singleton

+ (AbstractWindowController *)sharedInstance
{
    return _sharedInstance;
}

#pragma mark - Window lifecycle

- (void)awakeFromNib
{
    _sharedInstance = self;
    _mode = FLOWindowModeNormal;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setupUI];
    [self registerEventMonitor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter/Setter

- (FLOWindowMode)mode
{
    return _mode;
}

- (BOOL)isDesktopMode
{
    return _mode == FLOWindowModeDesktop;
}

- (NSRect)normalFrame
{
    return _normalFrame;
}

- (CGFloat)titleBarHeight
{
    return _titleBarHeight;
}

- (void)setMode
{
    if (_mode == FLOWindowModeNormal)
    {
        _mode = FLOWindowModeDesktop;
        _normalFrame = self.window.frame;
    }
    else
    {
        _mode = FLOWindowModeNormal;
    }
}

- (void)setTitleBarHeight
{
    _titleBarHeight = self.window.frame.size.height - self.window.contentView.frame.size.height;
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSRect visibleFrame = [self.window.screen visibleFrame];
    CGFloat width = 0.7 * visibleFrame.size.width;
    CGFloat height = 0.8 * visibleFrame.size.height;
    CGFloat x = (visibleFrame.size.width - width) / 2;
    CGFloat y = (visibleFrame.size.height + visibleFrame.origin.y - height) / 2;
    NSRect viewFrame = NSMakeRect(x, y, width, height);
    
    [self.window setFrame:viewFrame display:YES];
    //    [self.window setMinSize:NSMakeSize(0.7 * visibleFrame.size.width, 0.8 * visibleFrame.size.height)];
}

#pragma mark - Local methods

- (void)activate
{
    [self.window makeKeyAndOrderFront:nil];
}

- (void)changeWindowToDesktopMode
{
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask = NSWindowStyleMaskBorderless;
    [self.window makeKeyAndOrderFront:nil];
    self.window.level = [Utils windowLevelDesktop];
    
    [self.window setFrame:[self.window.screen visibleFrame] display:YES animate:YES];
}

- (void)changeWindowToNormalMode
{
    self.window.titleVisibility = NSWindowTitleVisible;
    self.window.styleMask = (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable);
    self.window.level = [Utils windowLevelBase];
    
    [self.window setFrame:self.normalFrame display:YES animate:YES];
}

- (void)showChildWindowsOnActivate
{
    NSWindowLevel levelNormal = [Utils windowLevelNormal];
    NSWindowLevel levelSetting = [Utils windowLevelSetting];
    NSWindowLevel levelUtility = [Utils windowLevelUtility];
    NSWindowLevel levelHigh = [Utils windowLevelHigh];
    NSWindowLevel levelAlert = [Utils windowLevelAlert];
    
    NSWindowLevel windowLevel = levelNormal;
    
    for (NSWindow *childWindow in self.window.childWindows)
    {
        windowLevel = levelNormal;
        
        if ([childWindow isKindOfClass:[FLOPopoverWindow class]])
        {
            switch (((FLOPopoverWindow *)childWindow).tag)
            {
                case WindowLevelGroupTagSetting:
                    windowLevel = levelSetting;
                    break;
                case WindowLevelGroupTagUtility:
                    windowLevel = levelUtility;
                    break;
                case WindowLevelGroupTagHigh:
                    windowLevel = levelHigh;
                    break;
                case WindowLevelGroupTagAlert:
                    windowLevel = levelAlert;
                    break;
                default:
                    break;
            }
        }
        
        childWindow.level = windowLevel;
    }
}

- (void)hideChildWindowsOnDeactivate
{
    NSWindowLevel levelBase = [Utils windowLevelBase];
    NSWindowLevel levelAlert = [Utils windowLevelAlert];
    BOOL shouldOrderChildWindows = NO;
    
    for (NSWindow *childWindow in self.window.childWindows)
    {
        if (childWindow.level != levelBase)
        {
            shouldOrderChildWindows = YES;
            
            childWindow.level = levelBase;
            
            // **NOTE: MUST have this line to make childWindow sink.
            // If we don't have this line the childWindow still floats on other active application,
            // even the childWindow.level is set as levelBase (NSNormalWindowLevel)
            [childWindow orderFront:self.window];
        }
    }
    
    BOOL shouldChildWindowsFloat = [Utils sharedInstance].shouldChildWindowsFloat;
    
    // If we want some childWindow float on other active application.
    if (shouldChildWindowsFloat)
    {
        //        for (NSWindow *childWindow in self.window.childWindows) {
        //            if ([childWindow isKindOfClass:[FLOPopoverWindow class]])
        //            {
        //                if (((FLOPopoverWindow *)childWindow).tag == WindowLevelGroupTagAlert)
        //                {
        //                    childWindow.level = levelAlert;
        //                }
        //            }
        //        }
    }
    
    // If none of childWindows floats on other active application. But we want to keep childWindow orders.
    if (!shouldChildWindowsFloat && shouldOrderChildWindows)
    {
    }
}

- (void)hideOtherAppsExceptThoseInside
{
    script_hideAllAppsExcept(kFlowarePopover_BundleIdentifier_Finder, kFlowarePopover_BundleIdentifier_Safari);
}

#pragma mark - Event handles

- (void)windowDidChangeMode:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kFlowarePopover_WindowDidChangeMode])
    {
        if (self.mode == FLOWindowModeDesktop)
        {
            [self changeWindowToDesktopMode];
            script_hideAllApps();
        }
        else
        {
            [self changeWindowToNormalMode];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"effectiveAppearance"] && [[change objectForKey:@"new"] isKindOfClass:[NSAppearance class]])
    {
        [NSAppearance setCurrentAppearance:[change objectForKey:@"new"]];
    }
}

#pragma mark - Event monitor

- (void)registerEventMonitor
{
    [self registerWindowChangeModeEvent];
    [self registerApplicationAppearanceNotification];
}

- (void)registerWindowChangeModeEvent
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeMode:) name:kFlowarePopover_WindowDidChangeMode object:nil];
}

- (void)removeWindowChangeModeEvent
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFlowarePopover_WindowDidChangeMode object:nil];
}

- (void)registerApplicationAppearanceNotification
{
    [self.window.contentView addObserver:self forKeyPath:@"effectiveAppearance"
                                 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                 context:NULL];
}

- (void)unregisterApplicationAppearanceNotification
{
    [self.window.contentView removeObserver:self forKeyPath:@"effectiveAppearance"];
}

@end
