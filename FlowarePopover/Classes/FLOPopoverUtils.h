//
//  FLOPopoverUtils.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLOPopoverConstants.h"

@interface FLOPopoverUtils : NSObject

+ (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame withAnimationType:(FLOPopoverAnimationTransition)animationType showing:(BOOL)showing;

@end
