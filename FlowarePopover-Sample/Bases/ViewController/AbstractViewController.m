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
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    
    [self refreshUIColors];
}

#pragma mark - Setup UI

- (void)setupUI
{
}

- (void)refreshUIColors
{
    if ([self.view.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name])
    {
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _backgroundColor] forView:self.view];
#else
        [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.view];
#endif
    }
}

- (void)addView:(NSView *)child toParent:(NSView *)parent
{
    [self addView:child toParent:parent needConstraints:YES];
}

- (void)addView:(NSView *)child toParent:(NSView *)parent needConstraints:(BOOL)needConstraints
{
    [parent addSubview:child];
    
    if (needConstraints)
    {
        child.translatesAutoresizingMaskIntoConstraints = NO;
        
        [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[child]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(child)]];
        [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[child]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(child)]];
    }
}


@end
