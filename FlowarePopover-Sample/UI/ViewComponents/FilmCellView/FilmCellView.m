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
{
    id<FilmRepositoryProtocols> _repository;
    id<FilmCellPresenterProtocols> _presenter;
}

/// IBOutlet
///
@property (weak) IBOutlet NSView *vContainer;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSTextField *lblName;

/// @property
///

@end

@implementation FilmCellView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self objectsInitialize];
    [self setupUI];
    [self refreshUIAppearance];
}

#pragma mark - Initialize

- (void)objectsInitialize
{
    _repository = [[FilmRepository alloc] init];
    _presenter = [[FilmCellPresenter alloc] init];
    [_presenter attachView:self repository:_repository];
}

#pragma mark - Getter/Setter

- (void)setSelected:(BOOL)selected
{
    self.vContainer.layer.borderWidth = selected ? 2.5 : 0.0;
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.imgView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.lblName.maximumNumberOfLines = 0;
}

#pragma mark - Public methods

- (CGFloat)getViewItemHeight
{
    CGFloat imageHeight = self.imgView.frame.size.height;
    CGFloat nameHeight = [Utils sizeOfControl:self.lblName].height;
    CGFloat verticalMargins = 65.0; // Take a look at FilmCellView.xib file
    
    return imageHeight + nameHeight + verticalMargins;
}

#pragma mark - ItemCellViewProtocols implementation

- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndexPath:(NSIndexPath *)indexPath
{
    if ([data isKindOfClass:[Film class]])
    {
        Film *film = (Film *)data;
        
        [_presenter fetchImageFromData:film];
        
        self.lblName.stringValue = film.name;
    }
}

#pragma mark - FilmCellViewProtocols implementation

- (void)refreshUIAppearance
{
    [Utils setShadowForView:self.vContainer];
    
    [Utils setBackgroundColor:[NSColor backgroundWhiteColor] cornerRadius:[CORNER_RADIUSES[0] doubleValue] borderWidth:0.0 borderColor:[NSColor blueColor] forView:self.vContainer];
    
    [Utils setBackgroundColor:NSColor.clearColor cornerRadius:[CORNER_RADIUSES[0] doubleValue] forView:self.imgView];
    
    [Utils setTitle:self.lblName.stringValue color:[NSColor textBlackColor] fontSize:16.0 forControl:self.lblName];
}

- (void)updateViewImage
{
    if ([_presenter fetchedImage])
    {
        self.imgView.image = [_presenter fetchedImage];
    }
}

@end
