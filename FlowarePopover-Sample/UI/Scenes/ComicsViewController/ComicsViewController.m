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

@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet CustomNSOutlineView *outlineViewData;

@property (nonatomic, strong) ComicRepository *comicRepository;
@property (nonatomic, strong) ComicsPresenter *comicsPresenter;

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

#pragma mark - Initialize

- (void)initialize {
    self.comicRepository = [[ComicRepository alloc] init];
    self.comicsPresenter = [[ComicsPresenter alloc] init];
    [self.comicsPresenter attachView:self repository:self.comicRepository];
}

#pragma mark - Setup UI

- (void)setupUI {
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineViewData tableColumnWithIdentifier:@"ComicCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineViewData.backgroundColor = [NSColor clearColor];
    [self.outlineViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([ComicCellView class]) bundle:nil] forIdentifier:NSStringFromClass([ComicCellView class])];
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
    [self.comicsPresenter fetchData];
}

- (void)deSelectRowIfSelected {
    if ([self.outlineViewData selectedRow] != -1) {
        [self.outlineViewData deselectRow:[self.outlineViewData selectedRow]];
    }
}

- (CGFloat)getContentSizeHeight {
    NSInteger rows = self.outlineViewData.numberOfRows;
    
    return rows * 46.0 + self.vHeader.frame.size.height;
}

#pragma mark - CustomNSOutlineViewDelegate

- (void)outlineView:(CustomNSOutlineView *)outlineView didSelectRow:(NSInteger)row {
    if (row < [self.comicsPresenter data].count) {
        Comic *selected = [[self.comicsPresenter data] objectAtIndex:row];
        
        [[NSWorkspace sharedWorkspace] openURL:selected.pageUrl];
    }
}

#pragma mark - NSOutlineViewDelegate, NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if ([item isKindOfClass:[Comic class]]) {
        return ((Comic *)item).subComics.count;
    }
    
    return [self.comicsPresenter data].count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if ([item isKindOfClass:[Comic class]]) {
        return [((Comic *)item).subComics objectAtIndex:index];
    }
    
    return [[self.comicsPresenter data] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[Comic class]]) {
        return ((Comic *)item).subComics.count > 0;
    }
    
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 44.0;
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
    ComicCellView *cellView = (ComicCellView *)[outlineView makeViewWithIdentifier:NSStringFromClass([ComicCellView class]) owner:self];
    [cellView updateUIWithData:(Comic *)item];
    
    return cellView;
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    if (self.didContentSizeChange) {
        CGFloat height = [self getContentSizeHeight];
        NSSize newSize = NSMakeSize(self.view.superview.frame.size.width, height);
        
        self.didContentSizeChange(newSize);
    }
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    if (self.didContentSizeChange) {
        CGFloat height = [self getContentSizeHeight];
        NSSize newSize = NSMakeSize(self.view.superview.frame.size.width, height);
        
        self.didContentSizeChange(newSize);
    }
}

#pragma mark - ComicsViewProtocols implementation

- (void)reloadDataOutlineView {
    [self.outlineViewData reloadData];
    
    if (self.didContentSizeChange) {
        CGFloat height = [self getContentSizeHeight];
        NSSize newSize = NSMakeSize(350.0, height);
        
        if (NSEqualSizes(self.view.frame.size, newSize) == NO) {
            self.didContentSizeChange(newSize);
        }
    }
}

@end
