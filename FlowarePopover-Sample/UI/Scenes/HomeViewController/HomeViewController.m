//
//  HomeViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "HomeViewController.h"

#import "BaseWindowController.h"

#import "FilmsViewController.h"
#import "NewsViewController.h"
#import "DataViewController.h"
#import "ComicsViewController.h"

#import "FLOPopover.h"

#import "AppDelegate.h"

#import "AppleScript.h"

#define SHOULD_COMICS_POPOVER_ANCHOR_TO_APPLICATION_VIEW

@interface HomeViewController () <FLOPopoverDelegate>

@property (weak) IBOutlet NSView *vMenu;

@property (weak) IBOutlet NSView *vChangeMode;
@property (weak) IBOutlet NSButton *btnChangeMode;
@property (weak) IBOutlet NSView *vOpenFinderApp;
@property (weak) IBOutlet NSButton *btnOpenFinderApp;
@property (weak) IBOutlet NSView *vOpenSafariApp;
@property (weak) IBOutlet NSButton *btnOpenSafariApp;

@property (weak) IBOutlet NSView *vOpenFilmsPopup;
@property (weak) IBOutlet NSButton *btnOpenFilmsPopup;
@property (weak) IBOutlet NSView *vOpenNewsPopup;
@property (weak) IBOutlet NSButton *btnOpenNewsPopup;
@property (weak) IBOutlet NSView *vShowSecondBar;
@property (weak) IBOutlet NSButton *btnShowSecondBar;
@property (weak) IBOutlet NSView *vOpenComicsPopup;
@property (weak) IBOutlet NSButton *btnOpenComicsPopup;

@property (weak) IBOutlet NSView *vSecondBar;
@property (weak) IBOutlet NSLayoutConstraint *constraintVSecondBarHeight;

@property (nonatomic, strong) HomePresenter *homePresenter;

@property (nonatomic, strong) FLOPopover *popoverFilms;
@property (nonatomic, strong) FLOPopover *popoverNews;
@property (nonatomic, strong) FLOPopover *popoverComics;

@property (nonatomic, strong) FilmsViewController *filmsViewController;
@property (nonatomic, strong) NewsViewController *newsViewController;
@property (nonatomic, strong) DataViewController *dataViewController;
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
    self.homePresenter = [[HomePresenter alloc] init];
    [self.homePresenter attachView:self];
    
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
        [Utils setBackgroundColor:[NSColor _backgroundColor] forView:self.vMenu];
        
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vChangeMode];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenFinderApp];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenSafariApp];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenFilmsPopup];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenNewsPopup];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vShowSecondBar];
        [Utils setBackgroundColor:[NSColor _grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenComicsPopup];
        
        [Utils setTitle:@"Films popup" color:[NSColor _textWhiteColor] forControl:self.btnOpenFilmsPopup];
        [Utils setTitle:@"News popup" color:[NSColor _textWhiteColor] forControl:self.btnOpenNewsPopup];
        [Utils setTitle:@"Show second bar" color:[NSColor _textWhiteColor] forControl:self.btnShowSecondBar];
        [Utils setTitle:@"Comics popup" color:[NSColor _textWhiteColor] forControl:self.btnOpenComicsPopup];
        
        [Utils setBackgroundColor:[NSColor _backgroundColor] forView:self.vSecondBar];
#else
        [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.vMenu];
        
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vChangeMode];
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenFinderApp];
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenSafariApp];
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenFilmsPopup];
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenNewsPopup];
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vShowSecondBar];
        [Utils setBackgroundColor:[NSColor grayColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenComicsPopup];
        
        [Utils setTitle:@"Films popup" color:[NSColor textWhiteColor] forControl:self.btnOpenFilmsPopup];
        [Utils setTitle:@"News popup" color:[NSColor textWhiteColor] forControl:self.btnOpenNewsPopup];
        [Utils setTitle:@"Show second bar" color:[NSColor textWhiteColor] forControl:self.btnShowSecondBar];
        [Utils setTitle:@"Comics popup" color:[NSColor textWhiteColor] forControl:self.btnOpenComicsPopup];
        
        [Utils setBackgroundColor:[NSColor backgroundColor] forView:self.vSecondBar];
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
    [[BaseWindowController sharedInstance] setWindowMode];
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
        CGFloat menuHeight = self.vMenu.frame.size.height;
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
        
        [self.vSecondBar setNeedsUpdateConstraints:YES];
        [self.vSecondBar updateConstraints];
        [self.vSecondBar updateConstraintsForSubtreeIfNeeded];
        [self.vSecondBar layoutSubtreeIfNeeded];
        
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.vMenu.frame.size.height;
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

- (void)setWindowLevelForPopover:(FLOPopover *)popover {
    NSWindowLevel popoverWindowLevel = [BaseWindowController sharedInstance].window.level;
    
    if ([[BaseWindowController sharedInstance] windowInDesktopMode]) {
        if (popover.alwaysOnTop == YES) {
            popoverWindowLevel = NSStatusWindowLevel;
        } else {
            popoverWindowLevel = NSFloatingWindowLevel;
        }
    }
    
    [popover setPopoverLevel:popoverWindowLevel];
}

- (void)showRelativeToRectOfViewWithPopover:(FLOPopover *)popover edgeType:(FLOPopoverEdgeType)edgeType atView:(NSView *)sender {
    NSRect rect = (sender.superview != nil) ? sender.superview.bounds : sender.bounds;
    
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setWindowLevelForPopover:popover];
    
    if ([popover isShown]) {
        [popover close];
    } else {
        [popover showRelativeToRect:rect ofView:sender edgeType:edgeType];
    }
}

