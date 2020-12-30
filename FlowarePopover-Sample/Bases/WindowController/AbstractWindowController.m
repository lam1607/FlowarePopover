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
    NSRect _normalFrame;
    CGFloat _titleBarHeight;
    
    FLOVirtualView *_disableView;
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

- (NSRect)normalFrame
{
    return _normalFrame;
}

- (CGFloat)titleBarHeight
{
    return _titleBarHeight;
}

- (void)setTitleBarHeight
{
    _titleBarHeight = self.window.frame.size.height - self.window.contentView.frame.size.height;
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSRect visibleFrame = [self.window.screen visibleFrame];
    // CGFloat width = 0.7 * visibleFrame.size.width;
    // CGFloat height = 0.8 * visibleFrame.size.height;
    CGFloat width = 883.0;
    CGFloat height = 767.0;
    CGFloat x = (visibleFrame.size.width - width) / 2;
    CGFloat y = (visibleFrame.size.height + visibleFrame.origin.y - height) / 2;
    NSRect viewFrame = NSMakeRect(x, y, width, height);
    
    [self.window setFrame:viewFrame display:YES];
    // [self.window setMinSize:NSMakeSize(0.7 * visibleFrame.size.width, 0.8 * visibleFrame.size.height)];
}

#pragma mark - Local methods

- (void)changeToDesktopMode
{
    [[self window] setTitleVisibility:NSWindowTitleHidden];
    [[self window] setStyleMask:NSWindowStyleMaskBorderless];
    [[self window] makeKeyAndOrderFront:nil];
    [[self window] setLevel:[WindowManager levelForTag:WindowLevelGroupTagDesktop]];
    [[self window] setFrame:[[[self window] screen] visibleFrame] display:YES animate:YES];
}

- (void)changeToNormalMode
{
    [[self window] setTitleVisibility:NSWindowTitleVisible];
    [[self window] setStyleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)];
    [[self window] makeKeyAndOrderFront:nil];
    [[self window] setLevel:[WindowManager levelForTag:WindowLevelGroupTagNormal]];
    [[self window] setFrame:self.normalFrame display:YES animate:YES];
}

#pragma mark - AbstractWindowController methods

- (FLOVirtualView *)setUserInteractionEnabled:(BOOL)isEnabled
{
    NSView *contentView = [self.window contentView];
    
    FLOVirtualView *disableView = _disableView;
    
    if (isEnabled)
    {
        if ([disableView isDescendantOf:contentView])
        {
            [disableView removeFromSuperview];
            _disableView = nil;
        }
    }
    else
    {
        if (disableView == nil)
        {
            disableView = [[FLOVirtualView alloc] initWithFrame:contentView.frame type:FLOVirtualViewDisable];
        }
        
        if (![disableView isDescendantOf:contentView])
        {
            [contentView addSubview:disableView];
            
            [disableView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[disableView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(disableView)]];
            
            [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[disableView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(disableView)]];
            
            _disableView = disableView;
        }
    }
    
    return _disableView;
}

- (void)activate
{
    [self.window makeKeyAndOrderFront:nil];
}

#pragma mark - Event handles

- (void)windowWillChangeMode:(NSNotification *)notification
{
    if (![notification.name isEqualToString:kFlowarePopover_WindowWillChangeModeNotification]) return;
    
    if ([[SettingsManager sharedInstance] isNormalMode])
    {
        _normalFrame = self.window.frame;
    }
}

- (void)windowDidChangeMode:(NSNotification *)notification
{
    if (![notification.name isEqualToString:kFlowarePopover_WindowDidChangeModeNotification]) return;
    
    if ([[SettingsManager sharedInstance] isDesktopMode])
    {
        [self changeToDesktopMode];
        script_hideAllApps();
    }
    else
    {
        [self changeToNormalMode];
    }
}

#pragma mark - Event monitor

- (void)registerEventMonitor
{
    [self registerWindowChangeModeEvent];
}

- (void)registerWindowChangeModeEvent
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillChangeMode:) name:kFlowarePopover_WindowWillChangeModeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeMode:) name:kFlowarePopover_WindowDidChangeModeNotification object:nil];
}

- (void)removeWindowChangeModeEvent
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFlowarePopover_WindowWillChangeModeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFlowarePopover_WindowDidChangeModeNotification object:nil];
}

@end
