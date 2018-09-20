//
//  BaseWindowController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "BaseWindowController.h"

#import "FLOPopoverWindowController.h"

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
    [self registerWindowChangeModeEvent];
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
    CGFloat width = 0.6f * visibleFrame.size.width;
    CGFloat height = 0.7f * visibleFrame.size.height;
    CGFloat x = (visibleFrame.size.width - width) / 2;
    CGFloat y = (visibleFrame.size.height + visibleFrame.origin.y - height) / 2;
    NSRect viewFrame = NSMakeRect(x, y, width, height);
    
    [self.window setFrame:viewFrame display:YES];
    [self.window setMinSize:NSMakeSize(0.5f * visibleFrame.size.width, 0.5f * visibleFrame.size.height)];
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)activate {
    [self.window makeKeyAndOrderFront:nil];
}

- (void)changeWindowToDesktopMode {
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask = NSBorderlessWindowMask;
    [self.window makeKeyAndOrderFront:nil];
    self.window.level = kCGDesktopIconWindowLevel + 1;
    
    [self.window setFrame:[self.window.screen visibleFrame] display:YES animate:YES];
}

- (void)changeWindowToNormalMode {
    self.window.titleVisibility = NSWindowTitleVisible;
    self.window.styleMask = (NSWindowStyleMaskTitled | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask);
    self.window.level = NSNormalWindowLevel;
    
    [self.window setFrame:self.windowNormalFrame display:YES animate:YES];
}

- (void)showChildenWindowsOnActivate {
    for (NSWindow *childWindow in self.window.childWindows) {
        if (childWindow.level >= self.window.level) {
            if (childWindow == [FLOPopoverWindow sharedInstance].topWindow) {
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
            if (childWindow == [FLOPopoverWindow sharedInstance].topWindow) {
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
#pragma mark - Notification
#pragma mark -
- (void)registerWindowChangeModeEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeMode:) name:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE object:nil];
}

- (void)removeWindowChangeModeEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE object:nil];
}

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

@end
