//
//  FLOPopoverWindowController.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark -
#pragma mark - FLOPopoverWindow
#pragma mark -
@interface FLOPopoverWindow : NSWindow

@property (nonatomic, assign) BOOL canBecomeKey;

@end

#pragma mark -
#pragma mark - FLOPopoverWindowController
#pragma mark -
@interface FLOPopoverWindowController : NSWindowController

@end
