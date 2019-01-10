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

/// IBOutlet
///
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

#pragma mark - Setup UI

- (void)setupUI {
    self.lblTitle.maximumNumberOfLines = 0;
}

- (void)refreshUIColors {
    if ([self.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name]) {
        [Utils setShadowForView:self.vContainer];
        
#ifdef SHOULD_USE_ASSET_COLORS
        [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor _textGrayColor] fontSize:16.0 forControl:self.lblTitle];
#else
        [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.vContainer];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor textGrayColor] fontSize:16.0 forControl:self.lblTitle];
#endif
    }
}

#pragma mark - ViewRowProtocols implementation

- (void)updateData:(NSObject * _Nonnull)obj atIndex:(NSInteger)index {
    if ([obj isKindOfClass:[Comic class]]) {
        Comic *comic = (Comic *)obj;
        
        self.lblTitle.stringValue = comic.name;
    }
}

@end
