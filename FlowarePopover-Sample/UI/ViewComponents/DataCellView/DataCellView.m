//
//  DataCellView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "DataCellView.h"

#import "Comic.h"

@interface DataCellView ()

@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblTitle;
@property (weak) IBOutlet NSTextField *lblShortDesc;

@property (nonatomic, strong) ComicRepository *_comicRepository;
@property (nonatomic, strong) DataCellPresenter *_dataCellPresenter;

@end

@implementation DataCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
    [self setupUI];
}

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._comicRepository = [[ComicRepository alloc] init];
    self._dataCellPresenter = [[DataCellPresenter alloc] init];
    [self._dataCellPresenter attachView:self repository:self._comicRepository];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    self.vContainer.wantsLayer = YES;
    self.vContainer.layer.cornerRadius = [CORNER_RADIUSES[0] doubleValue];
    self.vContainer.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    [Utils setShadowForView:self.vContainer];
    
    self.imgView.wantsLayer = YES;
    self.imgView.layer.backgroundColor = [[NSColor colorUltraLightGray] CGColor];
    self.imgView.imageScaling = NSImageScaleProportionallyDown;
    self.imgView.layer.cornerRadius = [CORNER_RADIUSES[0] doubleValue];
    
    self.lblTitle.font = [NSFont systemFontOfSize:18.0f weight:NSFontWeightMedium];
    self.lblTitle.textColor = [NSColor colorBlue];
    self.lblTitle.maximumNumberOfLines = 0;
    
    self.lblShortDesc.font = [NSFont systemFontOfSize:14.0f weight:NSFontWeightRegular];
    self.lblShortDesc.textColor = [NSColor colorViolet];
    self.lblShortDesc.maximumNumberOfLines = 0;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (CGFloat)getCellHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat titleHeight = [Utils sizeOfControl:self.lblTitle].height;
    CGFloat descHeight = [Utils sizeOfControl:self.lblShortDesc].height;
    CGFloat verticalMargins = 75.0f; // Take a look at DataCellView.xib file
    
    return imageHeight + titleHeight + descHeight + verticalMargins;
}

- (void)updateUIWithData:(Comic *)comic {
    [self._dataCellPresenter fetchImageFromDataObject:comic];
    
    self.lblTitle.stringValue = comic.name;
    self.lblShortDesc.stringValue = comic.shortDesc;
}

#pragma mark -
#pragma mark - ComicDataCellViewProtocols implementation
#pragma mark -
- (void)updateCellViewImage {
    if ([self._dataCellPresenter getComicImage]) {
        self.imgView.image = [self._dataCellPresenter getComicImage];
    }
}

@end
