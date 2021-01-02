//
//  AbstractWindowController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractWindowProtocols.h"

@interface AbstractWindowController : NSWindowController

/// Protocols
///
@property (nonatomic, weak) id<AbstractWindowProtocols> protocols;

/// @property
///
@property (nonatomic, assign, readonly) NSRect normalFrame;
@property (nonatomic, assign, readonly) CGFloat titleBarHeight;

/// Singleton
///
+ (AbstractWindowController *)sharedInstance;

/// Methods
///
- (void)setTitleBarHeight;
- (FLOVirtualView *)setUserInteractionEnabled:(BOOL)isEnabled;

- (void)activate;

@end
