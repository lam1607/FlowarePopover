//
//  FilmCellView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmCellView.h"

#import "FilmRepository.h"
#import "FilmCellPresenter.h"

#import "Film.h"

@interface FilmCellView ()

@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblName;

@property (nonatomic, strong) FilmRepository *filmRepository;
@property (nonatomic, strong) FilmCellPresenter *filmCellPresenter;

@end

@implementation FilmCellView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self initialize];
    [self setupUI];
}

- (void)viewWillLayout {
    [super viewWillLayout];
    
    [self refreshUIColors];
}

#pragma mark - Initialize

- (void)initialize {
    self.filmRepository = [[FilmRepository alloc] init];
    self.filmCellPresenter = [[FilmCellPresenter alloc] init];
    [self.filmCellPresenter attachView:self repository:self.filmRepository];
}

#pragma mark - Setup UI

- (void)setupUI {
    self.imgView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.lblName.maximumNumberOfLines = 0;
}

- (void)refreshUIColors {
    if ([self.view.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name]) {
        [Utils setShadowForView:self.vContainer];
        
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblName.stringValue color:[NSColor _textBlackColor] fontSize:16.0 forControl:self.lblName];
#else
        [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblName.stringValue color:[NSColor textBlackColor] fontSize:16.0 forControl:self.lblName];
#endif
    }
}

#pragma mark - Processes

- (CGFloat)getViewItemHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat nameHeight = [Utils sizeOfControl:self.lblName].height;
    CGFloat verticalMargins = 65.0; // Take a look at FilmCellView.xib file
    
    return imageHeight + nameHeight + verticalMargins;
}

- (void)updateUIWithData:(Film *)film {
    [self.filmCellPresenter fetchImageFromData:film];
    
    self.lblName.stringValue = film.name;
}

#pragma mark - FilmCellViewProtocols implementation

- (void)updateViewImage {
    if ([self.filmCellPresenter fetchedImage]) {
        self.imgView.image = [self.filmCellPresenter fetchedImage];
    }
}

@end
