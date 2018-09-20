//
//  FilmCellView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmCellView.h"

#import "Film.h"

@interface FilmCellView ()

@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblName;

@property (nonatomic, strong) FilmRepository *_filmRepository;
@property (nonatomic, strong) FilmCellPresenter *_filmCellPresenter;

@end

@implementation FilmCellView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupUI];
}

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._filmRepository = [[FilmRepository alloc] init];
    self._filmCellPresenter = [[FilmCellPresenter alloc] init];
    [self._filmCellPresenter attachView:self repository:self._filmRepository];
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
    self.imgView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.imgView.layer.cornerRadius = [CORNER_RADIUSES[0] doubleValue];
    
    self.lblName.font = [NSFont systemFontOfSize:18.0f weight:NSFontWeightMedium];
    self.lblName.textColor = [NSColor colorBlue];
    self.lblName.maximumNumberOfLines = 0;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (CGFloat)getViewItemHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat nameHeight = [Utils sizeOfControl:self.lblName].height;
    CGFloat verticalMargins = 65.0f; // Take a look at FilmCellView.xib file
    
    return imageHeight + nameHeight + verticalMargins;
}

- (void)updateUIWithData:(Film *)film {
    [self._filmCellPresenter fetchImageFromDataObject:film];
    
    self.lblName.stringValue = film.name;
}

#pragma mark -
#pragma mark - FilmCellViewProtocols implementation
#pragma mark -
- (void)updateCellViewImage {
    if ([self._filmCellPresenter getFilmImage]) {
        self.imgView.image = [self._filmCellPresenter getFilmImage];
    }
}

@end
