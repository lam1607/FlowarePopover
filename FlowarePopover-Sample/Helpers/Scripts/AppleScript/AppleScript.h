//
//  AppleScript.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/13/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

typedef NS_ENUM(NSInteger, AppleScriptResult)
{
    AppleScriptResultUnknown = 0,
    AppleScriptResultError,
    AppleScriptResultSystemEventNotEnabled,
    AppleScriptResultSuccess
};

extern void script_openFile(NSString *appName, NSString *filePath, float x, float y, float w, float h);
extern void script_hideFile(NSString *appName, NSString *filePath);
extern void script_closeFile(NSString *appName, NSString *filePath);
extern void script_openApplication(NSString *appName, float x, float y, float w, float h);
extern void script_hideApplication(NSString *appName);
extern void script_closeApplication(NSString *appName);

extern BOOL script_closeWindow(NSString *appName, NSString *title);
extern BOOL script_checkAppHidden(NSString *bundleIdentifier);
extern BOOL script_checkMinimized(NSString *appName, NSString *property, NSString *title);
extern BOOL script_checkWinMinimized(NSString *appName);
extern BOOL script_checkWinCollapsed(NSString *appName);
extern BOOL script_checkWinHidden(NSString *appName);
extern BOOL script_checkFirstWinExist(NSString *appName);
extern void script_positionApp(NSString *appName, float x, float y);

extern void script_showApp(NSString *app);
extern void script_hideApp(NSString *bundleIdentifier);
extern void script_hideAllAppsExcept(NSString *bundleIdentifier1, NSString *bundleIdentifier2);
extern void script_hideAllApps(void);
extern void script_autoHideDock(BOOL hidden);
extern BOOL script_checkDockAutoHidden(void);
extern int script_openApp(NSString *appName, BOOL shouldActive);
extern void script_openMSApp(NSString *appName, BOOL openNewDocument);
extern void script_openAccessibilityPreference(void);

extern void script_activateApplication(NSString *appName);
extern int script_resizeApplication(NSString *appName, NSString *bundle, NSInteger x, NSInteger y, NSInteger width, NSInteger height, BOOL autoArrange);
extern int script_resizeDocument(NSString *appName, NSString *fullPath, NSString *siblingTitle, NSInteger x, NSInteger y, NSInteger width, NSInteger height, BOOL autoArrange);

@interface AppleScript : NSObject

@end
