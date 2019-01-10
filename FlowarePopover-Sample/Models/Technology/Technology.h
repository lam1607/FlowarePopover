//
//  Technology.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface Technology : AbstractData

/// @property
///
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, strong) NSString *longDesc;

/// Initialize
///
- (instancetype)initWithName:(NSString *)name shortDesc:(NSString *)shortDesc longDesc:(NSString *)longDesc
                    imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl;

@end
