//
//  AbstractWindowProtocols.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/2/21.
//  Copyright © 2021 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef AbstractWindowProtocols_h
#define AbstractWindowProtocols_h

@protocol AbstractWindowProtocols <NSObject>

@optional
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize;

@end

#endif /* AbstractWindowProtocols_h */
