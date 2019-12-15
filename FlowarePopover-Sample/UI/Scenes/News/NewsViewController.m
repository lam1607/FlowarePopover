//
//  NewsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsViewController.h"

#import "NewsRepository.h"
#import "NewsPresenter.h"

#import "News.h"

#import "TableRowView.h"
#import "NewsCellView.h"

#import "TableViewManager.h"

@interface NewsViewController () <TableViewManagerProtocols>
{
    id<NewsRepositoryProtocols> _repository;
    id<NewsPresenterProtocols> _presenter;
    
    TableViewManager *_tableManager;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;

/// @property
///

@end

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self objectsInitialize];
    [self setupUI];
    [self loadData];
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
    
    [self deSelectRowIfSelected];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _repository = [[NewsRepository alloc] init];
    _presenter = [[NewsPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
    [_presenter setupProvider];
    [_presenter registerNotificationObservers];
    
    _tableManager = [[TableViewManager alloc] initWithTableView:self.tableView source:self provider:[_presenter provider]];
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.tableView tableColumnWithIdentifier:@"NewsCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.tableView.backgroundColor = [NSColor clearColor];
    [self.tableView setAllowsMultipleSelection:YES];
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, (NSPasteboardType)kUTTypeFileURL, NSFilenamesPboardType, nil]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

#pragma mark - Local methods

- (void)loadData
{
    [_presenter fetchData];
}

- (void)deSelectRowIfSelected
{
    if ([self.tableView selectedRow] != -1)
    {
        [self.tableView deselectRow:[self.tableView selectedRow]];
    }
}

#pragma mark - TableViewManagerProtocols UI

- (NSUserInterfaceItemIdentifier)tableViewManager:(TableViewManager *)manager makeViewWithIdentifierForRow:(NSInteger)row byItem:(id)item
{
    return NSStringFromClass([NewsCellView class]);
}

- (NSTableRowView *)tableViewManager:(TableViewManager *)manager rowViewForRow:(NSInteger)row byItem:(id)item
{
    if ([item isKindOfClass:[News class]])
    {
        TableRowView *rowView = [[TableRowView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        
        return rowView;
    }
    
    return nil;
}

- (CGFloat)tableViewManager:(TableViewManager *)manager heightOfRow:(NSInteger)row byItem:(id)item
{
    return 254.0;
}

- (CGFloat)tableViewManager:(TableViewManager *)manager heightOfView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item
{
    if ([view isKindOfClass:[NewsCellView class]])
    {
        return [(NewsCellView *)view getCellHeight];
    }
    
    return 254.0;
}

#pragma mark - TableViewManagerProtocols Selection

- (BOOL)tableViewManager:(TableViewManager *)manager shouldSelectRow:(NSInteger)row byItem:(id)item
{
    //    if ((row + 1) % 2 == 0)
    //    {
    //        return NO;
    //    }
    
    return YES;
}

- (void)tableViewManager:(TableViewManager *)manager didSelectItem:(id)item forRow:(NSInteger)row
{
    //    if ([item isKindOfClass:[News class]])
    //    {
    //        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:((News *)item).pageUrl]];
    //    }
}

#pragma mark - TableViewManagerProtocols Drag/Drop

/**
 * Tells the delegate that a dragging session will begin.
 */
- (void)tableViewManager:(TableViewManager *)manager draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes items:(NSArray *)items
{
}

/**
 * Tells the delegate that a dragging session has ended.
 */
- (void)tableViewManager:(TableViewManager *)manager draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
}

/**
 * Tells the delegate to allow the table to update dragging items as they are dragged over a view.
 */
- (void)tableViewManager:(TableViewManager *)manager updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
}

/**
 * Returns a Boolean value that indicates whether a drag operation is allowed.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager writeRowsWithIndexes:(NSIndexSet *)rowIndexes items:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
    
    [pasteboard setData:data forType:(NSPasteboardType)kUTTypeData];
    
    return YES;
}

/**
 * Ask the delegate for a valid drop target.
 */
- (NSDragOperation)tableViewManager:(TableViewManager *)manager validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(nullable id)item proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
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
 * This method is called when the mouse is released over an NSTableView that previously decided to allow a drop via the validateDrop method.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(nullable id)item row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    if (([draggingInfo draggingSource] != nil) && [[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])
    {
        id draggedObj = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:(NSPasteboardType)kUTTypeData]];
        
        if ([_presenter couldDropObject:draggedObj])
        {
            if ([_presenter data].count > 0)
            {
                [_presenter dropObject:draggedObj forRow:row target:item completion:^(BOOL finished) {
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

#pragma mark - NewsViewProtocols implementation

- (void)refreshUIAppearance
{
    [super refreshUIAppearance];
    
    [Utils setBackgroundColor:[NSColor tealColor] forView:self.vHeader];
}

- (void)reloadViewData
{
    [_tableManager reloadData];
}

@end
