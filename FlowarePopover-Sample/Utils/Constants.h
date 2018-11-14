//
//  Constants.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define SHOULD_USE_ASSET_COLORS

#define FLO_NOTIFICATION_WINDOW_WILL_CHANGE_MODE                                            @"FLO_Notification_WindowWillChangeMode"
#define FLO_NOTIFICATION_WINDOW_DID_CHANGE_MODE                                             @"FLO_Notification_WindowDidChangeMode"

#define FLO_ENTITLEMENT_APP_IDENTIFIER_FINDER                                               @"com.apple.finder"
#define FLO_ENTITLEMENT_APP_IDENTIFIER_SAFARI                                               @"com.apple.Safari"

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

#endif /* Constants_h */
