//
//  AbstractWindowController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractWindowController.h"

#import "FLOPopover.h"

#import "AppDelegate.h"

#import "AppleScript.h"

@interface AbstractWindowController ()

/// @property
///
@property (nonatomic, assign, readwrite) FLOWindowMode windowMode;
@property (nonatomic, assign, readwrite) BOOL windowInDesktopMode;
@property (nonatomic, assign, readwrite) NSRect windowNormalFrame;
@property (nonatomic, assign, readwrite) CGFloat windowTitleBarHeight;

@end

static AbstractWindowController *_sharedInstance = nil;

@implementation AbstractWindowController

@synthesize windowMode = _windowMode;
@synthesize windowTitleBarHeight = _windowTitleBarHeight;

#pragma mark - Singleton

+ (AbstractWindowController *)sharedInstance {
    return _sharedInstance;
}

#pragma mark - Window lifecycle

- (void)awakeFromNib {
    _sharedInstance = self;
    _windowMode = FLOWindowModeNormal;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setupUI];
    [self registerEventMonitor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter/Setter

- (FLOWindowMode)windowMode {
    return _windowMode;
}

- (BOOL)windowInDesktopMode {
    return self.windowMode == FLOWindowModeDesktop;
}

- (NSRect)windowNormalFrame {
    return _windowNormalFrame;
}

- (CGFloat)windowTitleBarHeight {
    return _windowTitleBarHeight;
}

- (void)setWindowMode {
    if (_windowMode == FLOWindowModeNormal) {
        _windowMode = FLOWindowModeDesktop;
        _windowNormalFrame = self.window.frame;
    } else {
        _windowMode = FLOWindowModeNormal;
    }
}

- (void)setWindowTitleBarHeight {
    _windowTitleBarHeight = self.window.frame.size.height - self.window.contentView.frame.size.height;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSRect visibleFrame = [self.window.screen visibleFrame];
    CGFloat width = 0.7 * visibleFrame.size.width;
    CGFloat height = 0.8 * visibleFrame.size.height;
    CGFloat x = (visibleFrame.size.width - width) / 2;
    CGFloat y = (visibleFrame.size.height + visibleFrame.origin.y - height) / 2;
    NSRect viewFrame = NSMakeRect(x, y, width, height);
    
    [self.window setFrame:viewFrame display:YES];
    [self.window setMinSize:NSMakeSize(0.7 * visibleFrame.size.width, 0.8 * visibleFrame.size.height)];
}

#pragma mark - Processes

- (void)activate {
    [self.window makeKeyAndOrderFront:nil];
}

- (void)changeWindowToDesktopMode {
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask = NSWindowStyleMaskBorderless;
    [self.window makeKeyAndOrderFront:nil];
    self.window.level = [Utils windowLevelDesktop];
    
    [self.window setFrame:[self.window.screen visibleFrame] display:YES animate:YES];
}

- (void)changeWindowToNormalMode {
    self.window.titleVisibility = NSWindowTitleVisible;
    self.window.styleMask = (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable);
    self.window.level = [Utils windowLevelBase];
    
    [self.window setFrame:self.windowNormalFrame display:YES animate:YES];
}

- (void)showChildWindowsOnActivate {
    NSWindowLevel levelNormal = [Utils windowLevelNormal];
    NSWindowLevel levelSetting = [Utils windowLevelSetting];
    NSWindowLevel levelUtility = [Utils windowLevelUtility];
    NSWindowLevel levelHigh = [Utils windowLevelHigh];
    NSWindowLevel levelAlert = [Utils windowLevelAlert];
    
    NSWindowLevel windowLevel = levelNormal;
    
    for (NSWindow *childWindow in self.window.childWindows) {
        windowLevel = levelNormal;
        
        if ([childWindow isKindOfClass:[FLOPopoverWindow class]]) {
            switch (((FLOPopoverWindow *)childWindow).tag) {
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

- (void)hideChildWindowsOnDeactivate {
    NSWindowLevel levelBase = [Utils windowLevelBase];
    NSWindowLevel levelAlert = [Utils windowLevelAlert];
    BOOL shouldOrderChildWindows = NO;
    
    for (NSWindow *childWindow in self.window.childWindows) {
        if (childWindow.level != levelBase) {
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
    if (shouldChildWindowsFloat) {
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
    if ((shouldChildWindowsFloat == NO) && shouldOrderChildWindows) {
    }
}

- (void)hideOtherAppsExceptThoseInside {
    AppleScriptHideAllAppsExcept(FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER, FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI);
}

#pragma mark - Event handles

- (void)windowDidChangeMode:(NSNotification *)notification {
    if ([notification.name isEqualToString:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE]) {
        if (self.windowMode == FLOWindowModeDesktop) {
            [self changeWindowToDesktopMode];
            AppleScriptHideAllApps();
        } else {
            [self changeWindowToNormalMode];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"effectiveAppearance"] && [[change objectForKey:@"new"] isKindOfClass:[NSAppearance class]]) {
        [NSAppearance setCurrentAppearance:[change objectForKey:@"new"]];
    }
}

#pragma mark - Event monitor

- (void)registerEventMonitor {
    [self registerWindowChangeModeEvent];
    [self registerApplicationAppearanceNotification];
}

- (void)registerWindowChangeModeEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeMode:) name:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE object:nil];
}

- (void)removeWindowChangeModeEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE object:nil];
}

- (void)registerApplicationAppearanceNotification {
    [self.window.contentView addObserver:self forKeyPath:@"effectiveAppearance"
                                 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                 context:NULL];
}

- (void)unregisterApplicationAppearanceNotification {
    [self.window.contentView removeObserver:self forKeyPath:@"effectiveAppearance"];
}

@end
