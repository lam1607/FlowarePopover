//
//  NewsCellView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsCellView.h"

#import "NewsRepository.h"
#import "NewsCellPresenter.h"

#import "News.h"

@interface NewsCellView ()
{
    id<NewsRepositoryProtocols> _repository;
    id<NewsCellPresenterProtocols> _presenter;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblTitle;
@property (weak) IBOutlet NSTextField *lblContent;

/// @property
///

@end

@implementation NewsCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self objectsInitialize];
    [self setupUI];
}

- (void)layout
{
    [super layout];
    
    [self refreshUIColors];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _repository = [[NewsRepository alloc] init];
    _presenter = [[NewsCellPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.imgView.imageScaling = NSImageScaleProportionallyDown;
    self.lblTitle.maximumNumberOfLines = 0;
    self.lblContent.maximumNumberOfLines = 0;
}

- (void)refreshUIColors
{
    if ([self.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name])
    {
        [Utils setShadowForView:self.vContainer];
        
#ifdef kFlowarePopover_UseAssetColors
        [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor _blueColor] forView:self.vContainer];
        
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor _textBlackColor] fontSize:16.0 forControl:self.lblTitle];
        [Utils setTitle:self.lblContent.stringValue color:[NSColor _textGrayColor] fontSize:14.0 forControl:self.lblContent];
#else
        [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor blueColor] forView:self.vContainer];
        
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor textBlackColor] fontSize:16.0 forControl:self.lblTitle];
        [Utils setTitle:self.lblContent.stringValue color:[NSColor textGrayColor] fontSize:14.0 forControl:self.lblContent];
#endif
    }
}

#pragma mark - Public methods

- (CGFloat)getCellHeight
{
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat titleHeight = [Utils sizeOfControl:self.lblTitle].height;
    CGFloat contentHeight = [Utils sizeOfControl:self.lblContent].height;
    CGFloat verticalMargins = 75.0; // Take a look at NewsCellView.xib file
    
    return imageHeight + titleHeight + contentHeight + verticalMargins;
}

#pragma mark - ItemCellViewProtocols implementation

- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndex:(NSInteger)index
{
    if ([data isKindOfClass:[News class]])
    {
        News *news = (News *)data;
        
        [_presenter fetchImageFromData:news];
        
        self.lblTitle.stringValue = news.title;
        self.lblContent.stringValue = news.content;
    }
}

#pragma mark - NewsCellViewProtocols implementation

- (void)updateViewImage
{
    if ([_presenter fetchedImage])
    {
        self.imgView.image = [_presenter fetchedImage];
    }
}

@end
