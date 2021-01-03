//
//  HomeViewProtocols.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractViewProtocols.h"
#import "AbstractPresenterProtocols.h"

static const CGFloat SECOND_BAR_DEFAULT_HEIGHT = 40.0;

typedef NS_ENUM(NSInteger, PopoverGeneralType)
{
    PopoverGeneralTypeComics = 1,
    PopoverGeneralTypeTechnologies,
    PopoverGeneralTypeAlert
};

typedef NS_ENUM(NSInteger, PopoverGeneralDisplayStyle)
{
    PopoverGeneralDisplayStyleStickyRect = 1,
    PopoverGeneralDisplayStyleGivenRect,
    PopoverGeneralDisplayStyleAlert
};

typedef NS_ENUM(NSInteger, WorkspaceViewType)
{
    WorkspaceViewTypeFilms = 1,
    WorkspaceViewTypeNews,
    WorkspaceViewTypeComics,
    WorkspaceViewTypeTechnologies
};

///
/// View
@protocol HomeViewProtocols <AbstractViewProtocols>

- (void)viewDidSelectWindowModeChanging;
- (void)viewOpensFinder;
- (void)viewOpensSafari;
- (void)viewOpensFilmsView;
- (void)viewOpensNewsView;
- (void)viewOpensGeneralView;
- (void)viewOpensGeneralMenuAtView:(NSView *)sender;
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
- (void)openGeneralView;
- (void)openGeneralMenuAtView:(NSView *)sender;
- (void)showSecondBar;
- (void)showTrashView;

@end
