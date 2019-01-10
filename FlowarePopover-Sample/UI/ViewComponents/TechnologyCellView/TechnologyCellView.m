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

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblTitle;
@property (weak) IBOutlet NSTextField *lblShortDesc;

/// @property
///
@property (nonatomic, strong) TechnologyRepository *repository;
@property (nonatomic, strong) TechnologyCellPresenter *presenter;

@end

@implementation TechnologyCellView

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
    self.repository = [[TechnologyRepository alloc] init];
    self.presenter = [[TechnologyCellPresenter alloc] init];
    [self.presenter attachView:self repository:self.repository];
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

#pragma mark - ViewRowProtocols implementation

- (void)updateData:(NSObject * _Nonnull)obj atIndex:(NSInteger)index {
    if ([obj isKindOfClass:[Technology class]]) {
        Technology *technology = (Technology *)obj;
        
        [self.presenter fetchImageFromData:technology];
        
        self.lblTitle.stringValue = technology.name;
        self.lblShortDesc.stringValue = technology.shortDesc;
    }
}

#pragma mark - TechnologyCellViewProtocols implementation

- (void)updateViewImage {
    if ([self.presenter fetchedImage]) {
        self.imgView.image = [self.presenter fetchedImage];
    }
}

@end
