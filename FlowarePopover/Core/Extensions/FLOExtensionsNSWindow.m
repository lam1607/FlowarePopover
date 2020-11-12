//
//  FLOExtensionsNSWindow.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FLOExtensionsNSWindow.h"

@implementation NSWindow (FLOExtensionsNSWindow)

- (BOOL)containsChildWindow:(NSWindow *)child {
    return [[self class] windows:[self childWindows] contain:child];
}

#pragma mark - Class methods

+ (BOOL)windows:(NSArray *)windows contain:(NSWindow *)window {
    if ([windows containsObject:window]) {
        return YES;
    } else {
        for (NSWindow *item in windows) {
            if ([[self class] windows:[item childWindows] contain:window]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
