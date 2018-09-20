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

@property (weak) IBOutlet NSView *vShowWindowPopup;
@property (weak) IBOutlet NSButton *btnShowWindowPopup;
@property (weak) IBOutlet NSView *vShowViewPopup;
@property (weak) IBOutlet NSButton *btnShowViewPopup;
@property (weak) IBOutlet NSView *vShowDataMix;
@property (weak) IBOutlet NSButton *btnShowDataMix;

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
    
    self.filmsViewController = [[FilmsViewController alloc] initWithNibName:NSStringFromClass([FilmsViewController class]) bundle:nil];
    self.newsViewController = [[NewsViewController alloc] initWithNibName:NSStringFromClass([NewsViewController class]) bundle:nil];
    self.dataViewController = [[DataViewController alloc] initWithNibName:NSStringFromClass([DataViewController class]) bundle:nil];
    
    self.comicsViewController = [[ComicsViewController alloc] initWithNibName:NSStringFromClass([ComicsViewController class]) bundle:nil];
    [self.comicsViewController.view setFrame:NSZeroRect];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    [self setBackgroundColor:[NSColor colorGray] forView:self.vMenu];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize:14.0f weight:NSFontWeightRegular], NSFontAttributeName,
                                     [NSColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [self setBackgroundColor:[NSColor colorDust] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vChangeMode];
    [self setTitle:@"Change window mode" attributes:titleAttributes forControl:self.btnChangeMode];
    
    [self setBackgroundColor:[NSColor colorMoss] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenFinderApp];
    [self setTitle:@"Open Finder" attributes:titleAttributes forControl:self.btnOpenFinderApp];
    
    [self setBackgroundColor:[NSColor colorOrange] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vOpenSafariApp];
    [self setTitle:@"Open Safari" attributes:titleAttributes forControl:self.btnOpenSafariApp];
    
    [self setBackgroundColor:[NSColor colorTeal] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vShowWindowPopup];
    [self setTitle:@"Window popover" attributes:titleAttributes forControl:self.btnShowWindowPopup];
    
    [self setBackgroundColor:[NSColor colorLavender] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vShowViewPopup];
    [self setTitle:@"View popover" attributes:titleAttributes forControl:self.btnShowViewPopup];
    
    [self setBackgroundColor:[NSColor colorViolet] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vShowDataMix];
    [self setTitle:@"Mix popover" attributes:titleAttributes forControl:self.btnShowDataMix];
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
    __weak typeof(self) wself = self;
    
    self.comicsViewController.didContentSizeChange = ^{
        [wself handlePopoverMixRelativeToViewContentSizeChange];
    };
}

- (void)handlePopoverMixRelativeToViewContentSizeChange {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0f;
    CGFloat availableHeight = visibleRect.size.height - menuHeight - verticalMargin;
    CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
    CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
    NSRect contentViewRect = self.comicsViewController.view.frame;
    
    contentViewRect = NSMakeRect(contentViewRect.origin.x, contentViewRect.origin.y, contentViewRect.size.width, contentViewHeight);
    
    CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
    CGFloat positioningRectY = visibleRect.size.height - menuHeight - verticalMargin / 2 - contentViewHeight;
    NSRect positioningRect = NSMakeRect(positioningRectX, positioningRectY, 0.0f, 0.0f);
    
    [self._popoverMix rearrangePopoverWithNewContentViewFrame:contentViewRect positioningRect:positioningRect];
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
        [popover closePopover:popover];
    } else {
        [popover showRelativeToRect:positioningRect ofView:positioningView edgeType:edgeType];
    }
}

- (void)showRelativeToViewWithRect:(NSRect)positioningRect byPopover:(FLOPopover *)popover atView:(NSView *)positioningView {
    if (popover.delegate == nil) {
        popover.delegate = self;
    }
    
    [self setWindowLevelForPopover:popover];
    
    if ([popover isShown]) {
        [popover closePopover:popover];
    } else {
        [popover showRelativeToView:positioningView withRect:positioningRect];
    }
}

- (void)showPopoverWindowRelativeToRectOfView:(NSView *)sender {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0f;
    CGFloat width = 400.0f;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0f, 0.0f, width, height);
    
    if (self._popoverWindow == nil) {
        [self.filmsViewController.view setFrame:contentViewRect];
        
        self._popoverWindow = [[FLOPopover alloc] initWithContentViewController:self.filmsViewController popoverType:FLOWindowPopover];
    }
    
    //    self._popoverWindow.alwaysOnTop = YES;
    //    self._popoverWindow.shouldShowArrow = YES;
    self._popoverWindow.animated = YES;
    //    self._popoverWindow.closesWhenPopoverResignsKey = YES;
    //    self._popoverWindow.closesWhenApplicationBecomesInactive = YES;
    //    self._popoverWindow.popoverMovable = YES;
    
    //    if (NSEqualRects(self.filmsViewController.view.frame, contentViewRect) == NO) {
    //        [self.filmsViewController.view setFrame:contentViewRect];
    //    }
    
    [self._popoverWindow setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
    
    [self showRelativeToRectOfViewWithPopover:self._popoverWindow edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
}

- (void)showPopoverViewRelativeToRectOfView:(NSView *)sender {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0f;
    CGFloat width = 350.0f;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0f, 0.0f, width, height);
    
    if (self._popoverView == nil) {
        [self.newsViewController.view setFrame:contentViewRect];
        
        self._popoverView = [[FLOPopover alloc] initWithContentViewController:self.newsViewController popoverType:FLOViewPopover];
    }
    
    //    self._popoverView.alwaysOnTop = YES;
    //    self._popoverView.shouldShowArrow = YES;
    self._popoverView.animated = YES;
    //    self._popoverView.closesWhenPopoverResignsKey = YES;
    //    self._popoverView.closesWhenApplicationBecomesInactive = YES;
    //    self._popoverView.popoverMovable = YES;
    
    //    if (NSEqualRects(self.newsViewController.view.frame, contentViewRect) == NO) {
    //        [self.newsViewController.view setFrame:contentViewRect];
    //    }
    
    [self._popoverView setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationLeftToRight];
    
    [self showRelativeToRectOfViewWithPopover:self._popoverView edgeType:FLOPopoverEdgeTypeBelowLeftEdge atView:sender];
}

