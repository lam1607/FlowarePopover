//
//  NSAppearance+Extensions.h
//  SharedSources
//
//  Created by Lam Nguyen on 12/11/19.
//  Copyright © 2019 Floware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NSAppearanceInterfaceThemeDidChangeNotification @"NSAppearanceInterfaceThemeDidChangeNotification"

@protocol NSAppearanceExtensionsProtocols <NSObject>

@optional
- (BOOL)shouldUseSystemAppearance;
- (BOOL)isDarkAppearance;

@end

@interface NSAppearance (Extensions)

@property (class, nonatomic, weak) id<NSAppearanceExtensionsProtocols> protocolOwner;

+ (BOOL)isDarkAppearance;

@end
