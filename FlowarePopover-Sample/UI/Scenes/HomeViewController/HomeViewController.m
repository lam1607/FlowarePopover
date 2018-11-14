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

@property (nonatomic, strong) HomePresenter *_homePresenter;

@property (nonatomic, strong) FLOPopover *_popoverWindow;
@property (nonatomic, strong) FLOPopover *_popoverView;
@property (nonatomic, strong) FLOPopover *_popoverMix;

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

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._homePresenter = [[HomePresenter alloc] init];
    [self._homePresenter attachView:self];
    
    self.entitlementAppBundles = [[NSArray alloc] initWithObjects: FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER, FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI, nil];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    self.constraintVSecondBarHeight.constant = 0.0;
}

- (void)refreshUIColors {
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

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)setupEntitlementAppBundles {
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    
    [self.entitlementAppBundles enumerateObjectsUsingBlock:^(NSString *bundle, NSUInteger idx, BOOL *stop) {
        [appDelegate addEntitlementBundleId:bundle];
    }];
}

- (void)changeWindowMode {
    [[BaseWindowController sharedInstance] setWindowMode];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE object:nil userInfo:nil];
}

- (void)openEntitlementApplicationWithIdentifier:(NSString *)appIdentifier {
    AppDelegate *appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
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

- (void)observePopoverMixRelativeToViewContentSizeChange {
    if (self.comicsViewController) {
        __weak typeof(self) wself = self;
        
        self.comicsViewController.didContentSizeChange = ^{
            [wself handlePopoverMixRelativeToViewContentSizeChange];
        };
    }
}

- (void)handlePopoverMixRelativeToViewContentSizeChange {
    if (self.comicsViewController) {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.vMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
        CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
        NSRect contentViewRect = self.comicsViewController.view.frame;
        
        contentViewRect = NSMakeRect(contentViewRect.origin.x, contentViewRect.origin.y, contentViewRect.size.width, contentViewHeight);
        
        [self._popoverMix setPopoverContentViewSize:contentViewRect.size];
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
        CGFloat contentViewWidth = 350.0;
        CGFloat availableHeight = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
        CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, contentViewWidth, contentViewHeight);
        
        CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
        CGFloat positioningRectY = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin / 2 - contentViewHeight;
        NSRect contentRect = NSMakeRect(positioningRectX, positioningRectY, contentViewRect.size.width, contentViewRect.size.height);
        
        [self._popoverMix setPopoverContentViewSize:contentViewRect.size positioningRect:contentRect];
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

- (void)showRelativeToRectOfViewWithPopover:(FLOPopover *)popover edgeType:(FLOPopoverEdgeType)edgeType atView:(NSView *)positioningView {
    NSRect positioningRect = NSMakeRect(positioningView.bounds.origin.x, positioningView.bounds.origin.y, positioningView.bounds.size.width, self.vMenu.frame.size.height);
    positioningRect = (positioningView.superview != nil) ? positioningView.superview.bounds : positioningView.bounds;
    
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setWindowLevelForPopover:popover];
    
    if ([popover isShown]) {
        [popover close];
    } else {
        [popover showRelativeToRect:positioningRect ofView:positioningView edgeType:edgeType];
    }
}

- (void)showRelativeToViewWithRect:(NSRect)rect byPopover:(FLOPopover *)popover atView:(NSView *)positioningView {
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setWindowLevelForPopover:popover];
    
    if ([popover isShown]) {
        [popover close];
    } else {
        [popover showRelativeToView:positioningView withRect:rect];
    }
}

