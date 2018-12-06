//
//  DataViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "DataViewController.h"

#import "CustomNSOutlineView.h"
#import "CustomNSTableRowView.h"
#import "DataCellView.h"

#import "Comic.h"

@interface DataViewController () <NSOutlineViewDelegate, NSOutlineViewDataSource, CustomNSOutlineViewDelegate>

@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet CustomNSOutlineView *outlineViewData;

@property (nonatomic, strong) ComicRepository *comicRepository;
@property (nonatomic, strong) DataPresenter *dataPresenter;

@property (nonatomic, strong) NSCache *heights;

@end

@implementation DataViewController

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
    self.comicRepository = [[ComicRepository alloc] init];
    self.dataPresenter = [[DataPresenter alloc] init];
    [self.dataPresenter attachView:self repository:self.comicRepository];
    
    self.heights = [[NSCache alloc] init];
}

#pragma mark - Setup UI

- (void)setupUI {
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineViewData tableColumnWithIdentifier:@"DataCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineViewData.backgroundColor = [NSColor clearColor];
    self.outlineViewData.rowHeight = 269.0;
    [self.outlineViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([DataCellView class]) bundle:nil] forIdentifier:NSStringFromClass([DataCellView class])];
    self.outlineViewData.pdelegate = self;
    self.outlineViewData.delegate = self;
    self.outlineViewData.dataSource = self;
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
    [self.dataPresenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.outlineViewData selectedRow] != -1) {
        [self.outlineViewData deselectRow:[self.outlineViewData selectedRow]];
    }
}

#pragma mark - CustomNSOutlineViewDelegate

- (void)outlineView:(CustomNSOutlineView *)outlineView didSelectRow:(NSInteger)row {
    if (row < [self.dataPresenter data].count) {
        Comic *selected = [[self.dataPresenter data] objectAtIndex:row];
        
        [[NSWorkspace sharedWorkspace] openURL:selected.pageUrl];
    }
}

#pragma mark - NSOutlineViewDelegate, NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [self.dataPresenter data].count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil) ? [[self.dataPresenter data] objectAtIndex:index] : nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    NSInteger row = [outlineView rowForItem:item];
    
    if ([self.heights objectForKey:@(row)] && [[self.heights objectForKey:@(row)] isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)[self.heights objectForKey:@(row)]) doubleValue];
    }
    
    return 269.0;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    NSView *view = [outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
    
    if ([view isKindOfClass:[DataCellView class]]) {
        DataCellView *cellView = (DataCellView *)view;
        
        if (![self.heights objectForKey:@(row)]) {
            CGFloat cellHeight = [cellView getCellHeight];
            [self.heights setObject:@(cellHeight) forKey:@(row)];
            
            // Notify to the NSOutlineView reloads cell height
            [outlineView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    [cell setTransparent:YES];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    NSRect frm = NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CustomNSTableRowView *rowView = [[CustomNSTableRowView alloc] initWithFrame:frm];
    rowView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    [rowView setEmphasized:NO];
    
    return rowView;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
    DataCellView *cellView = (DataCellView *)[outlineView makeViewWithIdentifier:NSStringFromClass([DataCellView class]) owner:self];
    [cellView updateUIWithData:(Comic *)item];
    
    return cellView;
}

#pragma mark - DataViewProtocols implementation

- (void)reloadDataOutlineView {
    [self.outlineViewData reloadData];
}

@end
