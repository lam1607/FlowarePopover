//
//  AbstractWindowController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AbstractWindowController : NSWindowController

/// @property
///
@property (nonatomic, assign, readonly) FLOWindowMode windowMode;
@property (nonatomic, assign, readonly) BOOL windowInDesktopMode;
@property (nonatomic, assign, readonly) NSRect windowNormalFrame;
@property (nonatomic, assign, readonly) CGFloat windowTitleBarHeight;

/// Singleton
///
+ (AbstractWindowController *)sharedInstance;

/// Methods
///
- (void)setWindowMode;
- (void)setWindowTitleBarHeight;

- (void)activate;
- (void)hideChildWindowsOnDeactivate;
- (void)showChildWindowsOnActivate;
- (void)hideOtherAppsExceptThoseInside;

@end
