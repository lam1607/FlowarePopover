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

@property (nonatomic, strong) NewsRepository *_newsRepository;
@property (nonatomic, strong) NewsPresenter *_newsPresenter;

@property (nonatomic, strong) NSCache *_heights;

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

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._newsRepository = [[NewsRepository alloc] init];
    self._newsPresenter = [[NewsPresenter alloc] init];
    [self._newsPresenter attachView:self repository:self._newsRepository];
    
    self._heights = [[NSCache alloc] init];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
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

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)loadData {
    [self._newsPresenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.tableViewData selectedRow] != -1) {
        [self.tableViewData deselectRow:[self.tableViewData selectedRow]];
    }
}

#pragma mark -
#pragma mark - NSTableViewDelegate, NSTableViewDataSource
#pragma mark -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self._newsPresenter news].count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self._heights objectForKey:@(row)] && [[self._heights objectForKey:@(row)] isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *) [self._heights objectForKey:@(row)]) doubleValue];
    }
    
    return 254.0;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    NSView *view = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    
    if ([view isKindOfClass:[NewsCellView class]]) {
        NewsCellView *cellView = (NewsCellView *) view;
        
        if (![self._heights objectForKey:@(row)]) {
            CGFloat cellHeight = [cellView getCellHeight];
            [self._heights setObject:@(cellHeight) forKey:@(row)];
            
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
    NewsCellView *cellView = (NewsCellView *) [tableView makeViewWithIdentifier:NSStringFromClass([NewsCellView class]) owner:self];
    [cellView updateUIWithData:[[self._newsPresenter news] objectAtIndex:row]];
    
    return cellView;
}

#pragma mark -
#pragma mark - NewsViewProtocols implementation
#pragma mark -
- (void)reloadDataTableView {
    [self.tableViewData reloadData];
}

@end
