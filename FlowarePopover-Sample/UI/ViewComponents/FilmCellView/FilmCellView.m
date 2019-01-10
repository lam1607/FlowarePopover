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

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblName;

/// @property
///
@property (nonatomic, strong) FilmRepository *repository;
@property (nonatomic, strong) FilmCellPresenter *presenter;

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
    self.repository = [[FilmRepository alloc] init];
    self.presenter = [[FilmCellPresenter alloc] init];
    [self.presenter attachView:self repository:self.repository];
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

#pragma mark - Public methods

- (CGFloat)getViewItemHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat nameHeight = [Utils sizeOfControl:self.lblName].height;
    CGFloat verticalMargins = 65.0; // Take a look at FilmCellView.xib file
    
    return imageHeight + nameHeight + verticalMargins;
}

#pragma mark - ViewRowProtocols implementation

- (void)updateData:(NSObject * _Nonnull)obj atIndex:(NSInteger)index {
    if ([obj isKindOfClass:[Film class]]) {
        Film *film = (Film *)obj;
        
        [self.presenter fetchImageFromData:film];
        
        self.lblName.stringValue = film.name;
    }
}

#pragma mark - FilmCellViewProtocols implementation

- (void)updateViewImage {
    if ([self.presenter fetchedImage]) {
        self.imgView.image = [self.presenter fetchedImage];
    }
}

@end
