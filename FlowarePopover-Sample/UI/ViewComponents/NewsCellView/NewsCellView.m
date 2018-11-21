//
//  NewsCellView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsCellView.h"

#import "News.h"

@interface NewsCellView ()

@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblTitle;
@property (weak) IBOutlet NSTextField *lblContent;

@property (nonatomic, strong) NewsRepository *_newsRepository;
@property (nonatomic, strong) NewsCellPresenter *_newsCellPresenter;

@end

@implementation NewsCellView

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
    self._newsRepository = [[NewsRepository alloc] init];
    self._newsCellPresenter = [[NewsCellPresenter alloc] init];
    [self._newsCellPresenter attachView:self repository:self._newsRepository];
}

#pragma mark - Setup UI

- (void)setupUI {
    self.imgView.imageScaling = NSImageScaleProportionallyDown;
    self.lblTitle.maximumNumberOfLines = 0;
    self.lblContent.maximumNumberOfLines = 0;
}

- (void)refreshUIColors {
    if ([self.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name]) {
        [Utils setShadowForView:self.vContainer];
        
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor _textBlackColor] fontSize:16.0 forControl:self.lblTitle];
        [Utils setTitle:self.lblContent.stringValue color:[NSColor _textGrayColor] fontSize:14.0 forControl:self.lblContent];
#else
        [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor textBlackColor] fontSize:16.0 forControl:self.lblTitle];
        [Utils setTitle:self.lblContent.stringValue color:[NSColor textGrayColor] fontSize:14.0 forControl:self.lblContent];
#endif
    }
}

#pragma mark - Processes

- (CGFloat)getCellHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat titleHeight = [Utils sizeOfControl:self.lblTitle].height;
    CGFloat contentHeight = [Utils sizeOfControl:self.lblContent].height;
    CGFloat verticalMargins = 75.0; // Take a look at NewsCellView.xib file
    
    return imageHeight + titleHeight + contentHeight + verticalMargins;
}

- (void)updateUIWithData:(News *)news {
    [self._newsCellPresenter fetchImageFromDataObject:news];
    
    self.lblTitle.stringValue = news.title;
    self.lblContent.stringValue = news.content;
}

#pragma mark - NewsCellViewProtocols implementation

- (void)updateCellViewImage {
    if ([self._newsCellPresenter getNewsImage]) {
        self.imgView.image = [self._newsCellPresenter getNewsImage];
    }
}

@end