- (void)showFilmsPopupAtView:(NSView *)sender {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0;
    CGFloat width = 0.5 * visibleRect.size.width;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
    
    if (self._popoverWindow == nil) {
        self.filmsViewController = [[FilmsViewController alloc] initWithNibName:NSStringFromClass([FilmsViewController class]) bundle:nil];
        [self.filmsViewController.view setFrame:contentViewRect];
        
        self._popoverWindow = [[FLOPopover alloc] initWithContentViewController:self.filmsViewController popoverType:FLOWindowPopover];
    }
    
    //    self._popoverWindow.alwaysOnTop = YES;
    //    self._popoverWindow.shouldShowArrow = YES;
    self._popoverWindow.animated = YES;
    //    self._popoverWindow.closesWhenPopoverResignsKey = YES;
    //    self._popoverWindow.closesWhenApplicationBecomesInactive = YES;
    //    self._popoverWindow.popoverMovable = YES;
    
    [self._popoverWindow setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
    
    [self showRelativeToRectOfViewWithPopover:self._popoverWindow edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
}

- (void)showNewsPopupAtView:(NSView *)sender {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0;
    CGFloat width = 0.5 * visibleRect.size.width;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
    
    if (self._popoverView == nil) {
        self.newsViewController = [[NewsViewController alloc] initWithNibName:NSStringFromClass([NewsViewController class]) bundle:nil];
        [self.newsViewController.view setFrame:contentViewRect];
        
        self._popoverView = [[FLOPopover alloc] initWithContentViewController:self.newsViewController popoverType:FLOWindowPopover];
    }
    
    //    self._popoverView.alwaysOnTop = YES;
    //    self._popoverView.shouldShowArrow = YES;
    self._popoverView.animated = YES;
    //    self._popoverView.closesWhenPopoverResignsKey = YES;
    //    self._popoverView.closesWhenApplicationBecomesInactive = YES;
    //    self._popoverView.popoverMovable = YES;
    
    [self._popoverView setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
    
    [self showRelativeToRectOfViewWithPopover:self._popoverView edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
}

- (void)showComicsPopupAtView:(NSView *)sender option:(NSInteger)option {
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
        
        if (self._popoverMix == nil) {
            self.comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
            [self.comicsViewController.view setFrame:contentViewRect];
            
            self._popoverMix = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController popoverType:FLOWindowPopover];
        }
        
        self._popoverMix.alwaysOnTop = YES;
        self._popoverMix.shouldShowArrow = YES;
        self._popoverMix.animated = YES;
        //    self._popoverMix.closesWhenPopoverResignsKey = YES;
        //    self._popoverMix.closesWhenApplicationBecomesInactive = YES;
        //    self._popoverMix.popoverMovable = YES;
        //    self._popoverMix.popoverShouldDetach = YES;
        
        CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
        CGFloat positioningRectY = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin / 2 - contentViewHeight;
        NSRect contentRect = NSMakeRect(positioningRectX, positioningRectY, contentViewRect.size.width, contentViewRect.size.height);
        
        [self._popoverMix setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
        
        [self showRelativeToViewWithRect:contentRect byPopover:self._popoverMix atView:sender];
    } else {
        NSRect visibleRect = [self.view visibleRect];
        CGFloat menuHeight = self.vMenu.frame.size.height;
        CGFloat secondBarHeight = self.constraintVSecondBarHeight.constant;
        CGFloat verticalMargin = 10.0;
        CGFloat width = 350.0;
        CGFloat height = visibleRect.size.height - menuHeight - secondBarHeight - verticalMargin;
        NSRect contentViewRect = NSMakeRect(0.0, 0.0, width, height);
        
        if (self._popoverMix == nil) {
            self.dataViewController = [[DataViewController alloc] initWithNibName:NSStringFromClass([DataViewController class]) bundle:nil];
            [self.dataViewController.view setFrame:contentViewRect];
            self._popoverMix = [[FLOPopover alloc] initWithContentViewController:self.dataViewController popoverType:FLOWindowPopover];
        }
        
        self._popoverMix.alwaysOnTop = YES;
        self._popoverMix.shouldShowArrow = YES;
        self._popoverMix.animated = YES;
        //    self._popoverMix.closesWhenPopoverResignsKey = YES;
        //    self._popoverMix.closesWhenApplicationBecomesInactive = YES;
        //    self._popoverMix.popoverMovable = YES;
        //    self._popoverMix.popoverShouldDetach = YES;
        
        [self._popoverMix setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
        
        [self showRelativeToRectOfViewWithPopover:self._popoverMix edgeType:FLOPopoverEdgeTypeBelowRightEdge atView:sender];
    }
    
    [self observePopoverMixRelativeToViewContentSizeChange];
}

#pragma mark -
#pragma mark - Actions
#pragma mark -
- (IBAction)btnChangeMode_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"changeMode", @"object": sender}];
}

- (IBAction)btnOpenFinderApp_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"openFinder", @"object": sender}];
}

- (IBAction)btnOpenSafariApp_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"openSafari", @"object": sender}];
}

- (IBAction)btnOpenFilmsPopup_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"filmsPopup", @"object": sender}];
}

- (IBAction)btnOpenNewsPopup_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"newsPopup", @"object": sender}];
}

- (IBAction)btnShowSecondBar_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"showSecondBar", @"object": sender}];
}

- (IBAction)btnOpenComicsPopup_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"comicsPopup", @"object": sender}];
}

#pragma mark -
#pragma mark - HomeViewProtocols implementation
#pragma mark -
- (void)showPopoverAtSender:(NSDictionary *)senderInfo {
    NSString *keyType = @"type";
    NSString *keyObject = @"object";
    
    if ([senderInfo objectForKey:keyObject] && [[senderInfo objectForKey:keyObject] isKindOfClass:[NSView class]]) {
        NSView *sender = (NSView *) [senderInfo objectForKey:keyObject];
        
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

#pragma mark -
#pragma mark - FLOPopoverDelegate
#pragma mark -
- (void)floPopoverDidShow:(NSResponder *)popover {
}

- (void)floPopoverDidClose:(NSResponder *)popover {
}

@end
