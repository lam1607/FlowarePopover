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

#import "Film.h"

@interface FilmsViewController () <NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionViewData;

@property (nonatomic, strong) FilmRepository *_filmRepository;
@property (nonatomic, strong) FilmsPresenter *_filmsPresenter;

@property (nonatomic, assign) NSSize _estimatedItemSize;
@property (nonatomic, strong) NSCache *_itemSizes;

@end

@implementation FilmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupUI];
    [self loadData];
}

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._filmRepository = [[FilmRepository alloc] init];
    self._filmsPresenter = [[FilmsPresenter alloc] init];
    [self._filmsPresenter attachView:self repository:self._filmRepository];
    
    self._estimatedItemSize = NSMakeSize(self.view.frame.size.width / 3, 230.0f);
    self._itemSizes = [[NSCache alloc] init];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    //    [self setBackgroundColor:[NSColor clearColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.view];
    [self setBackgroundColor:[NSColor clearColor] forView:self.view];
    
    NSCollectionViewFlowLayout *flowLayout = [[NSCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.sectionInset = NSEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    self.collectionViewData.collectionViewLayout = flowLayout;
    
    self.collectionViewData.backgroundColors = @[[NSColor clearColor]];
    [self.collectionViewData registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([FilmCellView class]) bundle:nil] forItemWithIdentifier:NSStringFromClass([FilmCellView class])];
    self.collectionViewData.delegate = self;
    self.collectionViewData.dataSource = self;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)loadData {
    [self._filmsPresenter fetchData];
}

- (void)calculateSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat horizontalMargin = 30.0f;
    CGFloat itemWidth = self.view.frame.size.width / 2 - horizontalMargin;
    CGFloat itemHeight = 230.0f;
    NSSize itemSize = NSMakeSize(itemWidth, itemHeight);
    
    Film *film = [[self._filmsPresenter films] objectAtIndex:indexPath.item];
    CGFloat nameHorizontalMargin = 50.0f;
    NSTextField *lblName = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, itemWidth - nameHorizontalMargin, 17.0f)];
    
    lblName.font = [NSFont systemFontOfSize:18.0f weight:NSFontWeightMedium];
    lblName.textColor = [NSColor colorBlue];
    lblName.maximumNumberOfLines = 0;
    lblName.stringValue = film.name;
    
    CGFloat imageHeight = 150.0f;
    CGFloat nameHeight = [Utils sizeOfControl:lblName].height;
    CGFloat verticalMargins = 65.0f; // Take a look at FilmCellView.xib file
    
    itemHeight = imageHeight + nameHeight + verticalMargins;
    itemSize = NSMakeSize(itemWidth, itemHeight);
    
    [self._itemSizes setObject:[NSValue valueWithSize:itemSize] forKey:@(indexPath.item)];
}

#pragma mark -
#pragma mark - NSCollectionViewDataSource, NSCollectionViewDelegate
#pragma mark -
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self._filmsPresenter films].count;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self._filmsPresenter films] count] > 0) {
        if ([self._itemSizes objectForKey:@(indexPath.item)] == nil) {
            [self calculateSizeForItemAtIndexPath:indexPath];
        }
        
        return [[self._itemSizes objectForKey:@(indexPath.item)] sizeValue];
    }
    
    return self._estimatedItemSize;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    FilmCellView *viewItem = [collectionView makeItemWithIdentifier:NSStringFromClass([FilmCellView class]) forIndexPath:indexPath];
    [viewItem updateUIWithData:[[self._filmsPresenter films] objectAtIndex:indexPath.item]];
    
    return viewItem;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    DLog(@"");
}

#pragma mark -
#pragma mark - FilmsViewProtocols implementation
#pragma mark -
- (void)reloadDataCollectionView {
    [self.collectionViewData reloadData];
}

@end
