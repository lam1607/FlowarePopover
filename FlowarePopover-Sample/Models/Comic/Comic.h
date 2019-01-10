//
//  Comic.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/21/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface Comic : AbstractData

/// @property
///
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, strong) NSString *longDesc;
@property (nonatomic, strong) NSMutableArray<Comic *> *childItems;

/// Initialize
///
- (instancetype)initWithName:(NSString *)name shortDesc:(NSString *)shortDesc longDesc:(NSString *)longDesc
                    imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;

@end
