//
//  Constants.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/8/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kFlowarePopover_WindowWillChangeModeNotification    @"kFlowarePopover_WindowWillChangeModeNotification"
#define kFlowarePopover_WindowDidChangeModeNotification     @"kFlowarePopover_WindowDidChangeModeNotification"

#define kFlowarePopover_BundleIdentifier_Finder             @"com.apple.finder"
#define kFlowarePopover_BundleIdentifier_Safari             @"com.apple.Safari"

#define LOG_DEBUG

#ifdef LOG_DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define DLog(...)
#endif

///
/// Define Color
/// Convert between RGB and HEX from
/// https://www.webpagefx.com/web-design/hex-to-rgb/
///
#define COLOR_ALPHA                                             0.75

///
/// Files
///
#define FILENAME_DATA_MOCKUP                                    @"MockData"

///
/// Default values
///
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

///
/// Entitlements Identifiers
///
static NSString *const EntitlementsApplicationExtension = @".app";
static NSString *const EntitlementsIdentifier_SystemEvents = @"com.apple.systemevents";
static NSString *const EntitlementsIdentifier_Dock = @"com.apple.dock";
static NSString *const EntitlementsIdentifier_Finder = @"com.apple.finder";
static NSString *const EntitlementsIdentifier_Safari = @"com.apple.Safari";
static NSString *const EntitlementsIdentifier_GoogleChrome = @"com.google.Chrome";
static NSString *const EntitlementsIdentifier_Firefox = @"org.mozilla.firefox";
static NSString *const EntitlementsIdentifier_iTunes = @"com.apple.iTunes";
static NSString *const EntitlementsIdentifier_Photos = @"com.apple.Photos";
static NSString *const EntitlementsIdentifier_Pages = @"com.apple.iWork.Pages";
static NSString *const EntitlementsIdentifier_Numbers = @"com.apple.iWork.Numbers";
static NSString *const EntitlementsIdentifier_Keynote = @"com.apple.iWork.Keynote";
static NSString *const EntitlementsIdentifier_AddressBook = @"com.apple.AddressBook";
static NSString *const EntitlementsIdentifier_Calendar = @"com.apple.iCal";
static NSString *const EntitlementsIdentifier_Messages = @"com.apple.iChat";
static NSString *const EntitlementsIdentifier_FaceTime = @"com.apple.FaceTime";
static NSString *const EntitlementsIdentifier_Preview = @"com.apple.Preview";
static NSString *const EntitlementsIdentifier_SystemPreferences = @"com.apple.systempreferences";
static NSString *const EntitlementsIdentifier_TextEdit = @"com.apple.TextEdit";
static NSString *const EntitlementsIdentifier_Notes = @"com.apple.Notes";
static NSString *const EntitlementsIdentifier_Reminders = @"com.apple.reminders";
static NSString *const EntitlementsIdentifier_Maps = @"com.apple.Maps";
static NSString *const EntitlementsIdentifier_MicrosoftWord = @"com.microsoft.Word";
static NSString *const EntitlementsIdentifier_MicrosoftExcel = @"com.microsoft.Excel";
static NSString *const EntitlementsIdentifier_MicrosoftPowerpoint = @"com.microsoft.Powerpoint";
static NSString *const EntitlementsIdentifier_MicrosoftOutlook = @"com.microsoft.Outlook";
static NSString *const EntitlementsIdentifier_Photoshop = @"com.adobe.Photoshop";
static NSString *const EntitlementsIdentifier_AdobeLightroom6 = @"com.adobe.Lightroom6";
static NSString *const EntitlementsIdentifier_AdobeLightroomCC = @"com.adobe.lightroomCC";
static NSString *const EntitlementsIdentifier_AdobeAcrobatPro = @"com.adobe.Acrobat.Pro";
static NSString *const EntitlementsIdentifier_AdobeAcrobatReader = @"com.adobe.acrobat.reader";
static NSString *const EntitlementsIdentifier_AdobeAcrobatReaderDC = @"com.adobe.reader";
static NSString *const EntitlementsIdentifier_Skype = @"com.skype.skype";
static NSString *const EntitlementsIdentifier_QuickTimePlayer = @"com.apple.QuickTimePlayerX";
static NSString *const EntitlementsIdentifier_Mail = @"com.apple.mail";
static NSString *const EntitlementsIdentifier_Thunderbird = @"org.mozilla.thunderbird";
static NSString *const EntitlementsIdentifier_Iris = @"yahoo.messenger.iris";
static NSString *const EntitlementsIdentifier_ActivityMonitor = @"com.apple.ActivityMonitor";
static NSString *const EntitlementsIdentifier_Xcode = @"com.apple.dt.Xcode";
static NSString *const EntitlementsIdentifier_Postman = @"com.postmanlabs.mac";

#endif /* Constants_h */
