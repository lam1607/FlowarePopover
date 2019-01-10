//
//  AbstractData.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractData : NSObject

/// @property
///
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSURL *pageUrl;

/// Initialize
///
- (instancetype)initWithContent:(NSDictionary *)contentDict;
- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;
- (instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;

/// Methods
///
- (void)setImage:(NSImage *)image forURL:(NSURL *)url;
- (NSImage *)getImageForURL:(NSURL *)url;

@end
