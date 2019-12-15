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

#import "AppleScript.h"

#import "HomePresenter.h"

@interface HomeViewController () <FLOPopoverDelegate, DragDropTrackingDelegate>
{
    id<HomePresenterProtocols> _presenter;
    
    FLOPopover *_popoverFilms;
    FLOPopover *_popoverNews;
    FLOPopover *_popoverComics;
    
    NSArray<NSString *> *_entitlementAppBundles;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *viewMenu;

@property (weak) IBOutlet NSView *viewContainerMode;
@property (weak) IBOutlet NSButton *btnChangeMode;
@property (weak) IBOutlet NSView *viewContainerFinder;
@property (weak) IBOutlet NSButton *btnOpenFinder;
@property (weak) IBOutlet NSView *viewContainerSafari;
@property (weak) IBOutlet NSButton *btnOpenSafari;

@property (weak) IBOutlet NSView *viewContainerFilms;
@property (weak) IBOutlet NSButton *btnOpenFilms;
@property (weak) IBOutlet NSView *viewContainerNews;
@property (weak) IBOutlet NSButton *btnOpenNews;
@property (weak) IBOutlet NSView *viewContainerSecondBar;
@property (weak) IBOutlet NSButton *btnShowSecondBar;
@property (weak) IBOutlet NSView *viewContainerComics;
@property (weak) IBOutlet NSButton *btnOpenComics;

@property (weak) IBOutlet NSView *viewSecondBar;
@property (weak) IBOutlet NSLayoutConstraint *constraintVSecondBarHeight;

@property (weak) IBOutlet DragDroppableView *viewContainerTrashIcon;
@property (weak) IBOutlet NSImageView *imgTrashIcon;
@property (weak) IBOutlet NSButton *btnTrashIcon;


@property (weak) IBOutlet NSView *viewContainerTrash;

/// @property
///
@property (nonatomic, strong) FilmsViewController *filmsViewController;
@property (nonatomic, strong) NewsViewController *newsViewController;
@property (nonatomic, strong) TechnologiesViewController *technologiesViewController;
@property (nonatomic, strong) ComicsViewController *comicsViewController;
@property (nonatomic, strong) TrashViewController *trashViewController;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self objectsInitialize];
    [self setupEntitlementAppBundles];
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
    
    _entitlementAppBundles = [[NSArray alloc] initWithObjects:kFlowarePopover_BundleIdentifier_Finder, kFlowarePopover_BundleIdentifier_Safari, nil];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.constraintVSecondBarHeight.constant = 0.0;
    
    [self setupTrashView];
    [self setTrashViewHidden:YES];
}

- (void)setupTrashView
{
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.viewContainerTrash];
    
    if (self.trashViewController == nil)
    {
        self.trashViewController = [[TrashViewController alloc] initWithNibName:NSStringFromClass([TrashViewController class]) bundle:nil];
    }
    
    if (![self.trashViewController.view isDescendantOf:self.viewContainerTrash])
    {
        [self addView:self.trashViewController.view toParent:self.viewContainerTrash];
    }
}

#pragma mark - Local methods

- (void)setupEntitlementAppBundles
{
    for (NSString *bundle in _entitlementAppBundles)
    {
        [[EntitlementsManager sharedInstance] addWithBundleIdentifier:bundle];
    }
}

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

- (void)observeComicsViewContentSizeChange
{
    if (self.comicsViewController)
    {
        __weak typeof(self) wself = self;
        
        self.comicsViewController.didContentSizeChange = ^(NSSize newSize) {
            [wself handleComicsViewContentSizeChanging:newSize];
        };
    }
}

- (void)handleComicsViewContentSizeChanging:(NSSize)newSize
{
    if (self.comicsViewController)
    {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.viewMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentViewWidth = 350.0;
        CGFloat contentViewHeight = (newSize.height > availableHeight) ? availableHeight : newSize.height;
        NSRect contentViewRect = self.comicsViewController.view.frame;
        
        contentViewRect = NSMakeRect(contentViewRect.origin.x, contentViewRect.origin.y, contentViewWidth, contentViewHeight);
        
        [_popoverComics setPopoverContentViewSize:contentViewRect.size];
    }
}

