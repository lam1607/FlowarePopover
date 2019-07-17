//
//  FLOExtensionsNSWindow.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FLOExtensionsNSWindow.h"

#import "FLOExtensionsGraphicsContext.h"

@implementation NSWindow (FLOExtensionsNSWindow)

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame {
    [self showingAnimated:showing fromFrame:fromFrame toFrame:toFrame source:nil];
}

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame source:(id)source {
    [self showingAnimated:showing fromFrame:fromFrame toFrame:toFrame duration:0.2 source:source];
}

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame duration:(NSTimeInterval)duration source:(id)source {
    if (showing) {
        [self setFrame:toFrame display:NO];
        self.alphaValue = 0.0;
    }
    
    NSString *fadeEffect = showing ? NSViewAnimationFadeInEffect : NSViewAnimationFadeOutEffect;
    
    NSDictionary *effectAttr = [[NSDictionary alloc] initWithObjectsAndKeys: self, NSViewAnimationTargetKey,
                                [NSValue valueWithRect:fromFrame], NSViewAnimationStartFrameKey,
                                [NSValue valueWithRect:toFrame], NSViewAnimationEndFrameKey,
                                fadeEffect, NSViewAnimationEffectKey, nil];
    
    NSArray *effects = [[NSArray alloc] initWithObjects:effectAttr, nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:effects];
    
    animation.animationBlockingMode = NSAnimationBlocking;
    animation.animationCurve = NSAnimationEaseInOut;
    animation.frameRate = 0.0;
    animation.duration = duration;
    animation.delegate = source;
    [animation startAnimation];
}

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition {
    [self showingAnimated:showing fromPosition:fromPosition toPosition:toPosition completionHandler:nil];
}

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition completionHandler:(void(^)(void))complete {
    [self showingAnimated:showing fromPosition:fromPosition toPosition:toPosition duration:0.2 completionHandler:complete];
}

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition duration:(NSTimeInterval)duration completionHandler:(void(^)(void))complete {
    [[self animator] setFrameOrigin:fromPosition];
    [[self animator] setAlphaValue:showing ? 0.0 : 1.0];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [[self animator] setFrameOrigin:toPosition];
        
        if (complete != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:complete];
        }
    }];
    
    [[self animator] setFrameOrigin:toPosition];
    [[self animator] setAlphaValue:showing ? 1.0 : 0.0];
    [NSAnimationContext endGrouping];
}

@end
