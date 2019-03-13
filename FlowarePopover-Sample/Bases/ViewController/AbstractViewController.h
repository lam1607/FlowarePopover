//
//  AbstractViewController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AbstractViewController : NSViewController

- (void)refreshUIColors;
- (void)addView:(NSView *)child toParent:(NSView *)parent;
- (void)addView:(NSView *)child toParent:(NSView *)parent needConstraints:(BOOL)needConstraints;

@end
