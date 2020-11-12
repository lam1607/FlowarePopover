//
//  HomeViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomeViewController.h"

#import "FilmsViewController.h"
#import "NewsViewController.h"
#import "ComicsViewController.h"
#import "TechnologiesViewController.h"
#import "TrashViewController.h"

#import "DragDroppableView.h"
#import "DoubleClickButton.h"

#import "AppleScript.h"

#import "HomePresenter.h"

@interface HomeViewController () <FLOPopoverDelegate, DragDropTrackingDelegate>
{
    id<HomePresenterProtocols> _presenter;
    
    FLOPopover *_popoverFilms;
    FLOPopover *_popoverNews;
    FLOPopover *_popoverGeneral;
    
    PopoverGeneralType _generalType;
    PopoverGeneralDisplayStyle _generalDisplayStyle;
    
    FilmsViewController *_filmsViewController;
    NewsViewController *_newsViewController;
    TechnologiesViewController *_technologiesViewController;
    ComicsViewController *_comicsViewController;
    TrashViewController *_trashViewController;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *menuView;

@property (weak) IBOutlet NSView *viewContainerMode;
@property (weak) IBOutlet DoubleClickButton *btnChangeMode;
@property (weak) IBOutlet NSView *viewContainerFinder;
@property (weak) IBOutlet DoubleClickButton *btnOpenFinder;
@property (weak) IBOutlet NSView *viewContainerSafari;
@property (weak) IBOutlet DoubleClickButton *btnOpenSafari;

@property (weak) IBOutlet NSView *viewContainerFilms;
@property (weak) IBOutlet DoubleClickButton *btnOpenFilms;
@property (weak) IBOutlet NSView *viewContainerNews;
@property (weak) IBOutlet DoubleClickButton *btnOpenNews;
@property (weak) IBOutlet NSView *viewContainerSecondBar;
@property (weak) IBOutlet DoubleClickButton *btnShowSecondBar;
@property (weak) IBOutlet NSView *viewContainerGeneral;
@property (weak) IBOutlet DoubleClickButton *btnGeneral;

@property (weak) IBOutlet NSView *viewSecondBar;
@property (weak) IBOutlet NSLayoutConstraint *constraintHeightSecondBar;

@property (weak) IBOutlet DragDroppableView *viewContainerTrashIcon;
@property (weak) IBOutlet NSImageView *imgTrashIcon;
@property (weak) IBOutlet NSButton *btnTrashIcon;

@property (weak) IBOutlet NSView *viewContainerTrash;

/// @property
///

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self objectsInitialize];
    [self setupUI];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _presenter = [[HomePresenter alloc] init];
    [_presenter attachView:self];
    
    _generalType = PopoverGeneralTypeComics;
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.constraintHeightSecondBar.constant = 0.0;
    
    [self.btnChangeMode setFocusRingType:NSFocusRingTypeNone];
    [self.btnOpenFinder setFocusRingType:NSFocusRingTypeNone];
    [self.btnOpenSafari setFocusRingType:NSFocusRingTypeNone];
    [self.btnOpenFilms setFocusRingType:NSFocusRingTypeNone];
    [self.btnOpenNews setFocusRingType:NSFocusRingTypeNone];
    [self.btnShowSecondBar setFocusRingType:NSFocusRingTypeNone];
    [self.btnGeneral setFocusRingType:NSFocusRingTypeNone];
    [self.btnGeneral setRightClickAction:@selector(btnGeneralRightClicked:)];
    
    [self setupTrashView];
    [self setTrashViewHidden:YES];
}

- (void)setupTrashView
{
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.viewContainerTrash];
    
    if (_trashViewController == nil)
    {
        _trashViewController = [[TrashViewController alloc] initWithNibName:NSStringFromClass([TrashViewController class]) bundle:nil];
    }
    
    if (![_trashViewController.view isDescendantOf:self.viewContainerTrash])
    {
        [self addView:_trashViewController.view toParent:self.viewContainerTrash];
    }
}

