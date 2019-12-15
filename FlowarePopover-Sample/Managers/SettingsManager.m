//
//  SettingsManager.m
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "SettingsManager.h"

@interface SettingsManager ()
{
    ApplicationMode _appMode;
}

@end

@implementation SettingsManager

#pragma mark - Singleton

+ (SettingsManager *)sharedInstance
{
    static SettingsManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SettingsManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (ApplicationMode)appMode
{
    return _appMode;
}

#pragma mark - Local methods

- (void)initialize
{
    _appMode = ApplicationModeNormal;
}

#pragma mark - SettingsManager methods

- (BOOL)isNormalMode
{
    return (_appMode == ApplicationModeNormal);
}

- (BOOL)isDesktopMode
{
    return (_appMode == ApplicationModeDesktop);
}

- (void)changeApplicationMode
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFlowarePopover_WindowWillChangeMode object:nil userInfo:nil];
    
    if (_appMode == ApplicationModeNormal)
    {
        _appMode = ApplicationModeDesktop;
    }
    else
    {
        _appMode = ApplicationModeNormal;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFlowarePopover_WindowDidChangeMode object:nil userInfo:nil];
}

@end
