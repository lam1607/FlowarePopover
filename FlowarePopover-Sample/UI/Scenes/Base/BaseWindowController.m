//
//  BaseWindowController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "BaseWindowController.h"

#import "FLOPopoverUtils.h"

#import "AppDelegate.h"

#import "AppleScript.h"

@interface BaseWindowController ()

@property (nonatomic, assign, readwrite) FLOWindowMode windowMode;
@property (nonatomic, assign, readwrite) BOOL windowInDesktopMode;
@property (nonatomic, assign, readwrite) NSRect windowNormalFrame;
@property (nonatomic, assign, readwrite) CGFloat windowTitleBarHeight;

@end

static BaseWindowController *_sharedInstance = nil;

@implementation BaseWindowController

@synthesize windowMode = _windowMode;
@synthesize windowTitleBarHeight = _windowTitleBarHeight;

#pragma mark -
#pragma mark - Singleton
#pragma mark -
+ (BaseWindowController *)sharedInstance {
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Window lifecycle
#pragma mark -
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

#pragma mark -
#pragma mark - Getter/Setter
#pragma mark -
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

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    NSRect visibleFrame = [self.window.screen visibleFrame];
    CGFloat width = 0.6 * visibleFrame.size.width;
    CGFloat height = 0.7 * visibleFrame.size.height;
    CGFloat x = (visibleFrame.size.width - width) / 2;
    CGFloat y = (visibleFrame.size.height + visibleFrame.origin.y - height) / 2;
    NSRect viewFrame = NSMakeRect(x, y, width, height);
    
    [self.window setFrame:viewFrame display:YES];
    [self.window setMinSize:NSMakeSize(0.6 * visibleFrame.size.width, 0.7 * visibleFrame.size.height)];
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)activate {
    [self.window makeKeyAndOrderFront:nil];
}

- (void)changeWindowToDesktopMode {
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask = NSWindowStyleMaskBorderless;
    [self.window makeKeyAndOrderFront:nil];
    self.window.level = kCGDesktopIconWindowLevel + 1;
    
    [self.window setFrame:[self.window.screen visibleFrame] display:YES animate:YES];
}

- (void)changeWindowToNormalMode {
    self.window.titleVisibility = NSWindowTitleVisible;
    self.window.styleMask = (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable);
    self.window.level = NSNormalWindowLevel;
    
    [self.window setFrame:self.windowNormalFrame display:YES animate:YES];
}

- (void)showChildenWindowsOnActivate {
    for (NSWindow *childWindow in self.window.childWindows) {
        if (childWindow.level >= self.window.level) {
            if (childWindow == [FLOPopoverUtils sharedInstance].topWindow) {
                childWindow.level = NSStatusWindowLevel;
            } else {
                childWindow.level = NSFloatingWindowLevel;
            }
        }
    }
}

- (void)hideChildenWindowsOnDeactivate {
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    
    for (NSWindow *childWindow in self.window.childWindows) {
        if (![appDelegate isEntitlementAppFocused]) {
            childWindow.level = self.window.level;
        } else {
            if (childWindow == [FLOPopoverUtils sharedInstance].topWindow) {
                childWindow.level = NSFloatingWindowLevel;
            } else {
                childWindow.level = self.window.level;
            }
        }
    }
}

- (void)hideOtherAppsExceptThoseInside {
    AppleScriptHideAllAppsExcept(FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER, FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI);
}

#pragma mark -
#pragma mark - Event handles
#pragma mark -
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

#pragma mark -
#pragma mark - Event monitor
#pragma mark -
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
