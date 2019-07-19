//
//  FLOVirtualView.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 7/19/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"

@interface FLOVirtualView : NSView

#pragma mark - Properties

@property (nonatomic, assign, readonly) FLOVirtualViewType type;

#pragma mark - Initialize

- (instancetype)initWithFrame:(NSRect)frameRect type:(FLOVirtualViewType)type;

@end
