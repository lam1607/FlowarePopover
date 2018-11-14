//
//  BaseViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
}

- (void)viewWillLayout {
    [super viewWillLayout];
    
    [self refreshUIColors];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
}

- (void)refreshUIColors {
#ifdef SHOULD_USE_ASSET_COLORS
    [Utils setBackgroundColor:[NSColor _backgroundColor] forView:self.view];
#else
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.view];
#endif
}

@end
