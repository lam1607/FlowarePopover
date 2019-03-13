//
//  AbstractData.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ListSupplierProtocol.h"

@interface AbstractData : NSObject <ListSupplierProtocol, NSCoding, NSCopying, NSMutableCopying, NSPasteboardWriting, NSPasteboardReading>

/// @property
///
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *pageUrl;

/// Initialize
///
- (instancetype)initWithContent:(NSDictionary *)contentDict;
- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;
- (instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;

/// Methods
///
- (void)setImage:(NSImage *)image forURL:(NSString *)url;
- (NSImage *)getImageForURL:(NSString *)url;

@end
