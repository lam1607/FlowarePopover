//
//  FLOExtensionsGraphicsContext.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Graphics context creation

extern CGContextRef FLOExtensionsGraphicsContextCreate(CGSize size, CGColorSpaceRef colorSpace);

@interface FLOExtensionsGraphicsContext : NSObject

+ (NSImage *)imageRepresentationOnRect:(NSRect)rect representationWindow:(NSWindow *)representationWindow;
+ (NSImage *)screenShotView:(NSView *)aView forRect:(NSRect)aRect inWindow:(NSWindow *)aWindow;
+ (NSImage *)screenShotImageAtFrame:(NSRect)onFrame;
+ (NSImage *)snapshotImageFromView:(NSView *)view;

@end
