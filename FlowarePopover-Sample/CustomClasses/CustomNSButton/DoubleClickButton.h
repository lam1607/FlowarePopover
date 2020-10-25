//
//  DoubleClickButton.h
//  FLOPopupPrototypes
//
//  Created by lamnguyen on 7/13/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DoubleClickButton : NSButton

@property (nonatomic, assign) NSPoint clickedPoint;

@property (nonatomic, assign) SEL doubleAction;
@property (nonatomic, assign) SEL rightClickAction;

@end
