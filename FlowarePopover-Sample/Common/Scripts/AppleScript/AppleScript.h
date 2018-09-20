//
//  AppleScript.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/13/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void AppleScriptOpenFile(NSString *appName, NSString *filePath, float x, float y, float w, float h);
extern void AppleScriptHideFile(NSString *appName, NSString *filePath);
extern void AppleScriptCloseFile(NSString *appName, NSString *filePath);
extern void AppleScriptOpenApplication(NSString *appName, float x, float y, float w, float h);
extern void AppleScriptHideApplication(NSString *appName);
extern void AppleScriptCloseApplication(NSString *appName);

extern BOOL AppleScriptCloseWindow(NSString *appName, NSString *title);
extern BOOL AppleScriptCheckAppHidden(NSString *bundleIdentifier);
extern BOOL AppleScriptCheckMinimized(NSString *appName, NSString *property, NSString *title);
extern BOOL AppleScriptCheckWinMinimized(NSString *appName);
extern BOOL AppleScriptCheckWinCollapsed(NSString *appName);
extern BOOL AppleScriptCheckWinHidden(NSString *appName);
extern BOOL AppleScriptCheckFirstWinExist(NSString *appName);
extern void AppleScriptPositionApp(NSString *appName, float x, float y);

extern void AppleScriptShowApp(NSString *app);
extern void AppleScriptHideApp(NSString *bundleIdentifier);
extern void AppleScriptHideAllAppsExcept(NSString *bundleIdentifier1, NSString *bundleIdentifier2);
extern void AppleScriptHideAllApps();
extern void AppleScriptAutoHideDock(BOOL hidden);
extern BOOL AppleScriptCheckDockAutoHidden();
extern void AppleScriptOpenApp(NSString *appName);
extern void AppleScriptOpenMSAppWithNewDocument(NSString *appName);
extern void AppleScriptOpenAccessibilityPreference();

#pragma mark -
#pragma mark - Updated scripts
#pragma mark -
extern int AppleScriptPresentDocument(NSString *appName, NSString *title, NSString *siblingTitle, float x, float y, float w, float h, BOOL needResize);
extern int AppleScriptPresentApp(NSString *appName, NSString *bundle, float x, float y, float maxWidth, float maxHeight, BOOL needResize);
extern void AppleScriptActivateApplication(NSString *appName);

@interface AppleScript : NSObject

@end
