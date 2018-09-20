//
//  FLOPopoverUtils.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverUtils.h"

@implementation FLOPopoverUtils

+ (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame withAnimationType:(FLOPopoverAnimationTransition)animationType showing:(BOOL)showing {
    switch (animationType) {
        case FLOPopoverAnimationLeftToRight:
            if (showing) {
                (*fromFrame).origin.x -= (*toFrame).size.width / 2;
            } else {
                (*toFrame).origin.x -= (*fromFrame).size.width / 2;
            }
            break;
        case FLOPopoverAnimationRightToLeft:
            if (showing) {
                (*fromFrame).origin.x += (*toFrame).size.width / 2;
            } else {
                (*toFrame).origin.x += (*fromFrame).size.width / 2;
            }
            break;
        case FLOPopoverAnimationTopToBottom:
            if (showing) {
                (*fromFrame).origin.y += (*toFrame).size.height / 2;
            } else {
                (*toFrame).origin.y += (*fromFrame).size.height / 2;
            }
            break;
        case FLOPopoverAnimationBottomToTop:
            if (showing) {
                (*fromFrame).origin.y -= (*toFrame).size.height / 2;
            } else {
                (*toFrame).origin.y -= (*fromFrame).size.height / 2;
            }
            break;
        case FLOPopoverAnimationFromMiddle:
            break;
        default:
            break;
    }
}

@end
