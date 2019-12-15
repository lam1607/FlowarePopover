//
//  NSAppearance+Extensions.h
//  SharedSources
//
//  Created by Lam Nguyen on 12/11/19.
//  Copyright © 2019 Floware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NSAppearanceInterfaceThemeDidChangeNotification @"AppleInterfaceThemeChangedNotification"

@interface NSAppearance (Extensions)

+ (BOOL)isDarkAppearance;

@end
