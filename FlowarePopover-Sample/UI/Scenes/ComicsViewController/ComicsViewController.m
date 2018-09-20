//
//  ComicsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicsViewController.h"

#import "CustomNSOutlineView.h"
#import "CustomNSTableRowView.h"
#import "ComicCellView.h"

#import "Comic.h"

@interface ComicsViewController () <NSOutlineViewDelegate, NSOutlineViewDataSource, CustomNSOutlineViewDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet CustomNSOutlineView *outlineViewData;

@property (nonatomic, strong) ComicRepository *_comicRepository;
@property (nonatomic, strong) ComicsPresenter *_comicsPresenter;

@end

@implementation ComicsViewController

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
    self._comicsPresenter = [[ComicsPresenter alloc] init];
    [self._comicsPresenter attachView:self repository:self._comicRepository];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    //    [self setBackgroundColor:[NSColor clearColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.view];
    [self setBackgroundColor:[NSColor clearColor] forView:self.view];
    
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineViewData tableColumnWithIdentifier:@"ComicCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineViewData.backgroundColor = [NSColor clearColor];
    [self.outlineViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([ComicCellView class]) bundle:nil] forIdentifier:NSStringFromClass([ComicCellView class])];
    self.outlineViewData.pdelegate = self;
    self.outlineViewData.delegate = self;
    self.outlineViewData.dataSource = self;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)loadData {
    [self._comicsPresenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.outlineViewData selectedRow] != -1) {
        [self.outlineViewData deselectRow:[self.outlineViewData selectedRow]];
    }
}

- (CGFloat)getContentSizeHeight {
    NSInteger rows = self.outlineViewData.numberOfRows;
    
    return rows * 46.0f;
}

#pragma mark -
#pragma mark - CustomNSOutlineViewDelegate
#pragma mark -
- (void)outlineView:(CustomNSOutlineView *)outlineView didSelectRow:(NSInteger)row {
    //    if (row < [self._comicsPresenter comics].count) {
    //        Comic *selected = [[self._comicsPresenter comics] objectAtIndex:row];
    //
    //        [[NSWorkspace sharedWorkspace] openURL:selected.pageUrl];
    //    }
}

#pragma mark -
#pragma mark - NSOutlineViewDelegate, NSOutlineViewDataSource
#pragma mark -
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if ([item isKindOfClass:[Comic class]]) {
        return ((Comic *) item).subComics.count;
    }
    
    return [self._comicsPresenter comics].count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if ([item isKindOfClass:[Comic class]]) {
        return [((Comic *) item).subComics objectAtIndex:index];
    }
    
    return [[self._comicsPresenter comics] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[Comic class]]) {
        return ((Comic *) item).subComics.count > 0;
    }
    
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 44.0f;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    [cell setTransparent:YES];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return NO;
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
    ComicCellView *cellView = (ComicCellView *) [outlineView makeViewWithIdentifier:NSStringFromClass([ComicCellView class]) owner:self];
    [cellView updateUIWithData:(Comic *) item];
    
    return cellView;
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    if (self.didContentSizeChange) {
        self.didContentSizeChange();
    }
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    if (self.didContentSizeChange) {
        self.didContentSizeChange();
    }
}

#pragma mark -
#pragma mark - ComicsViewProtocols implementation
#pragma mark -
- (void)reloadDataOutlineView {
    [self.outlineViewData reloadData];
}

@end
