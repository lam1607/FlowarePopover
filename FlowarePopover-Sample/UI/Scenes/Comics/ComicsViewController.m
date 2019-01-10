//
//  ComicsViewController.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicsViewController.h"

#import "ComicCellView.h"

#import "OutlineViewManager.h"

#import "OutlineViewRow.h"

#import "ComicRepository.h"
#import "ComicsPresenter.h"

#import "Comic.h"

@interface ComicsViewController () <OutlineViewManagerProtocols>

/// IBOutlet
///
@property (weak) IBOutlet NSView *vHeader;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSOutlineView *outlineView;

/// @property
///
@property (nonatomic, strong) ComicRepository *repository;
@property (nonatomic, strong) ComicsPresenter *presenter;

@property (nonatomic, strong) OutlineViewManager *outlineManager;

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
    self.repository = [[ComicRepository alloc] init];
    self.presenter = [[ComicsPresenter alloc] init];
    [self.presenter attachView:self repository:self.repository];
    
    self.outlineManager = [[OutlineViewManager alloc] initWithOutlineView:self.outlineView];
    self.outlineManager.protocols = self;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSSize screenSize = [Utils screenSize];
    NSTableColumn *column = [self.outlineView tableColumnWithIdentifier:@"ComicCellViewColumn"];
    column.maxWidth = screenSize.width;
    
    self.outlineView.backgroundColor = [NSColor clearColor];
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

- (void)deSelectRowIfSelected {
    if ([self.outlineView selectedRow] != -1) {
        [self.outlineView deselectRow:[self.outlineView selectedRow]];
    }
}

- (CGFloat)getContentSizeHeight {
    NSInteger rows = self.outlineView.numberOfRows;
    
    return rows * 46.0 + self.vHeader.frame.size.height;
}

- (void)updateContentSize {
    CGFloat height = [self getContentSizeHeight];
    NSSize newSize = NSMakeSize(350.0, height);
    
    if (NSEqualSizes(self.view.frame.size, newSize) == NO) {
        [self.view setFrameSize:newSize];
        
        if (self.didContentSizeChange) {
            self.didContentSizeChange(newSize);
        }
    }
}

- (void)buildViewRowsWithData:(NSArray<AbstractData *> *)data parentRow:(OutlineViewRow *)parentRow {
    for (AbstractData *obj in data) {
        if ([obj isKindOfClass:[Comic class]]) {
            @autoreleasepool {
                Comic *comic = (Comic *)obj;
                
                OutlineViewRow *row = [[OutlineViewRow alloc] initWithIdentifier:NSStringFromClass([ComicCellView class]) data:comic];
                
                row.rowHeight = 44.0;
                
                if (parentRow == nil) {
                    [self.outlineManager addRow:row];
                } else {
                    [parentRow.childRows addObject:row];
                }
                
                if (comic.childItems.count > 0) {
                    [self buildViewRowsWithData:comic.childItems parentRow:row];
                }
            }
        }
    }
}

#pragma mark - OutlineViewManagerProtocols

- (void)outlineViewManager:(OutlineViewManager *)manager didSelectRow:(id<OutlineViewRowProtocols>)rowView atIndex:(NSInteger)index {
    if ((manager == self.outlineManager) && [rowView.data isKindOfClass:[Comic class]]) {
        [[NSWorkspace sharedWorkspace] openURL:((Comic *)rowView.data).pageUrl];
    }
}

- (void)outlineViewManager:(OutlineViewManager *)manager itemDidExpand:(NSNotification *)notification {
    [self updateContentSize];
}

- (void)outlineViewManager:(OutlineViewManager *)manager itemDidCollapse:(NSNotification *)notification {
    [self updateContentSize];
}

#pragma mark - ComicsViewProtocols implementation

- (void)reloadViewData {
    [self buildViewRowsWithData:[self.presenter data] parentRow:nil];
    [self.outlineManager reloadData];
    
    [self updateContentSize];
}

@end
