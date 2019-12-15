//
//  NSView+Extensions.m
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "NSView+Extensions.h"

#import "AbstractViewProtocols.h"

@implementation NSView (Extensions)

#ifdef __MAC_10_14
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_14
+ (void)load
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewDidChangeEffectiveAppearance);
        SEL swizzledSelector = @selector(_viewDidChangeEffectiveAppearance);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL isMethodAdded = class_addMethod(class,
                                             originalSelector,
                                             method_getImplementation(swizzledMethod),
                                             method_getTypeEncoding(swizzledMethod));
        
        if (isMethodAdded)
        {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)_viewDidChangeEffectiveAppearance
{
    [self _viewDidChangeEffectiveAppearance];
    
    if ([(id<AbstractViewProtocols>)self respondsToSelector:@selector(refreshUIAppearance)])
    {
        [(id<AbstractViewProtocols>)self refreshUIAppearance];
    }
    else
    {
        NSResponder *responder = [self nextResponder];
        
        if ([(id<AbstractViewProtocols>)responder respondsToSelector:@selector(refreshUIAppearance)])
        {
            [(id<AbstractViewProtocols>)responder refreshUIAppearance];
        }
    }
}
#endif
#endif

@end
