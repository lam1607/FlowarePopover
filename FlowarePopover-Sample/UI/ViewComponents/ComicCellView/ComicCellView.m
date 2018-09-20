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

#pragma mark -
#pragma mark - Setup UI
#pragma mark -
- (void)setupUI {
    self.vContainer.wantsLayer = YES;
    self.vContainer.layer.backgroundColor = [[NSColor clearColor] CGColor];
    
    self.lblTitle.font = [NSFont systemFontOfSize:16.0f weight:NSFontWeightMedium];
    self.lblTitle.textColor = [NSColor whiteColor];
    self.lblTitle.maximumNumberOfLines = 0;
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (void)updateUIWithData:(Comic *)comic {
    self.lblTitle.stringValue = comic.name;
}

@end
