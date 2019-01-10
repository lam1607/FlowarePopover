//
//  NewsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsViewController.h"

#import "NewsCellView.h"

#import "TableViewManager.h"

#import "TableViewRow.h"

#import "NewsRepository.h"
#import "NewsPresenter.h"

#import "News.h"

@interface NewsViewController () <TableViewManagerProtocols>

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;

/// @property
///
@property (nonatomic, strong) NewsRepository *repository;
@property (nonatomic, strong) NewsPresenter *presenter;

@property (nonatomic, strong) TableViewManager *tableManager;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupUI];
    [self loadData];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self deSelectRowIfSelected];
}

#pragma mark - Initialize

- (void)initialize {
    self.repository = [[NewsRepository alloc] init];
    self.presenter = [[NewsPresenter alloc] init];
    [self.presenter attachView:self repository:self.repository];
    
    self.tableManager = [[TableViewManager alloc] initWithTableView:self.tableView];
    self.tableManager.protocols = self;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.tableView tableColumnWithIdentifier:@"NewsCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.tableView.backgroundColor = [NSColor clearColor];
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

#pragma mark - Local methods

- (void)loadData {
    [self.presenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.tableView selectedRow] != -1) {
        [self.tableView deselectRow:[self.tableView selectedRow]];
    }
}

#pragma mark - TableViewManagerProtocols implementation

- (CGFloat)tableViewManager:(TableViewManager *)manager heightForRow:(id<TableViewRowProtocols>)rowView atIndex:(NSInteger)index {
    if ((manager == self.tableManager) && [rowView.view isKindOfClass:[NewsCellView class]]) {
        CGFloat rowHeight = [(NewsCellView *)rowView.view getCellHeight];
        
        return rowHeight;
    }
    
    return 254.0;
}

- (void)tableViewManager:(TableViewManager *)manager didSelectRow:(id<TableViewRowProtocols>)rowView atIndex:(NSInteger)index {
    if ((manager == self.tableManager) && [rowView.data isKindOfClass:[News class]]) {
        [[NSWorkspace sharedWorkspace] openURL:((News *)rowView.data).pageUrl];
    }
}

#pragma mark - NewsViewProtocols implementation

- (void)reloadViewData {
    for (AbstractData *obj in [self.presenter data]) {
        if ([obj isKindOfClass:[News class]]) {
            @autoreleasepool {
                TableViewRow *row = [[TableViewRow alloc] initWithIdentifier:NSStringFromClass([NewsCellView class]) data:(News *)obj];
                
                row.rowHeight = 254.0;
                
                [self.tableManager addRow:row];
            }
        }
    }
    
    [self.tableManager reloadData];
}

@end
