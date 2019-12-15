//
//  AbstractViewController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractViewProtocols.h"

@interface AbstractViewController : NSViewController <AbstractViewProtocols>

- (void)addView:(NSView *)child toParent:(NSView *)parent;
- (void)addView:(NSView *)child toParent:(NSView *)parent needConstraints:(BOOL)needConstraints;

@end
