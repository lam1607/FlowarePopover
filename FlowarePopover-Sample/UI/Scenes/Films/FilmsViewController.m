//
//  FilmsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmsViewController.h"

#import "FilmRepository.h"
#import "FilmsPresenter.h"

#import "Film.h"

#import "FilmCellView.h"

#import "CollectionViewManager.h"

@interface FilmsViewController () <CollectionViewManagerProtocols>
{
    id<FilmRepositoryProtocols> _repository;
    id<FilmsPresenterProtocols> _presenter;
    
    CollectionViewManager *_collectionManager;
    
    NSSize _estimatedItemSize;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionView;

/// @property
///

@end

@implementation FilmsViewController

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
    _repository = [[FilmRepository alloc] init];
    _presenter = [[FilmsPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
    [_presenter setupProvider];
    [_presenter registerNotificationObservers];
    
    _estimatedItemSize = NSMakeSize(self.view.frame.size.width / 3, 230.0);
    
    _collectionManager = [[CollectionViewManager alloc] initWithCollectionView:self.collectionView source:self provider:[_presenter provider]];
}

#pragma mark - Setup UI

- (void)setupUI
{
    NSCollectionViewFlowLayout *flowLayout = [[NSCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = NSEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    self.collectionView.collectionViewLayout = flowLayout;
    
    self.collectionView.backgroundColors = @[[NSColor clearColor]];
    
    [self.collectionView setSelectable:YES];
    [self.collectionView setAllowsMultipleSelection:YES];
    [self.collectionView registerForDraggedTypes:[NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, (NSPasteboardType)kUTTypeFileURL, NSFilenamesPboardType, nil]];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
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

- (NSSize)sizeForItem:(Film *)item atIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool
    {
        CGFloat horizontalMargin = 30.0;
        CGFloat itemWidth = self.view.frame.size.width / 2 - horizontalMargin;
        CGFloat itemHeight = 230.0;
        NSSize itemSize = NSMakeSize(itemWidth, itemHeight);
        CGFloat nameHorizontalMargin = 50.0;
        NSTextField *lblName = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, itemWidth - nameHorizontalMargin, 17.0)];
        
        lblName.font = [NSFont systemFontOfSize:18.0 weight:NSFontWeightMedium];
        lblName.maximumNumberOfLines = 0;
        lblName.stringValue = item.name;
        
        CGFloat imageHeight = 150.0;
        CGFloat nameHeight = [Utils sizeOfControl:lblName].height;
        CGFloat verticalMargins = 65.0; // Take a look at FilmCellView.xib file
        
        itemHeight = imageHeight + nameHeight + verticalMargins;
        itemSize = NSMakeSize(itemWidth, itemHeight);
        
        return itemSize;
    }
}

#pragma mark - CollectionViewManagerProtocols UI

- (NSUserInterfaceItemIdentifier)collectionViewManager:(CollectionViewManager *)manager makeItemWithIdentifierForItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    return NSStringFromClass([FilmCellView class]);
}

- (NSEdgeInsets)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return NSEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

- (NSSize)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    if ([item isKindOfClass:[Film class]])
    {
        return [self sizeForItem:(Film *)item atIndexPath:indexPath];
    }
    
    return _estimatedItemSize;
}

#pragma mark - CollectionViewManagerProtocols Selection

- (NSSet<NSIndexPath *> *)collectionViewManager:(CollectionViewManager *)manager shouldSelectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    //    NSIndexPath *indexPath = [[indexPaths allObjects] lastObject];
    //
    //    if (indexPath && (indexPath.item % 2 == 0))
    //    {
    //        return [NSSet set];
    //    }
    
    return indexPaths;
}

- (NSSet<NSIndexPath *> *)collectionViewManager:(CollectionViewManager *)manager shouldDeselectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    return indexPaths;
}

- (void)collectionViewManager:(CollectionViewManager *)manager didSelectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    //    for (id item in items)
    //    {
    //        if ([item isKindOfClass:[Film class]] && (((Film *)item).trailerUrl != nil))
    //        {
    //            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:((Film *)item).trailerUrl]];
    //        }
    //        else
    //        {
    //            DLog(@"URL of item %@ is unavailable", item);
    //        }
    //    }
}

- (void)collectionViewManager:(CollectionViewManager *)manager didDeselectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
}

#pragma mark - CollectionViewManagerProtocols Drag/Drop

/**
 * Asks the delegate whether a drag operation involving the specified items can begin.
 */
- (BOOL)collectionViewManager:(CollectionViewManager *)manager canDragItems:(NSArray *)draggedItems atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event
{
    return YES;
}

/**
 * Asks the delegate whether a drag operation can place the data on the pasteboard.
 */
- (BOOL)collectionViewManager:(CollectionViewManager *)manager writeItems:(NSArray *)draggedItems atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toPasteboard:(NSPasteboard *)pasteboard
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:draggedItems];
    
    [pasteboard setData:data forType:(NSPasteboardType)kUTTypeData];
    
    return YES;
}

/**
 * Asks the delegate whether a drop operation is possible at the specified location.
 */
- (NSDragOperation)collectionViewManager:(CollectionViewManager *)manager validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(nullable id)item proposedIndexPath:(NSIndexPath * __nonnull * __nonnull)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    if (([draggingInfo draggingSource] != nil) && [[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])
    {
        id draggedObj = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:(NSPasteboardType)kUTTypeData]];
        
        if ([_presenter couldDropObject:draggedObj])
        {
            return NSDragOperationMove;
        }
    }
    
    return NSDragOperationNone;
}

/**
 * Asks the delegate to incorporate the dropped content into the collection view.
 */
- (BOOL)collectionViewManager:(CollectionViewManager *)manager acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(nullable id)item indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    NSPasteboard *pasteboard = [draggingInfo draggingPasteboard];
    
    if (([draggingInfo draggingSource] != nil) && [[pasteboard types] containsObject:(NSPasteboardType)kUTTypeData])
    {
        id draggedObj = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:(NSPasteboardType)kUTTypeData]];
        
        if ([_presenter couldDropObject:draggedObj])
        {
            if ([_presenter data].count > 0)
            {
                [_presenter dropObject:draggedObj forRow:indexPath.item target:item completion:^(BOOL finished) {
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

/**
 * Asks the delegate that a drag session is about to begin.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
}

/**
 * Asks the delegate that a drag session ended.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation
{
}

/**
 * Asks the delegate to update the dragging items during a drag operation.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
}

#pragma mark - FilmsViewProtocols implementation

- (void)reloadViewData
{
    [_collectionManager reloadData];
}

@end
