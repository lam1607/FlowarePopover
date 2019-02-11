//
//  HomeViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomeViewController.h"

#import "AbstractWindowController.h"

#import "FilmsViewController.h"
#import "NewsViewController.h"
#import "ComicsViewController.h"
#import "TechnologiesViewController.h"

#import "FLOPopover.h"

#import "AppDelegate.h"

#import "AppleScript.h"

#import "HomePresenter.h"

@interface HomeViewController () <FLOPopoverDelegate>

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

/// @property
///
@property (nonatomic, strong) HomePresenter *presenter;

@property (nonatomic, strong) FLOPopover *popoverFilms;
@property (nonatomic, strong) FLOPopover *popoverNews;
@property (nonatomic, strong) FLOPopover *popoverComics;

@property (nonatomic, strong) FilmsViewController *filmsViewController;
@property (nonatomic, strong) NewsViewController *newsViewController;
@property (nonatomic, strong) TechnologiesViewController *technologiesViewController;
@property (nonatomic, strong) ComicsViewController *comicsViewController;

@property (nonatomic, strong) NSArray<NSString *> *entitlementAppBundles;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupEntitlementAppBundles];
    [self setupUI];
}

- (void)viewWillAppear {
    [super viewWillAppear];
}

#pragma mark - Initialize

- (void)initialize {
    self.presenter = [[HomePresenter alloc] init];
    [self.presenter attachView:self];
    
    self.entitlementAppBundles = [[NSArray alloc] initWithObjects: FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER, FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI, nil];
}

#pragma mark - Setup UI

- (void)setupUI {
    self.constraintVSecondBarHeight.constant = 0.0;
}

- (void)refreshUIColors {
    if ([self.view.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name]) {
        [super refreshUIColors];
        
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _backgroundColor] forView:self.viewMenu];
        
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerMode];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerFinder];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerSafari];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerFilms];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerNews];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerSecondBar];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.viewContainerComics];
        
        [Utils setTitle:@"Films popup" color:[NSColor _textWhiteColor] forControl:self.btnOpenFilms];
        [Utils setTitle:@"News popup" color:[NSColor _textWhiteColor] forControl:self.btnOpenNews];
        [Utils setTitle:@"Show second bar" color:[NSColor _textWhiteColor] forControl:self.btnShowSecondBar];
        [Utils setTitle:@"Comics popup" color:[NSColor _textWhiteColor] forControl:self.btnOpenComics];
        
        [Utils setBackgroundColor:[NSColor _backgroundColor] forView:self.viewSecondBar];
#else
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
#endif
    }
}

#pragma mark - Processes

- (void)setupEntitlementAppBundles {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    [self.entitlementAppBundles enumerateObjectsUsingBlock:^(NSString *bundle, NSUInteger idx, BOOL *stop) {
        [appDelegate addEntitlementBundleId:bundle];
    }];
}

- (void)changeWindowMode {
    [[AbstractWindowController sharedInstance] setWindowMode];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE object:nil userInfo:nil];
}

- (void)openEntitlementApplicationWithIdentifier:(NSString *)appIdentifier {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSURL *appUrl = [NSURL fileURLWithPath:[Utils getAppPathWithIdentifier:appIdentifier]];
    
    if (![[NSWorkspace sharedWorkspace] launchApplicationAtURL:appUrl options:NSWorkspaceLaunchDefault configuration:[NSDictionary dictionary] error:NULL]) {
        // If the application cannot be launched, then re-launch it by script
        NSString *appName = [Utils getAppNameWithIdentifier:appIdentifier];
        AppleScriptOpenApp(appName);
        
        [appDelegate activateEntitlementForBundleId:appIdentifier];
    } else {
        [appDelegate activateEntitlementForBundleId:appIdentifier];
    }
}

- (void)observeComicsViewContentSizeChange {
    if (self.comicsViewController) {
        __weak typeof(self) wself = self;
        
        self.comicsViewController.didContentSizeChange = ^(NSSize newSize) {
            [wself handleComicsViewContentSizeChanging:newSize];
        };
    }
}

- (void)handleComicsViewContentSizeChanging:(NSSize)newSize {
    if (self.comicsViewController) {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.viewMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentViewWidth = 350.0;
        CGFloat contentViewHeight = (newSize.height > availableHeight) ? availableHeight : newSize.height;
        NSRect contentViewRect = self.comicsViewController.view.frame;
        
        contentViewRect = NSMakeRect(contentViewRect.origin.x, contentViewRect.origin.y, contentViewWidth, contentViewHeight);
        
        [self.popoverComics setPopoverContentViewSize:contentViewRect.size];
    }
}

