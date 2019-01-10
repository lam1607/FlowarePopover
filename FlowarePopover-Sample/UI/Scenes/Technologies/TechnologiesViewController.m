//
//  TechnologiesViewController.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologiesViewController.h"

#import "TechnologyCellView.h"

#import "OutlineViewManager.h"

#import "OutlineViewRow.h"

#import "TechnologyRepository.h"
#import "TechnologiesPresenter.h"

#import "Technology.h"

@interface TechnologiesViewController () <OutlineViewManagerProtocols>

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSOutlineView *outlineView;

/// @property
///
@property (nonatomic, strong) TechnologyRepository *repository;
@property (nonatomic, strong) TechnologiesPresenter *presenter;

@property (nonatomic, strong) OutlineViewManager *outlineManager;

@end

@implementation TechnologiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupUI];
    [self loadData];
}

- (void)viewWillAppear {
    [super viewWillAppear];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self deSelectRowIfSelected];
}

#pragma mark - Initialize

- (void)initialize {
    self.repository = [[TechnologyRepository alloc] init];
    self.presenter = [[TechnologiesPresenter alloc] init];
    [self.presenter attachView:self repository:self.repository];
    
    self.outlineManager = [[OutlineViewManager alloc] initWithOutlineView:self.outlineView];
    self.outlineManager.protocols = self;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineView tableColumnWithIdentifier:@"TechnologyCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineView.backgroundColor = [NSColor clearColor];
    self.outlineView.rowHeight = 269.0;
}

- (void)refreshUIColors {
    [super refreshUIColors];
    
    if ([self.view.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name]) {
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _tealColor] forView:self.vHeader];
#else
        [Utils setBackgroundColor:[NSColor tealColor] forView:self.vHeader];
#endif
    }
}

#pragma mark - Processes

- (void)loadData {
    [self.presenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.outlineView selectedRow] != -1) {
        [self.outlineView deselectRow:[self.outlineView selectedRow]];
    }
}

#pragma mark - OutlineViewManagerProtocols

- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightForRow:(id<OutlineViewRowProtocols>)rowView atIndex:(NSInteger)index {
    if ((manager == self.outlineManager) && [rowView.view isKindOfClass:[TechnologyCellView class]]) {
        CGFloat rowHeight = [(TechnologyCellView *)rowView.view getCellHeight];
        
        return rowHeight;
    }
    
    return 254.0;
}

- (void)outlineViewManager:(OutlineViewManager *)manager didSelectRow:(id<OutlineViewRowProtocols>)rowView atIndex:(NSInteger)index {
    if ((manager == self.outlineManager) && [rowView.data isKindOfClass:[Technology class]]) {
        [[NSWorkspace sharedWorkspace] openURL:((Technology *)rowView.data).pageUrl];
    }
}

#pragma mark - TechnologiesViewProtocols implementation

- (void)reloadViewData {
    for (AbstractData *obj in [self.presenter data]) {
        if ([obj isKindOfClass:[Technology class]]) {
            @autoreleasepool {
                OutlineViewRow *row = [[OutlineViewRow alloc] initWithIdentifier:NSStringFromClass([TechnologyCellView class]) data:(Technology *)obj];
                
                row.rowHeight = 269.0;
                
                [self.outlineManager addRow:row];
            }
        }
    }
    
    [self.outlineManager reloadData];
}

@end
