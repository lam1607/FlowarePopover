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
{
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSTextField *lblTitle;

@end

@implementation ComicCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupUI];
    [self refreshUIAppearance];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.lblTitle.maximumNumberOfLines = 0;
}

#pragma mark - ItemCellViewProtocols implementation

- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndex:(NSInteger)index
{
    if ([data isKindOfClass:[Comic class]])
    {
        Comic *comic = (Comic *)data;
        
        self.lblTitle.stringValue = comic.name;
    }
}

#pragma mark - AbstractViewProtocols

- (void)refreshUIAppearance
{
    [Utils setShadowForView:self.vContainer];
    
    [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor blueColor] forView:self.vContainer];
    
    [Utils setTitle:self.lblTitle.stringValue color:[NSColor textGrayColor] fontSize:16.0 forControl:self.lblTitle];
}

@end