- (void)handleShowSecondBar {
    if (self.comicsViewController) {
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        
        if (secondBarHeight < 40.0) {
            secondBarHeight = 40.0;
        } else {
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
        
        [self.popoverComics setPopoverContentViewSize:contentViewRect.size positioningRect:positioningRect];
    }
}

- (void)setLevelForPopover:(FLOPopover *)popover {
    NSWindowLevel level = [Utils windowLevelBase];
    
    if ([Utils sharedInstance].isApplicationActive) {
        switch (popover.tag) {
            case WindowLevelGroupTagNormal:
                level = [Utils windowLevelNormal];
                break;
            case WindowLevelGroupTagSetting:
                level = [Utils windowLevelSetting];
                break;
            case WindowLevelGroupTagUtility:
                level = [Utils windowLevelUtility];
                break;
            case WindowLevelGroupTagHigh:
                level = [Utils windowLevelHigh];
                break;
            case WindowLevelGroupTagAlert:
                level = [Utils windowLevelAlert];
                break;
            default:
                break;
        }
    }
    
    [popover setPopoverLevel:level];
}

- (void)showRelativeToRectOfViewWithPopover:(FLOPopover *)popover edgeType:(FLOPopoverEdgeType)edgeType atView:(NSView *)sender {
    NSRect rect = (sender.superview != nil) ? sender.superview.bounds : sender.bounds;
    
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setLevelForPopover:popover];
    [popover showRelativeToRect:rect ofView:sender edgeType:edgeType];
}

- (void)showRelativeToViewWithRect:(NSRect)rect byPopover:(FLOPopover *)popover sender:(NSView *)sender {
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setLevelForPopover:popover];
    [popover showRelativeToView:sender withRect:rect];
}

