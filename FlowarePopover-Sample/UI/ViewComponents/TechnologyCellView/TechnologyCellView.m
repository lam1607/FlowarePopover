//
//  TechnologyCellView.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologyCellView.h"

#import "TechnologyRepository.h"
#import "TechnologyCellPresenter.h"

#import "Technology.h"

@interface TechnologyCellView ()
{
    id<TechnologyRepositoryProtocols> _repository;
    id<TechnologyCellPresenterProtocols> _presenter;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblTitle;
@property (weak) IBOutlet NSTextField *lblShortDesc;

/// @property
///

@end

@implementation TechnologyCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self objectsInitialize];
    [self setupUI];
    [self refreshUIAppearance];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _repository = [[TechnologyRepository alloc] init];
    _presenter = [[TechnologyCellPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.imgView.imageScaling = NSImageScaleProportionallyDown;
    self.lblTitle.maximumNumberOfLines = 0;
    self.lblShortDesc.maximumNumberOfLines = 0;
}

#pragma mark - Local methods

- (CGFloat)getCellHeight
{
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat titleHeight = [Utils sizeOfControl:self.lblTitle].height;
    CGFloat descHeight = [Utils sizeOfControl:self.lblShortDesc].height;
    CGFloat verticalMargins = 75.0; // Take a look at DataCellView.xib file
    
    return imageHeight + titleHeight + descHeight + verticalMargins;
}

#pragma mark - ItemCellViewProtocols implementation

- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndex:(NSInteger)index
{
    if ([data isKindOfClass:[Technology class]])
    {
        Technology *technology = (Technology *)data;
        
        [_presenter fetchImageFromData:technology];
        
        self.lblTitle.stringValue = technology.name;
        self.lblShortDesc.stringValue = technology.shortDesc;
    }
}

#pragma mark - TechnologyCellViewProtocols implementation

- (void)refreshUIAppearance
{
    [Utils setShadowForView:self.vContainer];
    
    [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor blueColor] forView:self.vContainer];
    
    [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
    
    [Utils setTitle:self.lblTitle.stringValue color:[NSColor textBlackColor] fontSize:16.0 forControl:self.lblTitle];
    [Utils setTitle:self.lblShortDesc.stringValue color:[NSColor textGrayColor] fontSize:14.0 forControl:self.lblShortDesc];
}

- (void)updateViewImage
{
    if ([_presenter fetchedImage])
    {
        self.imgView.image = [_presenter fetchedImage];
    }
}

@end
