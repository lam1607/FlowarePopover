//
//  HomePresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomePresenter.h"

#import "HomeViewProtocols.h"

@implementation HomePresenter

#pragma mark - HomePresenterProtocols implementation

- (void)changeWindowMode {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewDidSelectWindowModeChanging];
    }
}

- (void)openFinder {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewShouldOpenFinder];
    }
}

- (void)openSafari {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewShouldOpenSafari];
    }
}

- (void)openFilmsView {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewShouldOpenFilmsView];
    }
}

- (void)openNewsView {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewShouldOpenNewsView];
    }
}

- (void)openComicsView {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewShouldOpenComicsView];
    }
}

- (void)showSecondBar {
    if ([self.view conformsToProtocol:@protocol(HomeViewProtocols)]) {
        [(id<HomeViewProtocols>)self.view viewShouldShowSecondBar];
    }
}

@end
