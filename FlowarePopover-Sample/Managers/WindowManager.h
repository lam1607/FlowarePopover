//
//  WindowManager.h
//  FLOPopupPrototypes
//
//  Created by Lam Nguyen on 9/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, WindowLevelGroupTag)
{
    WindowLevelGroupTagDesktop          = kCGDesktopIconWindowLevel + 1,
    WindowLevelGroupTagNormal           = kCGNormalWindowLevel,
    WindowLevelGroupTagFloat            = kCGNormalWindowLevel + 1,
    WindowLevelGroupTagMiddle           = kCGNormalWindowLevel + 2,
    WindowLevelGroupTagSetting          = kCGFloatingWindowLevel,
    WindowLevelGroupTagMenu             = kCGFloatingWindowLevel + 2,
    WindowLevelGroupTagAlert            = kCGFloatingWindowLevel + 3,
    WindowLevelGroupTagTop              = kCGFloatingWindowLevel + 4,
};


@interface WindowManager : NSObject

@property (nonatomic, assign, readonly) BOOL userInteractionEnabled;
@property (nonatomic, assign, readonly) BOOL menuItemsEnabled;

#pragma mark - Singleton

+ (WindowManager *)sharedInstance;

#pragma mark - Methods

- (void)setNSAppearanceProtocolOwner;

+ (void)changeWindowsEffectiveAppearance;

+ (BOOL)shouldChildWindowsFloat;
+ (void)hideChildWindows;
+ (void)showChildWindows;
+ (FLOVirtualView *)setUserInteractionEnable:(BOOL)isEnabled withMenuItemsEnable:(BOOL)isMenuItemsEnable;
+ (FLOVirtualView *)setUserInteractionEnable:(BOOL)isEnabled withMenuItemsEnable:(BOOL)isMenuItemsEnable disabledColor:(NSColor *)disabledColor;
+ (void)excludeDisableForWindow:(NSWindow *)window;

+ (void)floatUpdateWindowsIfNeeded;
+ (BOOL)isUpdateWindow:(NSWindow *)window;
+ (BOOL)isUpdateAlert:(NSWindow *)window;

+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag;
+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag floatsWhenAppResignsActive:(BOOL)floatsWhenAppResignsActive;
+ (NSRect)fitFrame:(NSRect)frame toContainer:(NSRect)containerFrame;

@end
