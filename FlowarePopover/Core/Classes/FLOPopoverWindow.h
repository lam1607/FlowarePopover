//
//  FLOPopoverWindow.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FLOPopoverWindow : NSWindow

@property (nonatomic, assign) BOOL canBecomeKey;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL userInteractionEnable;

/**
 * This property is used out side of this scope for handling
 * whether the popover floats or not when application resigns active.
 */
@property (nonatomic, assign) BOOL floatsWhenAppResignsActive;

@end
