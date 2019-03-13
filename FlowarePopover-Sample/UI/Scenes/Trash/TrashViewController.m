//
//  TrashViewController.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TrashViewController.h"

#import "TrashPresenter.h"

#import "AbstractData.h"

#import "TrashCellView.h"

#import "TableViewManager.h"

@interface TrashViewController () <TableViewManagerProtocols>
{
    TrashPresenter *_presenter;
    
    TableViewManager *_tableManager;
}

/// IBOutlet
///
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;

/// @property
///

@end

@implementation TrashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self objectsInitialize];
    [self setupUI];
    [self loadData];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _presenter = [[TrashPresenter alloc] init];
    [_presenter attachView:self];
    [_presenter setupProvider];
    [_presenter registerNotificationObservers];
    
    _tableManager = [[TableViewManager alloc] initWithTableView:self.tableView source:self provider:[_presenter provider]];
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.tableView tableColumnWithIdentifier:@"TrashCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.tableView.backgroundColor = [NSColor clearColor];
    
    [self.tableView setAllowsMultipleSelection:NO];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, nil]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
}

#pragma mark - Local methods

- (void)loadData
{
    [_presenter fetchData];
}

#pragma mark - TableViewManagerProtocols implementation

- (NSUserInterfaceItemIdentifier)tableViewManager:(TableViewManager *)manager makeViewWithIdentifierForRow:(NSInteger)row byItem:(id)item
{
    return NSStringFromClass([TrashCellView class]);
}

- (CGFloat)tableViewManager:(TableViewManager *)manager heightOfRow:(NSInteger)row byItem:(id)item
{
    return 60.0;
}

- (CGFloat)tableViewManager:(TableViewManager *)manager heightOfView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item
{
    return 60.0;
}

/**
 * Asks the delegate if the user is allowed to change the selection.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager selectionShouldChangeInTableView:(NSTableView *)tableView
{
    return NO;
}

#pragma mark - TableViewManagerProtocols Drag/Drop

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
                [_presenter trashObject:draggedObj forRow:row notify:YES];
            }
            else
            {
                [_presenter trashObject:draggedObj notify:YES];
            }
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - TrashViewProtocols implementation

- (void)reloadViewData
{
    [_tableManager reloadData];
}

@end
