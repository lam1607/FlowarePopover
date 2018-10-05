//
//  FLOPopoverService.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FLOPopoverService <NSObject>

@property (nonatomic, copy) void (^popoverDidCloseCallback)(NSResponder *popover);
@property (nonatomic, copy) void (^popoverDidShowCallback)(NSResponder *popover);

@optional

#pragma mark -
#pragma mark - Initialize
#pragma mark -
/**
 * Initialize the FLOPopover with content view and type is FLOViewPopover by default.
 *
 * @param contentView the view needs displayed on FLOPopover
 * @return FLOPopover instance
 */
- (id)initWithContentView:(NSView *)contentView;

/**
 * Initialize the FLOPopover with content view controller and type is FLOViewPopover by default.
 *
 * @param contentViewController the view controller needs displayed on FLOPopover
 * @return FLOPopover instance
 */
- (id)initWithContentViewController:(NSViewController *)contentViewController;

@required

#pragma mark -
#pragma mark - Utilities
#pragma mark -
- (IBAction)closePopover:(NSResponder *)sender;
- (void)closePopover:(NSResponder *)sender completion:(void(^)(void))complete;

@end
