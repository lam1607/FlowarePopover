//
//  FLOPopoverWindow.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOPopoverWindow.h"

@implementation FLOPopoverWindow

- (instancetype)init {
    if (self = [super init]) {
        _tag = -1;
        _userInteractionEnable = YES;
        _floatsWhenAppResignsActive = NO;
    }
    
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        _tag = -1;
        _userInteractionEnable = YES;
        _floatsWhenAppResignsActive = NO;
    }
    
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return (self.userInteractionEnable ? self.canBecomeKey : NO);
}

@end
