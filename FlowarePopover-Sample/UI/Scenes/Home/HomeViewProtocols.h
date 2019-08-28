//
//  HomeViewProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractViewProtocols.h"
#import "AbstractPresenterProtocols.h"

///
/// View
@protocol HomeViewProtocols <AbstractViewProtocols>

- (void)viewDidSelectWindowModeChanging;
- (void)viewOpensFinder;
- (void)viewOpensSafari;
- (void)viewOpensFilmsView;
- (void)viewOpensNewsView;
- (void)viewOpensComicsView;
- (void)viewShowsSecondBar;
- (void)viewShowsTrashView;

@end

///
/// Presenter
@protocol HomePresenterProtocols <AbstractPresenterProtocols>

- (void)changeWindowMode;
- (void)openFinder;
- (void)openSafari;
- (void)openFilmsView;
- (void)openNewsView;
- (void)openComicsView;
- (void)showSecondBar;
- (void)showTrashView;

@end