#pragma mark - Local methods

- (void)changeWindowMode
{
    [[SettingsManager sharedInstance] changeApplicationMode];
}

- (void)openEntitlementApplicationWithIdentifier:(NSString *)appIdentifier
{
    NSURL *appUrl = [NSURL fileURLWithPath:[EntitlementsManager getAppPathWithIdentifier:appIdentifier]];
    
    if (![[NSWorkspace sharedWorkspace] launchApplicationAtURL:appUrl options:NSWorkspaceLaunchDefault configuration:[NSDictionary dictionary] error:NULL])
    {
        // If the application cannot be launched, then re-launch it by script
        NSString *appName = [EntitlementsManager getAppNameWithIdentifier:appIdentifier];
        script_openApp(appName, YES);
        
        [[EntitlementsManager sharedInstance] activateWithBundleIdentifier:appIdentifier];
    }
    else
    {
        [[EntitlementsManager sharedInstance] activateWithBundleIdentifier:appIdentifier];
    }
}

- (void)handleShowSecondBar
{
    CGFloat secondBarHeight = self.constraintHeightSecondBar.constant;
    secondBarHeight = (secondBarHeight < SECOND_BAR_DEFAULT_HEIGHT) ? SECOND_BAR_DEFAULT_HEIGHT : 0.0;
    
    self.constraintHeightSecondBar.constant = secondBarHeight;
    [self.viewSecondBar layoutSubtreeIfNeeded];
    
    if ([_popoverGeneral isShown] && (_generalDisplayStyle == PopoverGeneralDisplayStyleGivenRect))
    {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = NSHeight([self.menuView frame]);
        CGFloat verticalMargin = 10.0;
        CGFloat availableHeight = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentViewWidth = COMICS_VIEW_DETAIL_WIDTH;
        CGFloat contentViewHeight = COMICS_VIEW_DEFAULT_HEIGHT;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
        
        if (_comicsViewController != nil)
        {
            CGFloat contentHeight = [_comicsViewController getContentSizeHeight];
            contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
            contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
        }
        else if (_technologiesViewController != nil)
        {
            contentViewHeight = NSHeight([_technologiesViewController.view frame]);
            contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
        }
        
        CGFloat positioningRectX = NSWidth(visibleRect) - NSWidth(contentViewRect) - verticalMargin / 2;
        CGFloat positioningRectY = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin / 2;
        NSRect positioningRect = [[self.view window] convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
        
        [_popoverGeneral setPopoverContentViewSize:contentViewRect.size positioningRect:positioningRect];
    }
}

- (void)showRelativeToRectOfViewWithPopover:(FLOPopover *)popover edgeType:(FLOPopoverEdgeType)edgeType atView:(NSView *)sender
{
    NSView *view = (sender.superview != nil) ? sender.superview : sender;
    NSRect rect = [view convertRect:[view visibleRect] toView:sender];
    
    if (popover == _popoverGeneral)
    {
        _generalDisplayStyle = PopoverGeneralDisplayStyleStickyRect;
    }
    
    popover.delegate = self;
    [popover setPopoverLevel:[WindowManager levelForTag:popover.tag]];
    [popover showRelativeToRect:rect ofView:sender edgeType:edgeType];
}

- (void)showRelativeToViewWithRect:(NSRect)rect byPopover:(FLOPopover *)popover sender:(NSView *)sender
{
    if (popover == _popoverGeneral)
    {
        _generalDisplayStyle = PopoverGeneralDisplayStyleGivenRect;
    }
    
    popover.delegate = self;
    [popover setPopoverLevel:[WindowManager levelForTag:popover.tag]];
    [popover showRelativeToView:sender withRect:rect];
}

- (void)showFilmsPopupAtView:(NSView *)sender
{
    if ([_popoverFilms isShown])
    {
        [_popoverFilms close];
    }
    else
    {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = NSHeight([self.menuView frame]);
        CGFloat verticalMargin = 10.0;
        CGFloat width = 0.5 * NSWidth(visibleRect);
        CGFloat height = NSHeight(visibleRect) - menuHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (_popoverFilms == nil)
        {
            _filmsViewController = [[FilmsViewController alloc] initWithNibName:NSStringFromClass([FilmsViewController class]) bundle:nil];
            [_filmsViewController.view setFrame:contentViewRect];
            
            _popoverFilms = [[FLOPopover alloc] initWithContentViewController:_filmsViewController type:FLOViewPopover];
        }
        
        _popoverFilms.animated = YES;
        _popoverFilms.closesWhenPopoverResignsKey = YES;
        // _popoverFilms.closesWhenApplicationBecomesInactive = YES;
        _popoverFilms.becomesKeyOnMouseOver = YES;
        _popoverFilms.isMovable = YES;
        _popoverFilms.isDetachable = YES;
        _popoverFilms.tag = WindowLevelGroupTagFloat;
        
        // [_popoverFilms setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
        [_popoverFilms setAnimationBehaviour:FLOPopoverAnimationBehaviorTransform type:FLOPopoverAnimationScale];
        
        [self showRelativeToRectOfViewWithPopover:_popoverFilms edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
    }
}

- (void)showNewsPopupAtView:(NSView *)sender
{
    if ([_popoverNews isShown])
    {
        [_popoverNews close];
    }
    else
    {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = NSHeight([self.menuView frame]);
        CGFloat verticalMargin = 10.0;
        CGFloat width = 0.5 * NSWidth(visibleRect);
        CGFloat height = NSHeight(visibleRect) - menuHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (_popoverNews == nil)
        {
            _newsViewController = [[NewsViewController alloc] initWithNibName:NSStringFromClass([NewsViewController class]) bundle:nil];
            [_newsViewController.view setFrame:contentViewRect];
            
            _popoverNews = [[FLOPopover alloc] initWithContentViewController:_newsViewController];
        }
        
        _popoverNews.animated = YES;
        // _popoverNews.closesWhenPopoverResignsKey = YES;
        // _popoverNews.closesWhenApplicationBecomesInactive = YES;
        // _popoverNews.closesAfterTimeInterval = 3.0;
        // _popoverNews.disableTimeIntervalOnMoving = YES;
        _popoverNews.becomesKeyOnMouseOver = YES;
        _popoverNews.isMovable = YES;
        _popoverNews.isDetachable = YES;
        _popoverNews.tag = WindowLevelGroupTagFloat;
        
        [_popoverNews setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
        
        [self showRelativeToRectOfViewWithPopover:_popoverNews edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
    }
}

- (void)showGeneralPopupAtView:(NSView *)sender option:(PopoverGeneralType)option
{
    if ([_popoverGeneral isShown])
    {
        [_popoverGeneral close];
    }
    else
    {
        _generalType = option;
        
        if (option == PopoverGeneralTypeComics)
        {
            NSRect visibleRect = [self.view visibleRect];
            CGFloat menuHeight = NSHeight([self.menuView frame]);
            CGFloat secondBarHeight = self.constraintHeightSecondBar.constant;
            CGFloat verticalMargin = 10.0;
            CGFloat contentViewWidth = COMICS_VIEW_DETAIL_WIDTH;
            CGFloat minHeight = COMICS_VIEW_DEFAULT_HEIGHT;
            CGFloat availableHeight = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin;
            CGFloat contentHeight = [_comicsViewController getContentSizeHeight];
            CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : ((contentHeight >= minHeight) ? contentHeight : minHeight);
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
            CGFloat positioningRectX = NSWidth(visibleRect) - NSWidth(contentViewRect) - verticalMargin / 2;
            CGFloat positioningRectY = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin / 2;
            NSRect positioningRect = [[sender window] convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
            
            if (_popoverGeneral == nil)
            {
                _comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
                [_comicsViewController.view setFrame:contentViewRect];
                
                // _popoverGeneral = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController];
                // _popoverGeneral = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController type:FLOViewPopover];
                _popoverGeneral = [[FLOPopover alloc] initWithContentView:_comicsViewController.view];
                // _popoverGeneral = [[FLOPopover alloc] initWithContentView:self.comicsViewController.view type:FLOViewPopover];
            }
            
            _popoverGeneral.animated = YES;
            // _popoverGeneral.animatedForwarding = YES;
            // _popoverGeneral.shouldChangeSizeWhenApplicationResizes = YES;
            // _popoverGeneral.closesWhenPopoverResignsKey = YES;
            // _popoverGeneral.closesWhenApplicationBecomesInactive = YES;
            _popoverGeneral.isMovable = YES;
            _popoverGeneral.isDetachable = YES;
            _popoverGeneral.tag = WindowLevelGroupTagSetting;
            
            [_popoverGeneral setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft animatedInAppFrame:YES];
            
            [self showRelativeToViewWithRect:positioningRect byPopover:_popoverGeneral sender:sender];
        }
        else if (option == PopoverGeneralTypeTechnologies)
        {
            NSRect visibleRect = [self.view visibleRect];
            CGFloat menuHeight = NSHeight([self.menuView frame]);
            CGFloat secondBarHeight = self.constraintHeightSecondBar.constant;
            CGFloat verticalMargin = 10.0;
            CGFloat width = COMICS_VIEW_DETAIL_WIDTH;
            CGFloat height = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin;
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
            
            if (_popoverGeneral == nil)
            {
                _technologiesViewController = [[TechnologiesViewController alloc] initWithNibName:NSStringFromClass([TechnologiesViewController class]) bundle:nil];
                [_technologiesViewController.view setFrame:contentViewRect];
                
                _popoverGeneral = [[FLOPopover alloc] initWithContentViewController:_technologiesViewController];
            }
            
            _popoverGeneral.shouldShowArrow = YES;
            _popoverGeneral.animated = YES;
            // _popoverGeneral.shouldChangeSizeWhenApplicationResizes = NO;
            // _popoverGeneral.closesWhenPopoverResignsKey = YES;
            // _popoverGeneral.closesWhenApplicationBecomesInactive = YES;
            _popoverGeneral.isMovable = YES;
            _popoverGeneral.isDetachable = YES;
            _popoverGeneral.staysInContainer = YES;
            _popoverGeneral.tag = WindowLevelGroupTagSetting;
            
            [_popoverGeneral setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
            
            [self showRelativeToRectOfViewWithPopover:_popoverGeneral edgeType:FLOPopoverEdgeTypeBelowRightEdge atView:sender];
        }
        else
        {
            NSRect visibleRect = [self.view visibleRect];
            CGFloat menuHeight = NSHeight([self.menuView frame]);
            CGFloat secondBarHeight = self.constraintHeightSecondBar.constant;
            CGFloat verticalMargin = 10.0;
            CGFloat contentViewWidth = COMICS_VIEW_DETAIL_WIDTH;
            CGFloat minHeight = COMICS_VIEW_DEFAULT_HEIGHT;
            CGFloat availableHeight = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin;
            CGFloat contentHeight = [_comicsViewController getContentSizeHeight];
            CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : ((contentHeight >= minHeight) ? contentHeight : minHeight);
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
            
            if (_popoverGeneral == nil)
            {
                _comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
                [_comicsViewController.view setFrame:contentViewRect];
                
                // _popoverGeneral = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController];
                _popoverGeneral = [[FLOPopover alloc] initWithContentView:_comicsViewController.view];
                _popoverGeneral.delegate = self;
            }
            
            _popoverGeneral.closesWhenApplicationBecomesInactive = YES;
            _popoverGeneral.maxHeight = NSHeight([[[self.view window] screen] visibleFrame]);
            _popoverGeneral.tag = WindowLevelGroupTagSetting;
            
            _generalDisplayStyle = PopoverGeneralDisplayStyleGivenRect;
            
            [_popoverGeneral showWithAlertStyleForWindow:[self.view window]];
        }
    }
}

- (void)generalMenuDidSelectForItem:(NSMenuItem *)item
{
    if (![_popoverGeneral isShown]) return;
    
    if (item.tag == 10001)
    {
        /// Change positioning view
        BOOL shouldChange = (_generalDisplayStyle == PopoverGeneralDisplayStyleStickyRect) || (_generalDisplayStyle == PopoverGeneralDisplayStyleGivenRect);
        
        if (shouldChange)
        {
            NSView *sender = self.btnShowSecondBar;
            NSView *view = (sender.superview != nil) ? sender.superview : sender;
            
            if (_generalDisplayStyle == PopoverGeneralDisplayStyleStickyRect)
            {
                [_popoverGeneral setPopoverPositioningView:view edgeType:FLOPopoverEdgeTypeBelowRightEdge];
            }
            else
            {
                NSRect visibleRect = [self.view visibleRect];
                CGFloat menuHeight = NSHeight([self.menuView frame]);
                CGFloat secondBarHeight = self.constraintHeightSecondBar.constant;
                CGFloat verticalMargin = 10.0;
                CGFloat positioningRectX = NSMaxX([view convertRect:[view visibleRect] toView:self.view]) - NSWidth([_popoverGeneral frame]);
                CGFloat positioningRectY = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin / 2;
                NSRect positioningRect = [[sender window] convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
                
                [_popoverGeneral setPopoverPositioningView:view positioningRect:positioningRect];
            }
        }
    }
    else if (item.tag == 10002)
    {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = NSHeight([self.menuView frame]);
        CGFloat secondBarHeight = self.constraintHeightSecondBar.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat availableHeight = NSHeight(visibleRect) - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentViewWidth = COMICS_VIEW_DETAIL_WIDTH;
        NSViewController *contentViewController = nil;
        
        /// Change popover content view to other
        if ((_generalType == PopoverGeneralTypeComics) && (_comicsViewController != nil))
        {
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, availableHeight);
            
            _generalType = PopoverGeneralTypeTechnologies;
            _comicsViewController = nil;
            _technologiesViewController = [[TechnologiesViewController alloc] initWithNibName:NSStringFromClass([TechnologiesViewController class]) bundle:nil];
            [_technologiesViewController.view setFrame:contentViewRect];
            
            contentViewController = _technologiesViewController;
        }
        else if ((_generalType == PopoverGeneralTypeTechnologies) && (_technologiesViewController != nil))
        {
            CGFloat contentHeight = [_comicsViewController getContentSizeHeight];
            CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
            
            _generalType = PopoverGeneralTypeComics;
            _technologiesViewController = nil;
            _comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
            [_comicsViewController.view setFrame:contentViewRect];
            
            contentViewController = _comicsViewController;
        }
        
        [_popoverGeneral setPopoverContentViewController:contentViewController];
    }
}

- (void)setTrashViewHidden:(BOOL)isHidden
{
    [self.viewContainerTrash setHidden:isHidden];
}

#pragma mark - Actions

- (IBAction)btnChangeModeClicked:(NSButton *)sender
{
    [_presenter changeWindowMode];
}

- (IBAction)btnOpenFinderClicked:(NSButton *)sender
{
    [_presenter openFinder];
}

- (IBAction)btnOpenSafariClicked:(NSButton *)sender
{
    [_presenter openSafari];
}

- (IBAction)btnOpenFilmsClicked:(NSButton *)sender
{
    [_presenter openFilmsView];
}

- (IBAction)btnOpenNewsClicked:(NSButton *)sender
{
    [_presenter openNewsView];
}

- (IBAction)btnShowSecondBarClicked:(NSButton *)sender
{
    [_presenter showSecondBar];
}

- (IBAction)btnGeneralClicked:(NSButton *)sender
{
    [_presenter openGeneralView];
}

- (IBAction)btnGeneralRightClicked:(NSButton *)sender
{
    [_presenter openGeneralMenuAtView:sender];
}

- (IBAction)btnTrashIconClicked:(NSButton *)sender
{
    [_presenter showTrashView];
}


#pragma mark - HomeViewProtocols implementation

- (void)refreshUIAppearance
{
    [super refreshUIAppearance];
    
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.menuView];
    
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerMode];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerFinder];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerSafari];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerFilms];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerNews];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerSecondBar];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerGeneral];
    
    [Utils setTitle:@"Films popup" color:[NSColor textWhiteColor] forControl:self.btnOpenFilms];
    [Utils setTitle:@"News popup" color:[NSColor textWhiteColor] forControl:self.btnOpenNews];
    [Utils setTitle:@"Show second bar" color:[NSColor textWhiteColor] forControl:self.btnShowSecondBar];
    [Utils setTitle:@"General popup" color:[NSColor textWhiteColor] forControl:self.btnGeneral];
    
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.viewSecondBar];
}

