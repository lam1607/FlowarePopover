//
//  AbstractWindow.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/16/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractWindow.h"

@interface AbstractWindow ()
{
    BOOL _isOrdering;
}

@end

@implementation AbstractWindow

#pragma mark - Override methods

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)addChildWindow:(NSWindow *)childWin ordered:(NSWindowOrderingMode)place
{
    [super addChildWindow:childWin ordered:place];
    
    if (_isOrdering) return;
    
    [self orderChildWindowsIfNeeded];
}

#pragma mark - Local methods

- (void)orderChildWindowsIfNeeded
{
    if (_isOrdering) return;
    
    _isOrdering = YES;
    
    @autoreleasepool
    {
        NSMutableArray *popupNormals = [[NSMutableArray alloc] init];
        NSMutableArray *popupSettings = [[NSMutableArray alloc] init];
        NSMutableArray *popupAlerts = [[NSMutableArray alloc] init];
        NSMutableArray *popupTops = [[NSMutableArray alloc] init];
        
        for (NSWindow *childWindow in self.childWindows)
        {
            if ([childWindow isKindOfClass:[FLOPopoverWindow class]])
            {
                switch (((FLOPopoverWindow *)childWindow).tag)
                {
                    case WindowLevelGroupTagSetting:
                        [popupSettings addObject:childWindow];
                        break;
                    case WindowLevelGroupTagAlert:
                        [popupAlerts addObject:childWindow];
                        break;
                    case WindowLevelGroupTagTop:
                        [popupTops addObject:childWindow];
                        break;
                    default:
                        [popupNormals addObject:childWindow];
                        break;
                }
            }
            else if ([childWindow isKindOfClass:[NSPanel class]])
            {
                [popupAlerts addObject:childWindow];
            }
            else
            {
                [popupNormals addObject:childWindow];
            }
        }
        
        NSMutableArray *childWindows = [[NSMutableArray alloc] init];
        
        if (popupNormals.count)
        {
            [childWindows addObjectsFromArray:popupNormals];
        }
        
        if (popupSettings.count)
        {
            [childWindows addObjectsFromArray:popupSettings];
        }
        
        if (popupAlerts.count)
        {
            [childWindows addObjectsFromArray:popupAlerts];
        }
        
        if (popupTops.count)
        {
            [childWindows addObjectsFromArray:popupTops];
        }
        
        for (NSWindow *window in childWindows)
        {
            NSWindowLevel level = [WindowManager levelForTag:WindowLevelGroupTagFloat];
            
            if ([window isKindOfClass:[FLOPopoverWindow class]])
            {
                level = [WindowManager levelForTag:((FLOPopoverWindow *)window).tag];
            }
            
            [self removeChildWindow:window];
            [self addChildWindow:window ordered:NSWindowAbove];
            
            [window setLevel:level];
            [[window attachedSheet] setLevel:([[NSApplication sharedApplication] isActive] ? (window.level + 1) : window.level)];
        }
        
        popupNormals = nil;
        popupSettings = nil;
        popupAlerts = nil;
        popupTops = nil;
        
        _isOrdering = NO;
    }
}

@end
