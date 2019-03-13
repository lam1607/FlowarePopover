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
@property (nonatomic, assign, readonly) FLOWindowMode mode;
@property (nonatomic, assign, readonly) BOOL isDesktopMode;
@property (nonatomic, assign, readonly) NSRect normalFrame;
@property (nonatomic, assign, readonly) CGFloat titleBarHeight;

/// Singleton
///
+ (AbstractWindowController *)sharedInstance;

/// Methods
///
- (void)setMode;
- (void)setTitleBarHeight;

- (void)activate;
- (void)hideChildWindowsOnDeactivate;
- (void)showChildWindowsOnActivate;
- (void)hideOtherAppsExceptThoseInside;

@end
