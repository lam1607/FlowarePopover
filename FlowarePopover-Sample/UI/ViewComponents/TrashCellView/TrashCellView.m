//
//  TrashCellView.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TrashCellView.h"

#import "AbstractData.h"

#import "NSObject+Extensions.h"

@interface TrashCellView ()
{
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSTextField *lblTitle;
@property (weak) IBOutlet NSTextField *lblUrl;

/// @property
///

@end

@implementation TrashCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupUI];
}

- (void)layout
{
    [super layout];
    
    [self refreshUIColors];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.lblTitle.maximumNumberOfLines = 1;
    self.lblUrl.maximumNumberOfLines = 1;
}

- (void)refreshUIColors
{
    if ([self.effectiveAppearance.name isEqualToString:[NSAppearance currentAppearance].name])
    {
        [Utils setShadowForView:self.vContainer];
        
#ifdef kFlowarePopover_UseAssetColors
        [Utils setBackgroundColor:[NSColor _backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor _blueColor] forView:self.vContainer];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor _textGrayColor] fontSize:16.0 forControl:self.lblTitle];
#else
        [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor blueColor] forView:self.vContainer];
        
        [Utils setTitle:self.lblTitle.stringValue color:[NSColor textGrayColor] fontSize:16.0 forControl:self.lblTitle];
#endif
    }
}

#pragma mark - ItemCellViewProtocols implementation

- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndex:(NSInteger)index
{
    if ([data isKindOfClass:[AbstractData class]])
    {
        AbstractData *object = (AbstractData *)data;
        
        self.lblTitle.stringValue = [object.title isKindOfClass:[NSString class]] ? object.title : ([object.name isKindOfClass:[NSString class]] ? object.name : @"--");
        self.lblUrl.stringValue = object.imageUrl;
    }
}
@end
