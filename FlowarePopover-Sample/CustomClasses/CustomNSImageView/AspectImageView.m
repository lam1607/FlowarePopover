//
//  AspectImageView.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 12/28/20.
//  Copyright © 2020 Floware Inc. All rights reserved.
//

#import "AspectImageView.h"

@implementation AspectImageView

- (id)init
{
    if (self = [super init])
    {
        [super setImageScaling:NSImageScaleAxesIndependently];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [super setImageScaling:NSImageScaleAxesIndependently];
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        [super setImageScaling:NSImageScaleAxesIndependently];
    }
    
    return self;
}

- (void)setImageScaling:(NSImageScaling)newScaling
{
    // That's necessary to use nothing but NSImageScaleAxesIndependently
    [super setImageScaling:NSImageScaleAxesIndependently];
}

- (void)setImage:(NSImage *)image
{
    if (image == nil)
    {
        [super setImage:image];
    }
    else
    {
        __weak typeof(self) wself = self;
        
        NSImage *scaleToFillImage = [NSImage imageWithSize:[self bounds].size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            NSSize imageSize = [image size];
            NSSize imageViewSize = [wself bounds].size; // Yes, do not use dstRect.
            NSSize newImageSize = imageSize;
            CGFloat imageAspectRatio = imageSize.height / imageSize.width;
            CGFloat imageViewAspectRatio = imageViewSize.height / imageViewSize.width;
            
            if (imageAspectRatio < imageViewAspectRatio)
            {
                // Image is more horizontal than the view. Image left and right borders need to be cropped.
                newImageSize.width = imageSize.height / imageViewAspectRatio;
            }
            else
            {
                // Image is more vertical than the view. Image top and bottom borders need to be cropped.
                newImageSize.height = imageSize.width * imageViewAspectRatio;
            }
            
            NSRect srcRect = NSMakeRect(imageSize.width / 2.0 - newImageSize.width / 2.0,
                                        imageSize.height / 2.0 - newImageSize.height / 2.0,
                                        newImageSize.width,
                                        newImageSize.height);
            
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
            
            [image drawInRect:dstRect // Interestingly, here needs to be dstRect and not self.bounds
                     fromRect:srcRect
                    operation:NSCompositingOperationCopy
                     fraction:1.0
               respectFlipped:YES
                        hints:@{NSImageHintInterpolation:@(NSImageInterpolationHigh)}];
            
            return YES;
        }];
        
        [scaleToFillImage setCacheMode:NSImageCacheNever]; // Hence it will automatically redraw with new frame size of the image view.
        
        [super setImage:scaleToFillImage];
    }
}

@end
