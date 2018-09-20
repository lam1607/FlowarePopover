//
//  FLOExtensionsNSWindow.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface NSWindow (FLOExtensionsNSWindow)

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame;
- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame source:(id)source;
- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame duration:(NSTimeInterval)duration source:(id)source;

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition;
- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition completionHandler:(void(^)(void))complete;
- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition duration:(NSTimeInterval)duration completionHandler:(void(^)(void))complete;

@end
