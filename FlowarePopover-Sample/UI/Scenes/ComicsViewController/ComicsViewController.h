//
//  ComicsViewController.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "BaseViewController.h"

#import "ComicsViewProtocols.h"
#import "ComicRepository.h"
#import "ComicsPresenter.h"

@interface ComicsViewController : BaseViewController <ComicsViewProtocols>

@property (nonatomic, copy) void (^didContentSizeChange)(void);

- (CGFloat)getContentSizeHeight;

@end
