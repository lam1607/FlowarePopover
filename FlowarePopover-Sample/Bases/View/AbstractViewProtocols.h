//
//  AbstractViewProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef AbstractViewProtocols_h
#define AbstractViewProtocols_h

#import <Foundation/Foundation.h>

@protocol AbstractViewProtocols <NSObject>

@optional
- (void)reloadViewData;
- (void)updateViewImage;

@end

#endif /* AbstractViewProtocols_h */
