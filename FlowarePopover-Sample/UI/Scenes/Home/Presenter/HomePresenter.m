//
//  HomePresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomePresenter.h"

@implementation HomePresenter

#pragma mark - HomePresenterProtocols implementation

- (void)changeWindowMode
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewDidSelectWindowModeChanging];
    }
}

- (void)openFinder
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewOpensFinder];
    }
}

- (void)openSafari
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewOpensSafari];
    }
}

- (void)openFilmsView
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewOpensFilmsView];
    }
}

- (void)openNewsView
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewOpensNewsView];
    }
}

- (void)openGeneralView
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewOpensGeneralView];
    }
}

- (void)openGeneralMenuAtView:(NSView *)sender
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewOpensGeneralMenuAtView:sender];
    }
}

- (void)showSecondBar
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewShowsSecondBar];
    }
}

- (void)showTrashView
{
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)])
    {
        [(id<HomeViewProtocols>)self.view viewShowsTrashView];
    }
}

@end
