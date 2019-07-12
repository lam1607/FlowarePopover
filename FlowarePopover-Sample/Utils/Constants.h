//
//  Constants.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kFlowarePopover_UseAssetColors

#define kFlowarePopover_WindowWillChangeMode                @"kFlowarePopover_WindowWillChangeMode"
#define kFlowarePopover_WindowDidChangeMode                 @"kFlowarePopover_WindowDidChangeMode"

#define kFlowarePopover_BundleIdentifier_Finder             @"com.apple.finder"
#define kFlowarePopover_BundleIdentifier_Safari             @"com.apple.Safari"

typedef NS_ENUM(NSInteger, FLOWindowMode) {
    FLOWindowModeNormal,
    FLOWindowModeDesktop
};

#define LOG_DEBUG

#ifdef LOG_DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define DLog(...)
#endif

//
// Define Color
// Convert between RGB and HEX from
// https://www.webpagefx.com/web-design/hex-to-rgb/
//
#define COLOR_ALPHA                                             0.75

//
// Files
//
#define FILENAME_DATA_MOCKUP                                    @"MockData"

//
// Default values
//
#define EMPTY_STRING                                            @""
#define ZERO_STRING                                             @"0"
#define WHITESPACE                                              @" "
#define AMPERSAND                                               @"&"
#define HASH                                                    @"#"
#define COMMA                                                   @","
#define DOT                                                     @"."
#define SEMICOLON                                               @";"
#define COLON                                                   @":"
#define SINGLE_QUOTATION_MARK                                   @"'"
#define DOUBLE_QUOTATION_MARK                                   @"\""
#define DASH                                                    @"-"

#define CORNER_RADIUSES                                         @[@(5.0), @(10.0)]

//--------------------------------------------------------------------------------------------------------------------------------
//      WINDOW LEVEL GROUP TAG
//--------------------------------------------------------------------------------------------------------------------------------
typedef NS_ENUM(NSInteger, WindowLevelGroupTag) {
    WindowLevelGroupTagDesktop          = kCGDesktopIconWindowLevel + 1,
    WindowLevelGroupTagBase             = kCGNormalWindowLevel,
    WindowLevelGroupTagNormal           = kCGNormalWindowLevel + 1,
    WindowLevelGroupTagSetting          = kCGNormalWindowLevel + 2,
    WindowLevelGroupTagUtility          = kCGFloatingWindowLevel,
    WindowLevelGroupTagHigh             = kCGFloatingWindowLevel + 2,
    WindowLevelGroupTagAlert            = kCGModalPanelWindowLevel,
};
//--------------------------------------------------------------------------------------------------------------------------------

#endif /* Constants_h */
