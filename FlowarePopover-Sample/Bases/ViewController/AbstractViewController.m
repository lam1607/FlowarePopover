//
//  AbstractViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractViewController.h"

@interface AbstractViewController ()

@end

@implementation AbstractViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    [self setupUI];
    [self refreshUIAppearance];
}

#pragma mark - Setup UI

- (void)setupUI
{
}

#pragma mark - AbstractViewProtocols

- (void)refreshUIAppearance
{
    [self.view setWantsLayer:YES];
    [[self.view layer] setCornerRadius:[CORNER_RADIUSES[0] doubleValue]];
    
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.view];
}

@end
