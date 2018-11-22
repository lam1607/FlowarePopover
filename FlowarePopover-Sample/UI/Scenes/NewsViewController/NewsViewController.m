//
//  NewsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsViewController.h"

#import "CustomNSTableRowView.h"
#import "NewsCellView.h"

#import "News.h"

@interface NewsViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableViewData;

@property (nonatomic, strong) NewsRepository *newsRepository;
@property (nonatomic, strong) NewsPresenter *newsPresenter;

@property (nonatomic, strong) NSCache *heights;

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
    self.newsRepository = [[NewsRepository alloc] init];
    self.newsPresenter = [[NewsPresenter alloc] init];
    [self.newsPresenter attachView:self repository:self.newsRepository];
    
    self.heights = [[NSCache alloc] init];
}

#pragma mark - Setup UI

- (void)setupUI {
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.tableViewData tableColumnWithIdentifier:@"NewsCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.tableViewData.backgroundColor = [NSColor clearColor];
    self.tableViewData.rowHeight = 254.0;
    [self.tableViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([NewsCellView class]) bundle:nil] forIdentifier:NSStringFromClass([NewsCellView class])];
    self.tableViewData.delegate = self;
    self.tableViewData.dataSource = self;
}

#pragma mark - Processes

- (void)loadData {
    [self.newsPresenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.tableViewData selectedRow] != -1) {
        [self.tableViewData deselectRow:[self.tableViewData selectedRow]];
    }
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.newsPresenter data].count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self.heights objectForKey:@(row)] && [[self.heights objectForKey:@(row)] isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)[self.heights objectForKey:@(row)]) doubleValue];
    }
    
    return 254.0;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    NSView *view = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    
    if ([view isKindOfClass:[NewsCellView class]]) {
        NewsCellView *cellView = (NewsCellView *)view;
        
        if (![self.heights objectForKey:@(row)]) {
            CGFloat cellHeight = [cellView getCellHeight];
            [self.heights setObject:@(cellHeight) forKey:@(row)];
            
            // Notify to the NSTableView reloads cell height
            [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
        }
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    NSRect frm = NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CustomNSTableRowView *rowView = [[CustomNSTableRowView alloc] initWithFrame:frm];
    rowView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    [rowView setEmphasized:NO];
    
    return rowView;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NewsCellView *cellView = (NewsCellView *)[tableView makeViewWithIdentifier:NSStringFromClass([NewsCellView class]) owner:self];
    [cellView updateUIWithData:[[self.newsPresenter data] objectAtIndex:row]];
    
    return cellView;
}

#pragma mark - NewsViewProtocols implementation

- (void)reloadDataTableView {
    [self.tableViewData reloadData];
}

@end
