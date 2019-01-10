//
//  Film.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface Film : AbstractData

/// @property
///
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *synopsis;
@property (nonatomic, strong) NSURL *trailerUrl;

/// Initialize
///
- (instancetype)initWithName:(NSString *)name releaseDate:(NSString *)releaseDate synopsis:(NSString *)synopsis
                    imageUrl:(NSString *)imageUrl trailerUrl:(NSString *)trailerUrl;

@end
