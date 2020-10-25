//
//  ComicsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicsViewController.h"

#import "ComicRepository.h"
#import "ComicsPresenter.h"

#import "Comic.h"

#import "TableRowView.h"
#import "ComicCellView.h"

#import "OutlineViewManager.h"

@interface ComicsViewController () <OutlineViewManagerProtocols>
{
    id<ComicRepositoryProtocols> _repository;
    id<ComicsPresenterProtocols> _presenter;
    
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

@implementation ComicsViewController

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
    _repository = [[ComicRepository alloc] init];
    _presenter = [[ComicsPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
    [_presenter setupProvider];
    [_presenter registerNotificationObservers];
    
    _outlineManager = [[OutlineViewManager alloc] initWithOutlineView:self.outlineView source:self provider:[_presenter provider]];
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineView tableColumnWithIdentifier:@"ComicCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineView.backgroundColor = [NSColor clearColor];
    
    [self.outlineView setAllowsMultipleSelection:YES];
    [self.outlineView registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, (NSPasteboardType)kUTTypeFileURL, NSFilenamesPboardType, nil]];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
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

- (CGFloat)getContentSizeHeight
{
    return 46.0 * self.outlineView.numberOfRows + self.vHeader.frame.size.height;
}

- (void)updateContentSize
{
    CGFloat height = [self getContentSizeHeight];
    NSSize newSize = NSMakeSize(COMICS_VIEW_DETAIL_WIDTH, height);
    
    if (!NSEqualSizes([self.view frame].size, newSize))
    {
        [self.view setFrameSize:newSize];
    }
}

#pragma mark - OutlineViewManagerProtocols UI

- (NSUserInterfaceItemIdentifier)outlineViewManager:(OutlineViewManager *)manager makeViewWithIdentifierForItem:(id)item
{
    return NSStringFromClass([ComicCellView class]);
}

- (NSTableRowView *)outlineViewManager:(OutlineViewManager *)manager rowViewForItem:(id)item
{
    if ([item isKindOfClass:[Comic class]])
    {
        TableRowView *rowView = [[TableRowView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        
        return rowView;
    }
    
    return nil;
}

- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightOfRowByItem:(id)item
{
    return 44.0;
}

#pragma mark - OutlineViewManagerProtocols Selection

- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldSelectItem:(id)item
{
    return YES;
}

- (void)outlineViewManager:(OutlineViewManager *)manager didSelectItem:(id)item forRow:(NSInteger)row
{
    //    if ([item isKindOfClass:[Comic class]])
    //    {
    //        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:((Comic *)item).pageUrl]];
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
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - OutlineViewManagerProtocols Notifications

- (void)outlineViewManager:(OutlineViewManager *)manager itemDidExpand:(NSNotification *)notification
{
    [self updateContentSize];
}

- (void)outlineViewManager:(OutlineViewManager *)manager itemDidCollapse:(NSNotification *)notification
{
    [self updateContentSize];
}

#pragma mark - ComicsViewProtocols implementation

- (void)refreshUIAppearance
{
    [super refreshUIAppearance];
    
    [Utils setBackgroundColor:[NSColor tealColor] forView:self.vHeader];
}

- (void)reloadViewData
{
    [_outlineManager reloadData];
    
    [self updateContentSize];
}

@end
