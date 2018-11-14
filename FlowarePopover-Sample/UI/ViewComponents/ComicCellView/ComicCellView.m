//
//  ComicCellView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicCellView.h"

#import "Comic.h"

@interface ComicCellView ()

@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSTextField *lblTitle;

@end

@implementation ComicCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupUI];
}

- (void)layout {
    [super layout];
    
    [self refreshUIColors];
}

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    self.lblTitle.maximumNumberOfLines = 0;
}

- (void)refreshUIColors {
    [Utils setShadowForView:self.vContainer];
    
#ifdef SHOULD_USE_ASSET_COLORS
    [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
    
    [Utils setTitle:self.lblTitle.stringValue color:[NSColor _textGrayColor] fontSize:16.0 forControl:self.lblTitle];
#else
    [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
    
    [Utils setTitle:self.lblTitle.stringValue color:[NSColor textGrayColor] fontSize:16.0 forControl:self.lblTitle];
#endif
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)updateUIWithData:(Comic *)comic {
    self.lblTitle.stringValue = comic.name;
}

@end
