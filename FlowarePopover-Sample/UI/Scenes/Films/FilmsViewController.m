//
//  FilmsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmsViewController.h"

#import "FilmCellView.h"

#import "CollectionViewManager.h"

#import "CollectionViewRow.h"

#import "FilmRepository.h"
#import "FilmsPresenter.h"

#import "Film.h"

@interface FilmsViewController () <CollectionViewManagerProtocols>

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionView;

/// @property
///
@property (nonatomic, strong) FilmRepository *repository;
@property (nonatomic, strong) FilmsPresenter *presenter;

@property (nonatomic, assign) NSSize estimatedItemSize;

@property (nonatomic, strong) CollectionViewManager *collectionManager;

@end

@implementation FilmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupUI];
    [self loadData];
}

#pragma mark - Initialize

- (void)initialize {
    self.repository = [[FilmRepository alloc] init];
    self.presenter = [[FilmsPresenter alloc] init];
    [self.presenter attachView:self repository:self.repository];
    
    self.estimatedItemSize = NSMakeSize(self.view.frame.size.width / 3, 230.0);
    
    self.collectionManager = [[CollectionViewManager alloc] initWithCollectionView:self.collectionView];
    self.collectionManager.protocols = self;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSCollectionViewFlowLayout *flowLayout = [[NSCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = NSEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    self.collectionView.collectionViewLayout = flowLayout;
    
    self.collectionView.backgroundColors = @[[NSColor clearColor]];
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

#pragma mark - Local methods

- (void)loadData {
    [self.presenter fetchData];
}

- (NSSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat horizontalMargin = 30.0;
    CGFloat itemWidth = self.view.frame.size.width / 2 - horizontalMargin;
    CGFloat itemHeight = 230.0;
    NSSize itemSize = NSMakeSize(itemWidth, itemHeight);
    
    if ([[[self.presenter data] objectAtIndex:indexPath.item] isKindOfClass:[Film class]]) {
        @autoreleasepool {
            Film *film = (Film *)[[self.presenter data] objectAtIndex:indexPath.item];
            CGFloat nameHorizontalMargin = 50.0;
            NSTextField *lblName = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, itemWidth - nameHorizontalMargin, 17.0)];
            
            lblName.font = [NSFont systemFontOfSize:18.0 weight:NSFontWeightMedium];
            lblName.maximumNumberOfLines = 0;
            lblName.stringValue = film.name;
            
            CGFloat imageHeight = 150.0;
            CGFloat nameHeight = [Utils sizeOfControl:lblName].height;
            CGFloat verticalMargins = 65.0; // Take a look at FilmCellView.xib file
            
            itemHeight = imageHeight + nameHeight + verticalMargins;
            itemSize = NSMakeSize(itemWidth, itemHeight);
        }
    }
    
    return itemSize;
}

#pragma mark - CollectionViewManagerProtocols implementation

- (NSSize)collectionViewManager:(CollectionViewManager *)manager sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self sizeForItemAtIndexPath:indexPath];
}

- (void)collectionViewManager:(CollectionViewManager *)manager didSelectItems:(NSArray<id<CollectionViewRowProtocols>> *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    if (manager == self.collectionManager) {
        for (id<CollectionViewRowProtocols>item in items) {
            if ([item.data isKindOfClass:[Film class]] && (((Film *)item.data).trailerUrl != nil)) {
                [[NSWorkspace sharedWorkspace] openURL:((Film *)item.data).trailerUrl];
            } else {
                DLog(@"URL of item %@ is unavailable", item.data);
            }
        }
    }
}

#pragma mark - FilmsViewProtocols implementation

- (void)reloadViewData {
    for (AbstractData *obj in [self.presenter data]) {
        if ([obj isKindOfClass:[Film class]]) {
            @autoreleasepool {
                CollectionViewRow *row = [[CollectionViewRow alloc] initWithIdentifier:NSStringFromClass([FilmCellView class]) data:(Film *)obj];
                
                row.estimatedItemSize = self.estimatedItemSize;
                
                [self.collectionManager addRow:row];
            }
        }
    }
    
    [self.collectionManager reloadData];
}

@end
