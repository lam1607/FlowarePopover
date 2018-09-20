//
//  FLOGraphicsContext.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark - Graphics context creation
extern CGContextRef FLOCreateGraphicsContext(CGSize size, CGColorSpaceRef colorSpace);

@interface FLOGraphicsContext : NSObject

+ (NSImage *)imageRepresentationOnRect:(NSRect)rect representationWindow:(NSWindow *)representationWindow;
+ (NSImage *)screenShotView:(NSView *)aView forRect:(NSRect)aRect inWindow:(NSWindow *)aWindow;
+ (NSImage *)desktopScreenShotOnFrame:(NSRect)onFrame;
+ (NSImage *)snapshotImageFromView:(NSView *)view;

@end