- (void)handleShowSecondBar
{
    if (self.comicsViewController)
    {
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        
        if (secondBarHeight < 40.0)
        {
            secondBarHeight = 40.0;
        }
        else
        {
            secondBarHeight = 0.0;
        }
        
        self.constraintVSecondBarHeight.constant = secondBarHeight;
        
        [self.viewSecondBar setNeedsUpdateConstraints:YES];
        [self.viewSecondBar updateConstraints];
        [self.viewSecondBar updateConstraintsForSubtreeIfNeeded];
        [self.viewSecondBar layoutSubtreeIfNeeded];
        
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.viewMenu.frame.size.height;
        CGFloat verticalMargin = 10.0;
        CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
        CGFloat contentViewWidth = 350.0;
        CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
        
        CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
        CGFloat positioningRectY = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin / 2;
        NSRect positioningRect = [self.view.window convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
        
        [_popoverComics setPopoverContentViewSize:contentViewRect.size positioningRect:positioningRect];
    }
}

- (void)showRelativeToRectOfViewWithPopover:(FLOPopover *)popover edgeType:(FLOPopoverEdgeType)edgeType atView:(NSView *)sender
{
    NSRect rect = (sender.superview != nil) ? sender.superview.bounds : sender.bounds;
    
    popover.delegate = self;
    
    [popover setPopoverLevel:[WindowManager levelForTag:popover.tag]];
    
    [popover showRelativeToRect:rect ofView:sender edgeType:edgeType];
}

- (void)showRelativeToViewWithRect:(NSRect)rect byPopover:(FLOPopover *)popover sender:(NSView *)sender
{
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
        CGFloat menuHeight = self.viewMenu.frame.size.height;
        CGFloat verticalMargin = 10.0;
        CGFloat width = 0.5 * visibleRect.size.width;
        CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (_popoverFilms == nil)
        {
            self.filmsViewController = [[FilmsViewController alloc] initWithNibName:NSStringFromClass([FilmsViewController class]) bundle:nil];
            [self.filmsViewController.view setFrame:contentViewRect];
            
            _popoverFilms = [[FLOPopover alloc] initWithContentViewController:self.filmsViewController type:FLOViewPopover];
        }
        
        _popoverFilms.animated = YES;
        _popoverFilms.closesWhenPopoverResignsKey = YES;
        //    _popoverFilms.closesWhenApplicationBecomesInactive = YES;
        _popoverFilms.becomesKeyOnMouseOver = YES;
        _popoverFilms.isMovable = YES;
        _popoverFilms.isDetachable = YES;
        
        _popoverFilms.tag = WindowLevelGroupTagFloat;
        
        //    [_popoverFilms setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
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
        CGFloat menuHeight = self.viewMenu.frame.size.height;
        CGFloat verticalMargin = 10.0;
        CGFloat width = 0.5 * visibleRect.size.width;
        CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (_popoverNews == nil)
        {
            self.newsViewController = [[NewsViewController alloc] initWithNibName:NSStringFromClass([NewsViewController class]) bundle:nil];
            [self.newsViewController.view setFrame:contentViewRect];
            
            _popoverNews = [[FLOPopover alloc] initWithContentViewController:self.newsViewController];
        }
        
        _popoverNews.animated = YES;
        //    _popoverNews.closesWhenPopoverResignsKey = YES;
        //    _popoverNews.closesWhenApplicationBecomesInactive = YES;
        //    _popoverNews.closesAfterTimeInterval = 3.0;
        //    _popoverNews.disableTimeIntervalOnMoving = YES;
        _popoverNews.becomesKeyOnMouseOver = YES;
        _popoverNews.isMovable = YES;
        _popoverNews.isDetachable = YES;
        
        _popoverNews.tag = WindowLevelGroupTagFloat;
        
        [_popoverNews setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
        
        [self showRelativeToRectOfViewWithPopover:_popoverNews edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
    }
}

- (void)showComicsPopupAtView:(NSView *)sender option:(NSInteger)option
{
    if ([_popoverComics isShown])
    {
        [_popoverComics close];
    }
    else
    {
        if (option == 1)
        {
            NSRect visibleRect = [self.view visibleRect];
            CGFloat menuHeight = self.viewMenu.frame.size.height;
            CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
            CGFloat verticalMargin = 10.0;
            CGFloat contentViewWidth = 350.0;
            CGFloat minHeight = 429.0;
            CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
            CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
            CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : ((contentHeight >= minHeight) ? contentHeight : minHeight);
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
            
            if (_popoverComics == nil)
            {
                self.comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
                [self.comicsViewController.view setFrame:contentViewRect];
                
                //            _popoverComics = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController];
                //            _popoverComics = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController type:FLOViewPopover];
                _popoverComics = [[FLOPopover alloc] initWithContentView:self.comicsViewController.view];
                //            _popoverComics = [[FLOPopover alloc] initWithContentView:self.comicsViewController.view type:FLOViewPopover];
            }
            
            _popoverComics.animated = YES;
            //        _popoverComics.animatedForwarding = YES;
            //        _popoverComics.animatedByMovingFrame = YES;
            _popoverComics.shouldChangeSizeWhenApplicationResizes = YES;
            //        _popoverComics.closesWhenPopoverResignsKey = YES;
            //        _popoverComics.closesWhenApplicationBecomesInactive = YES;
            _popoverComics.isMovable = YES;
            _popoverComics.isDetachable = YES;
            
            CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
            CGFloat positioningRectY = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin / 2;
            NSRect positioningRect = [sender.window convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
            
            _popoverComics.tag = WindowLevelGroupTagSetting;
            
            [_popoverComics setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft animatedInAppFrame:YES];
            
            // MUST call the didContentSizeChange block before popover makes displaying.
            // To update the content view frame before capturing image for animation.
            [self observeComicsViewContentSizeChange];
            
            [self showRelativeToViewWithRect:positioningRect byPopover:_popoverComics sender:sender];
        }
        else
        {
            NSRect visibleRect = [self.view visibleRect];
            CGFloat menuHeight = self.viewMenu.frame.size.height;
            CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
            CGFloat verticalMargin = 10.0;
            CGFloat width = 350.0;
            CGFloat height = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
            NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
            
            if (_popoverComics == nil)
            {
                self.technologiesViewController = [[TechnologiesViewController alloc] initWithNibName:NSStringFromClass([TechnologiesViewController class]) bundle:nil];
                [self.technologiesViewController.view setFrame:contentViewRect];
                
                _popoverComics = [[FLOPopover alloc] initWithContentViewController:self.technologiesViewController];
            }
            
            _popoverComics.shouldShowArrow = YES;
            _popoverComics.animated = YES;
            _popoverComics.shouldChangeSizeWhenApplicationResizes = NO;
            //        _popoverComics.closesWhenPopoverResignsKey = YES;
            //        _popoverComics.closesWhenApplicationBecomesInactive = YES;
            _popoverComics.isMovable = YES;
            _popoverComics.isDetachable = YES;
            _popoverComics.staysInContainer = YES;
            
            _popoverComics.tag = WindowLevelGroupTagSetting;
            
            [_popoverComics setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
            
            [self showRelativeToRectOfViewWithPopover:_popoverComics edgeType:FLOPopoverEdgeTypeForwardTopEdge atView:sender];
        }
    }
}

- (void)setTrashViewHidden:(BOOL)isHidden
{
    [self.viewContainerTrash setHidden:isHidden];
}

#pragma mark - Actions

- (IBAction)btnChangeMode_clicked:(NSButton *)sender
{
    [_presenter changeWindowMode];
}

- (IBAction)btnOpenFinder_clicked:(NSButton *)sender
{
    [_presenter openFinder];
}

- (IBAction)btnOpenSafari_clicked:(NSButton *)sender
{
    [_presenter openSafari];
}

- (IBAction)btnOpenFilms_clicked:(NSButton *)sender
{
    [_presenter openFilmsView];
}

- (IBAction)btnOpenNews_clicked:(NSButton *)sender
{
    [_presenter openNewsView];
}

- (IBAction)btnShowSecondBar_clicked:(NSButton *)sender
{
    [_presenter showSecondBar];
}

- (IBAction)btnOpenComics_clicked:(NSButton *)sender
{
    [_presenter openComicsView];
}

- (IBAction)btnTrashIcon_clicked:(NSButton *)sender
{
    [_presenter showTrashView];
}


#pragma mark - HomeViewProtocols implementation

- (void)refreshUIAppearance
{
    [super refreshUIAppearance];
    
    [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.viewMenu];
    
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerMode];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerFinder];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerSafari];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerFilms];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerNews];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerSecondBar];
    [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerComics];
    
    [Utils setTitle:@"Films popup" color:[NSColor textWhiteColor] forControl:self.btnOpenFilms];
    [Utils setTitle:@"News popup" color:[NSColor textWhiteColor] forControl:self.btnOpenNews];
    [Utils setTitle:@"Show second bar" color:[NSColor textWhiteColor] forControl:self.btnShowSecondBar];
    [Utils setTitle:@"Comics popup" color:[NSColor textWhiteColor] forControl:self.btnOpenComics];
    
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

- (void)viewOpensComicsView
{
    [self showComicsPopupAtView:self.btnOpenComics option:1];
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
    // @warning: MUST set the popover to nil for completely deallocating the content view or content view controller, when popover closed.
    if (popover == _popoverFilms)
    {
        _popoverFilms = nil;
    }
    else if (popover == _popoverNews)
    {
        _popoverNews = nil;
    }
    else if (popover == _popoverComics)
    {
        _popoverComics = nil;
    }
}

@end
