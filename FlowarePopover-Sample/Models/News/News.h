//
//  News.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface News : AbstractData

/// @property
///
@property (nonatomic, strong) NSString *content;

/// Initialize
///
- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;

@end
