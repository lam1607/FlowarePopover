//
//  AsynchronousOperation.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/28/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsynchronousOperation : NSOperation

@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSObject *object;

+ (instancetype)asynchronousOperationWithBlock:(void(^)(AsynchronousOperation *operation))block;

/**
 * Finishes the execution of the operation.
 *
 *@note - This shouldn’t be called externally as this is used internally by subclasses. To cancel an operation use cancel instead.
 */
- (void)finish;

- (void)completeWithDelay:(NSInteger)interval;
- (void)completeWithError:(NSError *)error delay:(NSInteger)interval;

@end


@interface NSOperationQueue (AsynchronousOperation)

- (AsynchronousOperation *)addAsynchronousOperationWithBlock:(void(^)(AsynchronousOperation *operation))block;

@end
