//
//  HomePresenterProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractPresenterProtocols.h"

@protocol HomePresenterProtocols <AbstractPresenterProtocols>

- (void)changeWindowMode;
- (void)openFinder;
- (void)openSafari;
- (void)openFilmsView;
- (void)openNewsView;
- (void)openComicsView;
- (void)showSecondBar;

@end