- (void)showRelativeToViewWithRect:(NSRect)rect byPopover:(FLOPopover *)popover sender:(NSView *)sender {
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setWindowLevelForPopover:popover];
    
    if ([popover isShown]) {
        [popover close];
    } else {
#ifdef SHOULD_COMICS_POPOVER_ANCHOR_TO_APPLICATION_VIEW
        [popover showRelativeToView:[BaseWindowController sharedInstance].window.contentView withRect:rect sender:sender relativePositionType:FLOPopoverRelativePositionTopLeading];
#else
        [popover showRelativeToView:sender withRect:rect];
#endif
    }
}

- (void)showFilmsPopupAtView:(NSView *)sender {
    if ([self.popoverFilms isShown]) {
        [self.popoverFilms close];
        return;
    }
    
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
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
    CGFloat menuHeight = self.vMenu.frame.size.height;
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
    self.popoverNews.closesAfterTimeInterval = 3.0;
    self.popoverNews.isMovable = YES;
    self.popoverNews.isDetachable = YES;
    
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
        CGFloat menuHeight = self.vMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat contentViewWidth = 350.0;
        CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
        CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
        
        if (self.popoverComics == nil) {
            self.comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
            self.popoverComics = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController];
        }
        
        self.popoverComics.alwaysOnTop = YES;
        //        self.popoverComics.shouldShowArrow = YES;
        self.popoverComics.animated = YES;
        //        self.popoverComics.animatedForwarding = YES;
        //        self.popoverComics.makesKeyWindowOnMouseEvents = YES;
        self.popoverComics.shouldChangeSizeWhenApplicationResizes = NO;
        //        self.popoverComics.closesWhenPopoverResignsKey = YES;
        //        self.popoverComics.closesWhenApplicationBecomesInactive = YES;
        self.popoverComics.isMovable = YES;
        //        self.popoverComics.isDetachable = YES;
        
        CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
        CGFloat positioningRectY = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin / 2;
        NSRect positioningRect = [sender.window convertRectToScreen:NSMakeRect(positioningRectX, positioningRectY, 0.0, 0.0)];
        
        [self.popoverComics setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft animatedInApplicationRect:YES];
        
        // MUST call the didContentSizeChange block before popover makes displaying.
        // To update the content view frame before capturing image for animation.
        [self observeComicsViewContentSizeChange];
        
        [self showRelativeToViewWithRect:positioningRect byPopover:self.popoverComics sender:sender];
    } else {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.vMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat width = 350.0;
        CGFloat height = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (self.popoverComics == nil) {
            self.dataViewController = [[DataViewController alloc] initWithNibName:NSStringFromClass([DataViewController class]) bundle:nil];
            [self.dataViewController.view setFrame:contentViewRect];
            self.popoverComics = [[FLOPopover alloc] initWithContentViewController:self.dataViewController];
        }
        
        self.popoverComics.alwaysOnTop = YES;
        self.popoverComics.shouldShowArrow = YES;
        self.popoverComics.animated = YES;
        self.popoverComics.shouldChangeSizeWhenApplicationResizes = NO;
        //        self.popoverComics.closesWhenPopoverResignsKey = YES;
        //        self.popoverComics.closesWhenApplicationBecomesInactive = YES;
        self.popoverComics.isMovable = YES;
        self.popoverComics.isDetachable = YES;
        
        [self.popoverComics setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
        
        [self showRelativeToRectOfViewWithPopover:self.popoverComics edgeType:FLOPopoverEdgeTypeForwardTopEdge atView:sender];
    }
}

#pragma mark - Actions

- (IBAction)btnChangeMode_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"changeMode", @"object": sender}];
}

- (IBAction)btnOpenFinderApp_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"openFinder", @"object": sender}];
}

- (IBAction)btnOpenSafariApp_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"openSafari", @"object": sender}];
}

- (IBAction)btnOpenFilmsPopup_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"filmsPopup", @"object": sender}];
}

- (IBAction)btnOpenNewsPopup_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"newsPopup", @"object": sender}];
}

- (IBAction)btnShowSecondBar_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"showSecondBar", @"object": sender}];
}

- (IBAction)btnOpenComicsPopup_clicked:(NSButton *)sender {
    [self.homePresenter doSelectSender:@{@"type": @"comicsPopup", @"object": sender}];
}

#pragma mark - HomeViewProtocols implementation

- (void)showPopoverAtSender:(NSDictionary *)senderInfo {
    NSString *keyType = @"type";
    NSString *keyObject = @"object";
    
    if ([senderInfo objectForKey:keyObject] && [[senderInfo objectForKey:keyObject] isKindOfClass:[NSView class]]) {
        NSView *sender = (NSView *)[senderInfo objectForKey:keyObject];
        
        if ([[senderInfo objectForKey:keyType] isEqualToString:@"changeMode"]) {
            [self changeWindowMode];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"openFinder"]) {
            [self openEntitlementApplicationWithIdentifier:FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"openSafari"]) {
            [self openEntitlementApplicationWithIdentifier:FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"filmsPopup"]) {
            [self showFilmsPopupAtView:sender];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"newsPopup"]) {
            [self showNewsPopupAtView:sender];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"showSecondBar"]) {
            [self handleShowSecondBar];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"comicsPopup"]) {
            [self showComicsPopupAtView:sender option:1];
        }
    }
}

#pragma mark - FLOPopoverDelegate

- (void)floPopoverWillShow:(FLOPopover *)popover {
}

- (void)floPopoverDidShow:(FLOPopover *)popover {
}

- (void)floPopoverWillClose:(FLOPopover *)popover {
}

- (void)floPopoverDidClose:(FLOPopover *)popover {
    if (popover == self.popoverFilms) {
        self.popoverFilms = nil;
    } else if (popover == self.popoverNews) {
        self.popoverNews = nil;
    } else if (popover == self.popoverComics) {
        self.popoverComics = nil;
    }
}

@end