- (void)showFilmsPopupAtView:(NSView *)sender {
    if ([self.popoverFilms isShown]) {
        [self.popoverFilms close];
        return;
    }
    
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.viewMenu.frame.size.height;
    CGFloat verticalMargin = 10.0;
    CGFloat width = 0.5 * visibleRect.size.width;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
    
    if (self.popoverFilms == nil) {
        self.filmsViewController = [[FilmsViewController alloc] initWithNibName:NSStringFromClass([FilmsViewController class]) bundle:nil];
        [self.filmsViewController.view setFrame:contentViewRect];
        
        self.popoverFilms = [[FLOPopover alloc] initWithContentViewController:self.filmsViewController type:FLOViewPopover];
    }
    
    //    self.popoverFilms.alwaysOnTop = YES;
    //    self.popoverFilms.shouldShowArrow = YES;
    self.popoverFilms.animated = YES;
    self.popoverFilms.closesWhenPopoverResignsKey = YES;
    //    self.popoverFilms.closesWhenApplicationBecomesInactive = YES;
    self.popoverFilms.isMovable = YES;
    self.popoverFilms.isDetachable = YES;
    
    self.popoverFilms.tag = WindowLevelGroupTagNormal;
    
    //    [self.popoverFilms setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
    [self.popoverFilms setAnimationBehaviour:FLOPopoverAnimationBehaviorTransform type:FLOPopoverAnimationScale];
    
    [self showRelativeToRectOfViewWithPopover:self.popoverFilms edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
}

- (void)showNewsPopupAtView:(NSView *)sender {
    if ([self.popoverNews isShown]) {
        [self.popoverNews close];
        return;
    }
    
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.viewMenu.frame.size.height;
    CGFloat verticalMargin = 10.0;
    CGFloat width = 0.5 * visibleRect.size.width;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
    
    if (self.popoverNews == nil) {
        self.newsViewController = [[NewsViewController alloc] initWithNibName:NSStringFromClass([NewsViewController class]) bundle:nil];
        [self.newsViewController.view setFrame:contentViewRect];
        
        self.popoverNews = [[FLOPopover alloc] initWithContentViewController:self.newsViewController];
    }
    
    //    self.popoverNews.alwaysOnTop = YES;
    //    self.popoverNews.shouldShowArrow = YES;
    self.popoverNews.animated = YES;
    //    self.popoverNews.closesWhenPopoverResignsKey = YES;
    //    self.popoverNews.closesWhenApplicationBecomesInactive = YES;
    //    self.popoverNews.closesAfterTimeInterval = 3.0;
    self.popoverNews.isMovable = YES;
    self.popoverNews.isDetachable = YES;
    
    self.popoverNews.tag = WindowLevelGroupTagNormal;
    
    [self.popoverNews setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
    
    [self showRelativeToRectOfViewWithPopover:self.popoverNews edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
}

- (void)showComicsPopupAtView:(NSView *)sender option:(NSInteger)option {
    if ([self.popoverComics isShown]) {
        [self.popoverComics close];
        return;
    }
    
    if (option == 1) {
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
        
        if (self.popoverComics == nil) {
            self.comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
            [self.comicsViewController.view setFrame:contentViewRect];
            self.popoverComics = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController type:FLOViewPopover];
        }
        
        self.popoverComics.alwaysOnTop = YES;
        //        self.popoverComics.shouldShowArrow = YES;
        self.popoverComics.animated = YES;
        //        self.popoverComics.animatedForwarding = YES;
        self.popoverComics.animatedByMovingFrame = YES;
        self.popoverComics.animatedByMovingFrame = YES;
        self.popoverComics.shouldChangeSizeWhenApplicationResizes = NO;
        //        self.popoverComics.closesWhenPopoverResignsKey = YES;
        //        self.popoverComics.closesWhenApplicationBecomesInactive = YES;
        self.popoverComics.isMovable = YES;
        //        self.popoverComics.isDetachable = YES;
        
        CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
        CGFloat positioningRectY = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin / 2;
        NSRect positioningRect = [sender.window convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
        
        self.popoverComics.tag = WindowLevelGroupTagUtility;
        
        [self.popoverComics setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft animatedInApplicationRect:YES];
        
        // MUST call the didContentSizeChange block before popover makes displaying.
        // To update the content view frame before capturing image for animation.
        [self observeComicsViewContentSizeChange];
        
        [self showRelativeToViewWithRect:positioningRect byPopover:self.popoverComics sender:sender];
    } else {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.viewMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat width = 350.0;
        CGFloat height = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (self.popoverComics == nil) {
            self.technologiesViewController = [[TechnologiesViewController alloc] initWithNibName:NSStringFromClass([TechnologiesViewController class]) bundle:nil];
            [self.technologiesViewController.view setFrame:contentViewRect];
            self.popoverComics = [[FLOPopover alloc] initWithContentViewController:self.technologiesViewController];
        }
        
        self.popoverComics.alwaysOnTop = YES;
        self.popoverComics.shouldShowArrow = YES;
        self.popoverComics.animated = YES;
        self.popoverComics.shouldChangeSizeWhenApplicationResizes = NO;
        //        self.popoverComics.closesWhenPopoverResignsKey = YES;
        //        self.popoverComics.closesWhenApplicationBecomesInactive = YES;
        self.popoverComics.isMovable = YES;
        self.popoverComics.isDetachable = YES;
        
        self.popoverComics.tag = WindowLevelGroupTagUtility;
        
        [self.popoverComics setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
        
        [self showRelativeToRectOfViewWithPopover:self.popoverComics edgeType:FLOPopoverEdgeTypeForwardTopEdge atView:sender];
    }
}

#pragma mark - Actions

- (IBAction)btnChangeMode_clicked:(NSButton *)sender {
    [self.presenter changeWindowMode];
}

- (IBAction)btnOpenFinder_clicked:(NSButton *)sender {
    [self.presenter openFinder];
}

- (IBAction)btnOpenSafari_clicked:(NSButton *)sender {
    [self.presenter openSafari];
}

- (IBAction)btnOpenFilms_clicked:(NSButton *)sender {
    [self.presenter openFilmsView];
}

- (IBAction)btnOpenNews_clicked:(NSButton *)sender {
    [self.presenter openNewsView];
}

- (IBAction)btnShowSecondBar_clicked:(NSButton *)sender {
    [self.presenter showSecondBar];
}

- (IBAction)btnOpenComics_clicked:(NSButton *)sender {
    [self.presenter openComicsView];
}

#pragma mark - HomeViewProtocols implementation

- (void)viewDidSelectWindowModeChanging {
    [self changeWindowMode];
}

- (void)viewShouldOpenFinder {
    [self openEntitlementApplicationWithIdentifier:FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER];
}

- (void)viewShouldOpenSafari {
    [self openEntitlementApplicationWithIdentifier:FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI];
}

- (void)viewShouldOpenFilmsView {
    [self showFilmsPopupAtView:self.btnOpenFilms];
}
- (void)viewShouldOpenNewsView {
    [self showNewsPopupAtView:self.btnOpenNews];
}

- (void)viewShouldOpenComicsView {
    [self showComicsPopupAtView:self.btnOpenComics option:1];
}

- (void)viewShouldShowSecondBar {
    [self handleShowSecondBar];
}

#pragma mark - FLOPopoverDelegate

- (void)floPopoverWillShow:(FLOPopover *)popover {
}

- (void)floPopoverDidShow:(FLOPopover *)popover {
}

- (void)floPopoverWillClose:(FLOPopover *)popover {
}

- (void)floPopoverDidClose:(FLOPopover *)popover {
    // @warning: MUST set the popover to nil for completely deallocating the content view or content view controller, when popover closed.
    if (popover == self.popoverFilms) {
        self.popoverFilms = nil;
    } else if (popover == self.popoverNews) {
        self.popoverNews = nil;
    } else if (popover == self.popoverComics) {
        self.popoverComics = nil;
    }
}

@end
