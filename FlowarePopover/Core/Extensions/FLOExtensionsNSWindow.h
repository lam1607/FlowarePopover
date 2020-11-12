//
//  FLOExtensionsNSWindow.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSWindow (FLOExtensionsNSWindow)

- (BOOL)containsChildWindow:(NSWindow *)child;

/// Class methods
///
+ (BOOL)windows:(NSArray *)windows contain:(NSWindow *)window;

@end
