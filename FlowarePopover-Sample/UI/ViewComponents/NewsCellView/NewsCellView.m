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

#pragma mark -
#pragma mark - Initialize
#pragma mark -
- (void)initialize {
    self._newsRepository = [[NewsRepository alloc] init];
    self._newsCellPresenter = [[NewsCellPresenter alloc] init];
    [self._newsCellPresenter attachView:self repository:self._newsRepository];
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
    
    self.lblContent.font = [NSFont systemFontOfSize:14.0f weight:NSFontWeightRegular];
    self.lblContent.textColor = [NSColor colorViolet];
    self.lblContent.maximumNumberOfLines = 0;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (CGFloat)getCellHeight {
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat titleHeight = [Utils sizeOfControl:self.lblTitle].height;
    CGFloat contentHeight = [Utils sizeOfControl:self.lblContent].height;
    CGFloat verticalMargins = 75.0f; // Take a look at NewsCellView.xib file
    
    return imageHeight + titleHeight + contentHeight + verticalMargins;
}

- (void)updateUIWithData:(News *)news {
    [self._newsCellPresenter fetchImageFromDataObject:news];
    
    self.lblTitle.stringValue = news.title;
    self.lblContent.stringValue = news.content;
}

#pragma mark -
#pragma mark - NewsCellViewProtocols implementation
#pragma mark -
- (void)updateCellViewImage {
    if ([self._newsCellPresenter getNewsImage]) {
        self.imgView.image = [self._newsCellPresenter getNewsImage];
    }
}

@end