- (void)viewDidSelectWindowModeChanging
{
    [self changeWindowMode];
}

- (void)viewOpensFinder
{
    [self openEntitlementApplicationWithIdentifier:kFlowarePopover_BundleIdentifier_Finder];
}

- (void)viewOpensSafari
{
    [self openEntitlementApplicationWithIdentifier:kFlowarePopover_BundleIdentifier_Safari];
}

- (void)viewOpensFilmsView
{
    [self showFilmsPopupAtView:self.btnOpenFilms];
}

- (void)viewOpensNewsView
{
    [self showNewsPopupAtView:self.btnOpenNews];
}

- (void)viewOpensGeneralView
{
    [self showGeneralPopupAtView:self.btnGeneral option:PopoverGeneralTypeTechnologies];
}

- (void)viewOpensGeneralMenuAtView:(NSView *)sender
{
    NSString *secondBarTitle = [NSString stringWithFormat:@"Change positioning view to \'%@\'", [self.btnShowSecondBar title]];
    NSArray *items = @[@{@"title": secondBarTitle, @"tag": @(10001)}, @{@"title": @"Change popover content view to other", @"tag": @(10002)}];
    SEL selector = @selector(generalMenuDidSelectForItem:);
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"General Menu"];
    [menu setAutoenablesItems:NO];
    
    for (NSDictionary *itemInfo in items)
    {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTitle:[itemInfo objectForKey:@"title"]];
        [item setTarget:self];
        [item setAction:selector];
        [item setTag:[[itemInfo objectForKey:@"tag"] integerValue]];
        
        [menu addItem:item];
    }
    
    [NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:sender];
}

- (void)viewShowsSecondBar
{
    [self handleShowSecondBar];
}

- (void)viewShowsTrashView
{
    [self setTrashViewHidden:!self.viewContainerTrash.isHidden];
}

#pragma mark - FLOPopoverDelegate

- (void)floPopoverWillShow:(FLOPopover *)popover
{
}

- (void)floPopoverDidShow:(FLOPopover *)popover
{
}

- (void)floPopoverWillClose:(FLOPopover *)popover
{
}

- (void)floPopoverDidClose:(FLOPopover *)popover
{
    // @warning: MUST set the popover to nil for completely deallocating
    // the content view or content view controller, when popover closed.
    if (popover == _popoverFilms)
    {
        _popoverFilms = nil;
    }
    else if (popover == _popoverNews)
    {
        _popoverNews = nil;
    }
    else if (popover == _popoverGeneral)
    {
        _popoverGeneral = nil;
    }
}

@end
