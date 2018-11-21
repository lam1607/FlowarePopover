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

- (void)layout {
    [super layout];
    
    [self refreshUIColors];
}

#pragma mark - Initialize

- (void)initialize {
    self._comicRepository = [[ComicRepository alloc] init];
    self._dataCellPresenter = [[DataCellPresenter alloc] init];
    [self._dataCellPresenter attachView:self repository:self._comicRepository];
}

#pragma mark - Setup UI

- (void)setupUI {
    self.imgView.imageScaling = NSImageScaleProportionallyDown;
    self.lblTitle.maximumNumberOfLines = 0;
    self.lblShortDesc.maximumNumberOfLines = 0;
}

- (void)refreshUIColors {
    if ([self.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name]) {
        [Utils setShadowForView:self.vContainer];
        
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor _textBlackColor] fontSize:16.0 forControl:self.lblTitle];
        [Utils setTitle:self.lblShortDesc.stringValue color:[NSColor _textGrayColor] fontSize:14.0 forControl:self.lblShortDesc];
#else
        [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor textBlackColor] fontSize:16.0 forControl:self.lblTitle];
        [Utils setTitle:self.lblShortDesc.stringValue color:[NSColor textGrayColor] fontSize:14.0 forControl:self.lblShortDesc];
#endif
    }
}

#pragma mark - Processes

- (CGFloat)getCellHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat titleHeight = [Utils sizeOfControl:self.lblTitle].height;
    CGFloat descHeight = [Utils sizeOfControl:self.lblShortDesc].height;
    CGFloat verticalMargins = 75.0; // Take a look at DataCellView.xib file
    
    return imageHeight + titleHeight + descHeight + verticalMargins;
}

- (void)updateUIWithData:(Comic *)comic {
    [self._dataCellPresenter fetchImageFromDataObject:comic];
    
    self.lblTitle.stringValue = comic.name;
    self.lblShortDesc.stringValue = comic.shortDesc;
}

#pragma mark - ComicDataCellViewProtocols implementation

- (void)updateCellViewImage {
    if ([self._dataCellPresenter getComicImage]) {
        self.imgView.image = [self._dataCellPresenter getComicImage];
    }
}

@end
