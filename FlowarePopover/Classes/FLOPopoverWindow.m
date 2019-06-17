//
//  FLOPopoverWindow.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOPopoverWindow.h"

@implementation FLOPopoverWindow

@synthesize tag = _tag;

- (instancetype)init {
    if (self = [super init]) {
        _tag = -1;
    }
    
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return self.canBecomeKey;
}

@end
