//
//  ComicsViewController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractViewController.h"

#import "ComicsViewProtocols.h"

@interface ComicsViewController : AbstractViewController <ComicsViewProtocols>

@property (nonatomic, copy) void (^didContentSizeChange)(NSSize newSize);

- (CGFloat)getContentSizeHeight;

@end
