//
//  AsynchronousOperation.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/28/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import "AsynchronousOperation.h"

@interface AsynchronousOperation ()

@property (nonatomic, copy) void (^executingBlock)(AsynchronousOperation *operation);

@end

@implementation AsynchronousOperation

/*
 * We need to do old school synthesizing as the compiler has trouble creating the internal ivars.
 */
@synthesize ready = _ready;
@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark - Init

- (instancetype)init
{
    if (self = [super init])
    {
        self.ready = YES;
    }
    
    return self;
}

+ (instancetype)asynchronousOperationWithBlock:(void(^)(AsynchronousOperation *operation))block
{
    AsynchronousOperation *operation = [[AsynchronousOperation alloc] init];
    operation.executingBlock = block;
    
    return operation;
}

- (void)dealloc
{
    _object = nil;
}

#pragma mark - Getter/Setter

- (void)setReady:(BOOL)ready
{
    if (_ready != ready)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isReady))];
        _ready = ready;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isReady))];
    }
}

- (BOOL)isReady
{
    return _ready;
}

- (void)setExecuting:(BOOL)executing
{
    if (_executing != executing)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = executing;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
}

- (BOOL)isExecuting
{
    return _executing;
}

- (void)setFinished:(BOOL)finished
{
    if (_finished != finished)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
        _finished = finished;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    }
}

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isAsynchronous
{
    return YES;
}

#pragma mark - Control

- (void)start
{
    if (self.isCancelled)
    {
        self.executing = YES;
        self.finished = YES;
    }
    else
    {
        if (!self.isExecuting)
        {
            self.ready = NO;
            self.executing = YES;
            self.finished = NO;
        }
        
        if (self.executingBlock != nil)
        {
            self.executingBlock(self);
        }
    }
}

- (void)finish
{
    if (self.executing)
    {
        self.executing = NO;
        self.finished = YES;
    }
}

- (void)completeWithDelay:(NSInteger)interval
{
    [self completeWithError:nil delay:interval];
}

- (void)completeWithError:(NSError *)error delay:(NSInteger)interval
{
    self.error = error;
    
    if (interval <= 0)
    {
        [self finish];
    }
    else
    {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_after(time, queue, ^{
            [self finish];
        });
    }
}

@end

@implementation NSOperationQueue (AsynchronousOperation)

- (AsynchronousOperation *)addAsynchronousOperationWithBlock:(void(^)(AsynchronousOperation *operation))block
{
    AsynchronousOperation *operation = [AsynchronousOperation asynchronousOperationWithBlock:block];
    
    [self addOperation:operation];
    
    return operation;
}

@end

