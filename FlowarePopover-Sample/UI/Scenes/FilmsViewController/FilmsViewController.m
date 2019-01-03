//
//  FilmsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmsViewController.h"

#import "CustomNSTableRowView.h"
#import "FilmCellView.h"

#import "FilmRepository.h"
#import "FilmsPresenter.h"

#import "Film.h"

@interface FilmsViewController () <NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout>

//
// IBOutlet
//
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionViewData;

//
// @property
//
@property (nonatomic, strong) FilmRepository *filmRepository;
@property (nonatomic, strong) FilmsPresenter *filmsPresenter;

@property (nonatomic, assign) NSSize estimatedItemSize;
@property (nonatomic, strong) NSCache *itemSizes;

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
    self.filmRepository = [[FilmRepository alloc] init];
    self.filmsPresenter = [[FilmsPresenter alloc] init];
    [self.filmsPresenter attachView:self repository:self.filmRepository];
    
    self.estimatedItemSize = NSMakeSize(self.view.frame.size.width / 3, 230.0);
    self.itemSizes = [[NSCache alloc] init];
}

#pragma mark - Setup UI

- (void)setupUI {
    NSCollectionViewFlowLayout *flowLayout = [[NSCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = NSEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    self.collectionViewData.collectionViewLayout = flowLayout;
    
    self.collectionViewData.backgroundColors = @[[NSColor clearColor]];
    [self.collectionViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([FilmCellView class]) bundle:nil] forItemWithIdentifier:NSStringFromClass([FilmCellView class])];
    self.collectionViewData.delegate = self;
    self.collectionViewData.dataSource = self;
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
    [self.filmsPresenter fetchData];
}

- (void)calculateSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat horizontalMargin = 30.0;
    CGFloat itemWidth = self.view.frame.size.width / 2 - horizontalMargin;
    CGFloat itemHeight = 230.0;
    NSSize itemSize = NSMakeSize(itemWidth, itemHeight);
    
    if ([[[self.filmsPresenter data] objectAtIndex:indexPath.item] isKindOfClass:[Film class]]) {
        Film *film = (Film *)[[self.filmsPresenter data] objectAtIndex:indexPath.item];
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
        
        [self.itemSizes setObject:[NSValue valueWithSize:itemSize] forKey:@(indexPath.item)];
    }
}

#pragma mark - NSCollectionViewDataSource, NSCollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filmsPresenter data].count;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.filmsPresenter data] count] > 0) {
        if ([self.itemSizes objectForKey:@(indexPath.item)] == nil) {
            [self calculateSizeForItemAtIndexPath:indexPath];
        }
        
        return [[self.itemSizes objectForKey:@(indexPath.item)] sizeValue];
    }
    
    return self.estimatedItemSize;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    FilmCellView *viewItem = [collectionView makeItemWithIdentifier:NSStringFromClass([FilmCellView class]) forIndexPath:indexPath];
    
    if ([[[self.filmsPresenter data] objectAtIndex:indexPath.item] isKindOfClass:[Film class]]) {
        [viewItem updateUIWithData:(Film *)[[self.filmsPresenter data] objectAtIndex:indexPath.item]];
    }
    
    return viewItem;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    DLog(@"");
}

#pragma mark - FilmsViewProtocols implementation

- (void)reloadViewData {
    [self.collectionViewData reloadData];
}

@end
