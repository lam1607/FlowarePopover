//
//  WindowMainView.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 12/7/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "WindowMainView.h"

@interface WindowMainView ()

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation WindowMainView

- (void)dealloc {
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
}

#pragma mark - Mouse events

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
    
    NSInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    // Re-focus to the application window when mouse re-entered after focusing on other NSWindow.
    if ([self isDescendantOf:event.window.contentView] && ([event.window isKeyWindow] == NO)) {
        [event.window makeKeyAndOrderFront:nil];
    }
}

- (void)mouseExited:(NSEvent *)event {
    // Don't resignKeyWindow for application window. For preventing loose focusing when mouse moves out of application window.
}

@end
