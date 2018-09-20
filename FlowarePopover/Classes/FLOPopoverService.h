//
//  FLOPopoverService.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FLOPopoverService <NSObject>

@property (nonatomic, copy) void (^popoverDidClose)(NSResponder *popover);
@property (nonatomic, copy) void (^popoverDidShow)(NSResponder *popover);

@optional
/*
 * @Inits
 */
- (id)initWithContentView:(NSView *)contentView;
- (id)initWithContentViewController:(NSViewController *)contentViewController;

/*
 * @Display
 */

@required
- (IBAction)closePopover:(NSResponder *)sender;
- (void)closePopover:(NSResponder *)sender completion:(void(^)(void))complete;

@end
