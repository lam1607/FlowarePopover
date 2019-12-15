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
    WindowLevelGroupTagSetting          = kCGNormalWindowLevel + 2,
    WindowLevelGroupTagAlert            = kCGModalPanelWindowLevel,
    WindowLevelGroupTagTop              = kCGModalPanelWindowLevel + 1,
};


@interface WindowManager : NSObject

@property (nonatomic, assign, readonly) BOOL shouldChildWindowsFloat;

#pragma mark - Singleton

+ (WindowManager *)sharedInstance;

#pragma mark - Methods

- (void)hideChildWindows;
- (void)showChildWindows;

+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag;
+ (NSWindowLevel)levelForTag:(WindowLevelGroupTag)tag floatsWhenAppResignsActive:(BOOL)floatsWhenAppResignsActive;
+ (NSRect)fitFrame:(NSRect)frame toContainer:(NSRect)containerFrame;

@end