- (void)showPopoverMixRelativeToRectOfView:(NSView *)sender {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0f;
    CGFloat width = 350.0f;
    CGFloat height = visibleRect.size.height - menuHeight - verticalMargin;
    NSRect contentViewRect = NSMakeRect(0.0f, 0.0f, width, height);
    
    if (self._popoverMix == nil) {
        [self.dataViewController.view setFrame:contentViewRect];
        
        self._popoverMix = [[FLOPopover alloc] initWithContentViewController:self.dataViewController popoverType:FLOWindowPopover];
    }
    
    self._popoverMix.alwaysOnTop = YES;
    //    self._popoverMix.shouldShowArrow = YES;
    self._popoverMix.animated = YES;
    //    self._popoverMix.closesWhenPopoverResignsKey = YES;
    //    self._popoverMix.closesWhenApplicationBecomesInactive = YES;
    //    self._popoverMix.popoverMovable = YES;
    //    self._popoverMix.popoverShouldDetach = YES;
    
    [self._popoverMix setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
    
    [self showRelativeToRectOfViewWithPopover:self._popoverMix edgeType:FLOPopoverEdgeTypeBelowRightEdge atView:sender];
}

- (void)showPopoverMixRelativeToView:(NSView *)sender {
    NSRect visibleRect = [self.view visibleRect];
    CGFloat menuHeight = self.vMenu.frame.size.height;
    CGFloat verticalMargin = 10.0f;
    CGFloat contentViewWidth = 350.0f;
    CGFloat availableHeight = visibleRect.size.height - menuHeight - verticalMargin;
    CGFloat contentHeight = [self.comicsViewController getContentSizeHeight];
    CGFloat contentViewHeight = (contentHeight > availableHeight) ? availableHeight : contentHeight;
    NSRect contentViewRect = NSMakeRect(0.0f, 0.0f, contentViewWidth, contentViewHeight);
    
    if (self._popoverMix == nil) {
        [self.comicsViewController.view setFrame:contentViewRect];
        
        self._popoverMix = [[FLOPopover alloc] initWithContentViewController:self.comicsViewController popoverType:FLOWindowPopover];
    }
    
    self._popoverMix.alwaysOnTop = YES;
    //    self._popoverMix.shouldShowArrow = YES;
    self._popoverMix.animated = YES;
    //    self._popoverMix.closesWhenPopoverResignsKey = YES;
    //    self._popoverMix.closesWhenApplicationBecomesInactive = YES;
    //    self._popoverMix.popoverMovable = YES;
    //    self._popoverMix.popoverShouldDetach = YES;
    
    CGFloat positioningRectX = visibleRect.size.width - contentViewRect.size.width - verticalMargin / 2;
    CGFloat positioningRectY = visibleRect.size.height - menuHeight - verticalMargin / 2 - contentViewHeight;
    NSRect positioningRect = NSMakeRect(positioningRectX, positioningRectY, 0.0f, 0.0f);
    
    [self._popoverMix setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
    
    [self showRelativeToViewWithRect:positioningRect byPopover:self._popoverMix atView:sender];
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

- (IBAction)btnShowWindowPopup_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"popoverWindow", @"object": sender}];
}

- (IBAction)btnShowViewPopup_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"popoverView", @"object": sender}];
}

- (IBAction)btnShowDataMix_clicked:(NSButton *)sender {
    [self._homePresenter doSelectSender:@{@"type": @"popoverMix", @"object": sender}];
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
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"popoverWindow"]) {
            [self showPopoverWindowRelativeToRectOfView:sender];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"popoverView"]) {
            [self showPopoverViewRelativeToRectOfView:sender];
        } else if ([[senderInfo objectForKey:keyType] isEqualToString:@"popoverMix"]) {
//            [self showPopoverMixRelativeToRectOfView:sender];
            [self showPopoverMixRelativeToView:sender];
        }
    }
}

#pragma mark -
#pragma mark - FLOPopoverDelegate
#pragma mark -
- (void)popoverDidShow:(NSResponder *)popover {
}

- (void)popoverDidClose:(NSResponder *)popover {
}

@end
