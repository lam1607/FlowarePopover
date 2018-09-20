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

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet CustomNSOutlineView *outlineViewData;

@property (nonatomic, strong) ComicRepository *_comicRepository;
@property (nonatomic, strong) DataPresenter *_dataPresenter;

@property (nonatomic, strong) NSCache *_heights;

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

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._comicRepository = [[ComicRepository alloc] init];
    self._dataPresenter = [[DataPresenter alloc] init];
    [self._dataPresenter attachView:self repository:self._comicRepository];
    
    self._heights = [[NSCache alloc] init];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    //    [self setBackgroundColor:[NSColor clearColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.view];
    [self setBackgroundColor:[NSColor clearColor] forView:self.view];
    
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineViewData tableColumnWithIdentifier:@"DataCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineViewData.backgroundColor = [NSColor clearColor];
    self.outlineViewData.rowHeight = 269.0f;
    [self.outlineViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([DataCellView class]) bundle:nil] forIdentifier:NSStringFromClass([DataCellView class])];
    self.outlineViewData.pdelegate = self;
    self.outlineViewData.delegate = self;
    self.outlineViewData.dataSource = self;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)loadData {
    [self._dataPresenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.outlineViewData selectedRow] != -1) {
        [self.outlineViewData deselectRow:[self.outlineViewData selectedRow]];
    }
}

#pragma mark -
#pragma mark - CustomNSOutlineViewDelegate
#pragma mark -
- (void)outlineView:(CustomNSOutlineView *)outlineView didSelectRow:(NSInteger)row {
    if (row < [self._dataPresenter comics].count) {
        Comic *selected = [[self._dataPresenter comics] objectAtIndex:row];
        
        [[NSWorkspace sharedWorkspace] openURL:selected.pageUrl];
    }
}

#pragma mark -
#pragma mark - NSOutlineViewDelegate, NSOutlineViewDataSource
#pragma mark -
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [self._dataPresenter comics].count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil) ? [[self._dataPresenter comics] objectAtIndex:index] : nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    NSInteger row = [outlineView rowForItem:item];
    
    if ([self._heights objectForKey:@(row)] && [[self._heights objectForKey:@(row)] isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *) [self._heights objectForKey:@(row)]) doubleValue];
    }
    
    return 269.0f;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    NSView *view = [outlineView viewAtColumn:0 row:row makeIfNecessary:NO];
    
    if ([view isKindOfClass:[DataCellView class]]) {
        DataCellView *cellView = (DataCellView *) view;
        
        if (![self._heights objectForKey:@(row)]) {
            CGFloat cellHeight = [cellView getCellHeight];
            [self._heights setObject:@(cellHeight) forKey:@(row)];
            
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
    DataCellView *cellView = (DataCellView *) [outlineView makeViewWithIdentifier:NSStringFromClass([DataCellView class]) owner:self];
    [cellView updateUIWithData:(Comic *) item];
    
    return cellView;
}

#pragma mark -
#pragma mark - DataViewProtocols implementation
#pragma mark -
- (void)reloadDataOutlineView {
    [self.outlineViewData reloadData];
}

@end
