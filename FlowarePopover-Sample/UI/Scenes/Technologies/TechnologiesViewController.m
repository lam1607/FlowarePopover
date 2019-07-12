//
//  TechnologiesViewController.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologiesViewController.h"

#import "TechnologyRepository.h"
#import "TechnologiesPresenter.h"

#import "Technology.h"

#import "TableRowView.h"
#import "TechnologyCellView.h"

#import "OutlineViewManager.h"

@interface TechnologiesViewController () <OutlineViewManagerProtocols>
{
    TechnologyRepository *_repository;
    TechnologiesPresenter *_presenter;
    
    OutlineViewManager *_outlineManager;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSOutlineView *outlineView;

/// @property
///

@end

@implementation TechnologiesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self objectsInitialize];
    [self setupUI];
    [self loadData];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
    
    [self deSelectRowIfSelected];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _repository = [[TechnologyRepository alloc] init];
    _presenter = [[TechnologiesPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
    [_presenter setupProvider];
    [_presenter registerNotificationObservers];
    
    _outlineManager = [[OutlineViewManager alloc] initWithOutlineView:self.outlineView source:self provider:[_presenter provider]];
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineView tableColumnWithIdentifier:@"TechnologyCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineView.backgroundColor = [NSColor clearColor];
    self.outlineView.rowHeight = 269.0;
    
    [self.outlineView setAllowsMultipleSelection:YES];
    [self.outlineView registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, (NSPasteboardType)kUTTypeFileURL, NSFilenamesPboardType, nil]];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

- (void)refreshUIColors
{
    [super refreshUIColors];
    
    if ([self.view.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name])
    {
#ifdef kFlowarePopover_UseAssetColors
        [Utils setBackgroundColor:[NSColor _tealColor] forView:self.vHeader];
#else
        [Utils setBackgroundColor:[NSColor tealColor] forView:self.vHeader];
#endif
    }
}

#pragma mark - Local methods

- (void)loadData
{
    [_presenter fetchData];
}

- (void)deSelectRowIfSelected
{
    if ([self.outlineView selectedRow] != -1)
    {
        [self.outlineView deselectRow:[self.outlineView selectedRow]];
    }
}

#pragma mark - OutlineViewManagerProtocols UI

- (NSUserInterfaceItemIdentifier)outlineViewManager:(OutlineViewManager *)manager makeViewWithIdentifierForItem:(id)item
{
    return NSStringFromClass([TechnologyCellView class]);
}

- (NSTableRowView *)outlineViewManager:(OutlineViewManager *)manager rowViewForItem:(id)item
{
    if ([item isKindOfClass:[Technology class]])
    {
        TableRowView *rowView = [[TableRowView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        
        return rowView;
    }
    
    return nil;
}

- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightOfRowByItem:(id)item
{
    return 269.0;
}

- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightOfView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item
{
    if ([view isKindOfClass:[TechnologyCellView class]])
    {
        return [(TechnologyCellView *)view getCellHeight];
    }
    
    return 269.0;
}

#pragma mark - OutlineViewManagerProtocols Selection

- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldSelectItem:(id)item
{
    return YES;
}

- (void)outlineViewManager:(OutlineViewManager *)manager didSelectItem:(id)item forRow:(NSInteger)row
{
    //    if ([item isKindOfClass:[Technology class]])
    //    {
    //        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:((Technology *)item).pageUrl]];
    //    }
}

#pragma mark - OutlineViewManagerProtocols Drag/Drop

/**
 * Tells the delegate that a dragging session will begin.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems
{
}

/**
 * Tells the delegate that a dragging session has ended.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
}

/**
 * Returns a Boolean value that indicates whether a drag operation is allowed.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
    
    [pasteboard setData:data forType:(NSPasteboardType)kUTTypeData];
    
    return YES;
}

/**
 * Tells the delegate to enable the table to update dragging items as they are dragged over the view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
}

/**
 * Used by an outline view to determine a valid drop target.
 */
- (NSDragOperation)outlineViewManager:(OutlineViewManager *)manager validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(nullable id)item proposedChildIndex:(NSInteger)index
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    if (([draggingInfo draggingSource] != nil) && [[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])
    {
        id draggedObj = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:(NSPasteboardType)kUTTypeData]];
        
        if ([_presenter couldDropObject:draggedObj])
        {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

/**
 * Returns a Boolean value that indicates whether a drop operation was successful.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(nullable id)item childIndex:(NSInteger)index
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    if (([draggingInfo draggingSource] != nil) && [[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])
    {
        id draggedObj = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:(NSPasteboardType)kUTTypeData]];
        
        if ([_presenter couldDropObject:draggedObj])
        {
            if ([_presenter data].count > 0)
            {
                [_presenter dropObject:draggedObj forRow:index target:item completion:^(BOOL finished) {
                    if (finished)
                    {
                    }
                }];
                
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - TechnologiesViewProtocols implementation

- (void)reloadViewData
{
    [_outlineManager reloadData];
}

@end
