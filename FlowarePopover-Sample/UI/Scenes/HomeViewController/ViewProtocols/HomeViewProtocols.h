//
//  HomeViewProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractViewProtocols.h"

@protocol HomeViewProtocols <AbstractViewProtocols>

- (void)viewDidSelectWindowModeChanging;
- (void)viewShouldOpenFinder;
- (void)viewShouldOpenSafari;
- (void)viewShouldOpenFilmsView;
- (void)viewShouldOpenNewsView;
- (void)viewShouldOpenComicsView;
- (void)viewShouldShowSecondBar;

@end
