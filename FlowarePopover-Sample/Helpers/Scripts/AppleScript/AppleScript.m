//
//  AppleScript.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/13/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AppleScript.h"

#pragma mark - AppleScript methods

void script_openFile(NSString *appName, NSString *filePath, float x, float y, float w, float h)
{
    if ([NSObject isEmpty:appName]) return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_sync(queue, ^{
        NSString *partOfCurrWindowName = [filePath lastPathComponent];
        NSString *source;
        
        if ([appName isEqualToString:@"Preview"])
        {
            source = [NSString stringWithFormat:@"\
                      \nactivate \
                      \ntell application \"%@\" \
                      \ntry  \
                      \ntell application \"%@\" to set visible of first window whose name contains \"%@\" to true \
                      \non error errMsg \
                      \ntell application \"%@\" to open POSIX file \"%@\" \
                      \nend try \
                      \nset bounds of first window to {%f, %f, %f, %f} \
                      \nend tell", appName, appName, partOfCurrWindowName, appName, filePath, x, y, w + x, h + y];
        }
        else if ([appName isEqualToString:@"Microsoft Word"])
        {
            source = [NSString stringWithFormat:@"\
                      \ntell application \"%@\" \
                      \nactivate \
                      \ntry  \
                      \ntell application \"%@\" to set window state of window \"%@\" to window state normal \
                      \non error errMsg \
                      \ntell application \"%@\" to open POSIX file \"%@\" \
                      \nend try \
                      \nset bounds of first window to {%f, %f, %f, %f} \
                      \nend tell", appName, appName, partOfCurrWindowName, appName, filePath, x, y, w + x, h + y];
        }
        else if ([appName isEqualToString:@"Microsoft Excel"])
        {
            source = [NSString stringWithFormat:@"\
                      \ntell application \"%@\" \
                      \nactivate \
                      \ntry  \
                      \ntell application \"%@\" to set window state of window \"%@\" to window state normal \
                      \non error errMsg \
                      \ntell application \"%@\" to open POSIX file \"%@\" \
                      \nend try \
                      \nset bounds of first window to {%f, %f, %f, %f} \
                      \nend tell", appName, appName, partOfCurrWindowName, appName, filePath, x, y, w + x, h + y];
        }
        else if ([appName isEqualToString:@"Finder"])
        {
            source = [NSString stringWithFormat:@"\
                      \nscript OpenFile\
                      \non Open()\
                      \nset openFile to POSIX file \"%@\"\
                      \ntell application \"Finder\" to open openFile\
                      \ndelay 1\
                      \n-- lookup which window has name like file -> resize it\
                      \ntell application \"System Events\"\
                      \nlocal flag\
                      \nset flag to \"NO\"\
                      \nrepeat with theProcess in processes\
                      \nif flag is equal \"YES\" then exit repeat\
                      \nif not background only of theProcess then\
                      \ntell theProcess\
                      \nset processName to name\
                      \nset theWindows to windows\
                      \nend tell\
                      \nrepeat with theWindow in theWindows\
                      \nset windowTitle to name of theWindow\
                      \nif windowTitle contains \"%@\" then\
                      \ntell theWindow\
                      \nset {size, position} to {{%f, %f}, {%f, %f}}\
                      \n set flag to \"YES\"\
                      \nexit repeat\
                      \nreturn\
                      \nend tell\
                      \nend if\
                      \nend repeat\
                      \nend if\
                      \nend repeat\
                      \nend tell\
                      \nend Open\
                      \nend script\
                      \ntell OpenFile to Open()", filePath, partOfCurrWindowName, w, h,x , y];
        }
        
        NSDictionary *errorDictionary;
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
        
        DLog(@"AppleScript execute script:\n%@\n", source);
        
        if (![script executeAndReturnError:&errorDictionary])
        {
            DLog(@"Error execute script: %@. \n", errorDictionary);
        }
    });
}

void script_closeFile(NSString *appName, NSString *filePath)
{
    if ([NSObject isEmpty:appName]) return;
    
    NSString *partOfCurrWindowName = [filePath lastPathComponent];
    NSString *source;
    
    if ([appName isEqualToString:@"Microsoft Excel"])
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\" \
                  \nclose (workbook \"%@\")\
                  \nend", appName, partOfCurrWindowName];
    }
    else
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\" \
                  \nclose (first window whose name contains \"%@\")\
                  \nend", appName, partOfCurrWindowName];
    }
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_openApplication(NSString *appName, float x, float y, float w, float h)
{
    if ([NSObject isEmpty:appName]) return;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"%@\"   \
                        \nreopen   \
                        \nactivate \
                        \ntry      \
                        \nset bounds of window 1 to {%f, %f, %f, %f} \
                        \nend try      \
                        \nend tell", appName, x, y, w + x, h + y];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_hideApplication(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return;
    
    /* * ---- Technical note ---- * *
     tell application "Safari"
     set miniaturized of every window to true
     end tell
     */
    NSString *source;
    
    if ([appName isEqualToString:@"Google Chrome"])
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\"   \
                  \ntry\
                  \nset miniaturized of first window to true \
                  \nend try\
                  \ntry\
                  \nset collapsed of first window to true \
                  \nend try \
                  \nend tell", appName];
    }
    else
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\"   \
                  \ntry\
                  \nset miniaturized of first window to true \
                  \nend try\
                  \ntry\
                  \nset collapsed of first window to true \
                  \nend try \
                  \nend tell", appName];
    }
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_closeApplication(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return;
    
    NSString *source;
    
    if ([appName isEqualToString:@"Safari"] || [appName isEqualToString:@"Firefox"] || [appName isEqualToString:@"Google Chrome"])
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\"   \
                  \nclose first window \
                  \nend tell", appName];
    }
    else
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\"   \
                  \nset visible of first window to false \
                  \nend tell", appName];
    }
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

BOOL script_closeWindow(NSString *appName, NSString *title)
{
    if ([NSObject isEmpty:appName]) return NO;
    
    BOOL documentWindow = [appName isEqualToString:@"Microsoft Powerpoint"];
    
    NSString *windowTitle = [title stringByDeletingPathExtension];
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"%@\" \
                        \ntry \
                        \nset wins to (every %@ window whose name contains \"%@\") \
                        \nrepeat with win in wins \
                        \nclose win \
                        \nend repeat \
                        \nend try \
                        \nend tell", appName, documentWindow ? @"document" : @"", windowTitle];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
        
        return NO;
    }
    
    return YES;
}

BOOL script_checkAppHidden(NSString *bundleIdentifier)
{
    if ([NSObject isEmpty:bundleIdentifier]) return NO;
    
    NSInteger ret = 1;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 1 \
                        \ntell application \"System Events\" \
                        \nset procs to (processes whose bundle identifier is \"%@\" and visible is true) \
                        \nif count of procs > 0 \
                        \ncopy 0 to ret \
                        \nend if \
                        \nend tell \
                        \nreturn ret", bundleIdentifier];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (result)
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    else
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    
    return ret == 1;
}

BOOL script_checkMinimized(NSString *appName, NSString *property, NSString *title)
{
    if ([NSObject isEmpty:appName]) return NO;
    
    NSInteger ret = 1;
    
    NSString *document = [appName isEqualToString:@"Microsoft PowerPoint"] ? @"document" : @"";
    
    NSString *source = title == nil ? [NSString stringWithFormat:@" \
                                       \nset ret to 0 \
                                       \ntell application \"%@\" \
                                       \ntry \
                                       \nset wins to (every %@ window whose %@ is false) \
                                       \nif count of wins = 0 \
                                       \ncopy 1 to ret \
                                       \nend if \
                                       \nend try \
                                       \nend tell \
                                       \nreturn ret", appName, document, property]
    : [NSString stringWithFormat:@" \
       \nset ret to 0 \
       \ntell application \"%@\" \
       \ntry \
       \nset wins to (every %@ window whose name contains '%@' and %@ is false) \
       \nif count of wins = 0 \
       \ncopy 1 to ret \
       \nend if \
       \nend try \
       \nend tell \
       \nreturn ret", appName, document, title, property];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (result)
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    else
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    
    return ret == 1;
}

BOOL script_checkWinMinimized(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return NO;
    
    NSInteger ret = 1;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 1 \
                        \ntell application \"%@\" \
                        \nset wins to (every window whose miniaturized is false) \
                        \nif count of wins > 0 \
                        \ncopy 0 to ret \
                        \nend if \
                        \nend tell \
                        \nreturn ret", appName];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (result)
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    else
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    
    return ret == 1;
}

BOOL script_checkWinCollapsed(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return NO;
    
    NSInteger ret = 1;
    
    NSString *document = [appName isEqualToString:@"Microsoft PowerPoint"] ? @"document" : @"";
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 1 \
                        \ntell application \"%@\" \
                        \nset wins to (every %@ window whose collapsed is false) \
                        \nif count of wins > 0 \
                        \ncopy 0 to ret \
                        \nend if \
                        \nend tell \
                        \nreturn ret", appName, document];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (result)
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    else
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    
    return ret == 1;
}

BOOL script_checkWinHidden(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return NO;
    
    NSInteger ret = 1;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 1 \
                        \ntell application \"%@\" \
                        \nset wins to (every window whose visible is true) \
                        \nif count of wins > 0 \
                        \ncopy 0 to ret \
                        \nend if \
                        \nend tell \
                        \nreturn ret", appName];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (result)
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    else
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    
    return ret == 1;
}

BOOL script_checkFirstWinExist(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return NO;
    
    if ([appName hasSuffix:@".app"]) {
        appName = [appName substringToIndex:[appName length] - 4];
    }
    
    NSInteger ret = 0;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 0 \
                        \ntell application \"System Events\" \
                        \ntry \
                        \nif exists (window 1 of process \"%@\") then \
                        \ncopy 1 to ret \
                        \nend if \
                        \nend try \
                        \nend tell \
                        \nreturn ret", appName];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (!result)
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    else
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    
    return ret == 1;
}

void script_positionApp(NSString *appName, float x, float y)
{
    //pass x = -1 or y = -1 to keep x or y position
    if ([NSObject isEmpty:appName]) return;
    
    NSString *xStr = (x == -1) ? @"set x to winX" : [NSString stringWithFormat:@"set x to %f", x];
    NSString *yStr = (y == -1) ? @"set y to winY" : [NSString stringWithFormat:@"set y to %f", y];
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Events\" \
                        \ntell process \"%@\" \
                        \nrepeat with i from 1 to (count of windows) \
                        \nset win to window i \
                        \nset winPosition to position of win \
                        \nset winX to item 1 of winPosition \
                        \nset winY to item 2 of winPosition \
                        \n%@ \
                        \n%@ \
                        \nset position of win to {x, y} \
                        \nend repeat \
                        \nend tell \
                        \nend tell", appName, xStr, yStr];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_hideApp(NSString *bundleIdentifier)
{
    if ([NSObject isEmpty:bundleIdentifier]) return;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Events\" \
                        \nset visible of processes where bundle identifier is \"%@\" to false \
                        \nend tell", bundleIdentifier];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_showApp(NSString *bundleIdentifier)
{
    if ([NSObject isEmpty:bundleIdentifier]) return;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Events\" \
                        \nset visible of processes where bundle identifier is \"%@\" to true \
                        \nactivate \
                        \nend tell", bundleIdentifier];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

int script_openApp(NSString *appName, BOOL shouldActive)
{
    if ([NSObject isEmpty:appName]) return 1;
    
    NSString *source = [NSString stringWithFormat:@"tell application \"%@\" to launch", appName];
    
    if (shouldActive)
    {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\" \
                  \nreopen   \
                  \nactivate \
                  \nend tell", appName];
    }
    
    NSDictionary *errorDictionary = nil;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
        
        return 0;
    }
    
    return 1;
}

void script_openMSApp(NSString *appName, BOOL openNewDocument)
{
    if ([NSObject isEmpty:appName]) return;
    
    NSString *doc = [appName isEqualToString:@"Microsoft PowerPoint"] ? @"presentation" : @"document";
    
    NSString *source = @"";
    if (openNewDocument) {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\" \
                  \nactivate \
                  \nmake new %@ \
                  \nend tell", appName, doc];
    } else {
        source = [NSString stringWithFormat:@" \
                  \ntell application \"%@\" \
                  \nactivate \
                  \nend tell", appName];
    }
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_hideAllAppsExcept(NSString *bundleIdentifier1, NSString *bundleIdentifier2)
{
    NSString *apps = @"";
    
    if ([NSObject isEmpty:bundleIdentifier1] && ![NSObject isEmpty:bundleIdentifier2])
    {
        bundleIdentifier1 = bundleIdentifier2;
        bundleIdentifier2 = nil;
    }
    
    if (![NSObject isEmpty:bundleIdentifier1])
    {
        apps = [NSString stringWithFormat:@" or bundle identifier is \"%@\"%@", bundleIdentifier1, bundleIdentifier2 == nil?@"":[NSString stringWithFormat:@" or bundle identifier is \"%@\"", bundleIdentifier2]];
    }
    
    NSString *exceptedApps = [NSString stringWithFormat:@" and not (bundle identifier is \"%@\"%@)", [[NSBundle mainBundle] bundleIdentifier], apps];
    NSString *source = [NSString stringWithFormat:@"    \
                        \ntell application \"System Events\"    \
                        \nset visible of (every process whose visible is true and frontmost is false%@) to false  \
                        \nend tell  \
                        ", exceptedApps];
    // nset visible of process \"Finder\" to false    \ => disabled
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_hideAllApps()
{
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Events\" \
                        \nset visible of processes where bundle identifier is not \"%@\" to false \
                        \nend tell", [[NSBundle mainBundle] bundleIdentifier]];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_autoHideDock(BOOL hidden)
{
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Events\" to set autohide of dock preferences to %@", hidden?@"true":@"false"];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

BOOL script_checkDockAutoHidden()
{
    NSInteger ret = 0;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 0 \
                        \ntell application \"System Events\" \
                        \nif autohide of dock preferences \
                        \ncopy 1 to ret \
                        \nend if \
                        \nend tell \
                        \nreturn ret"];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (!result)
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
    else
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    
    return ret == 1;
}

void script_openAccessibilityPreference()
{
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Preferences\" \
                        \nset securityPane to pane id \"com.apple.preference.security\" \
                        \ntell securityPane to reveal anchor \"Privacy_Accessibility\" \
                        \nactivate \
                        \nend tell"];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

void script_activateApplication(NSString *appName)
{
    if ([NSObject isEmpty:appName]) return;
    
    NSString *processName = appName;
    
    if ([appName containsString:@".app"])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - 4)];
    }
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"%@\"   \
                        \ntry      \
                        \nreopen   \
                        \nactivate \
                        \nend try      \
                        \nend tell", processName];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

int script_resizeApplication(NSString *appName, NSString *bundle, NSInteger x, NSInteger y, NSInteger width, NSInteger height, BOOL autoArrange)
{
    if ([NSObject isEmpty:appName] || (width == 0) || (height == 0)) return 2;
    
    NSString *processName = appName;
    
    if ([appName containsString:@".app"])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - 4)];
    }
    
    int ret = 0;
    
    NSString *source = [NSString stringWithFormat:@"\
                        \nset ret to 0 \
                        \n \
                        \ntell application \"System Events\" \
                        \ntell process \"%@\" \
                        \nset winList to windows \
                        \nset winListCount to (count of winList) \
                        \nset firstWindowFound to false \
                        \nset firstWindow to missing value \
                        \n \
                        \nif winListCount > 0 then \
                        \nrepeat with idx from 1 to winListCount \
                        \nif window idx exists then \
                        \nset windowCloseButton to (value of attribute \"AXCloseButton\" of window idx) \
                        \nset windowMinimizeButton to (value of attribute \"AXMinimizeButton\" of window idx) \
                        \n \
                        \nif window idx is not missing value and windowCloseButton is not missing value and windowMinimizeButton is not missing value and (enabled of windowCloseButton is true) and (enabled of windowMinimizeButton is true) then \
                        \nif firstWindowFound then \
                        \ntell window idx to set value of attribute \"AXMinimized\" to true \
                        \nelse \
                        \nset firstWindowFound to true \
                        \nset firstWindow to (a reference to (window idx)) \
                        \nend if \
                        \nend if \
                        \nend if \
                        \nend repeat \
                        \nend if \
                        \n \
                        \nif winListCount = 0 then \
                        \nset ret to 4 \
                        \nelse if not firstWindowFound then \
                        \nset ret to 2 \
                        \nelse if firstWindow is not missing value then \
                        \nset isMinimized to (value of attribute \"AXMinimized\" of firstWindow) \
                        \n \
                        \nif (isMinimized = 1) or (isMinimized is true) then \
                        \ntell firstWindow to set value of attribute \"AXMinimized\" to false \
                        \nend if \
                        \n \
                        \nset position of firstWindow to {%ld, %ld} \
                        \nset size of firstWindow to {%ld, %ld} \
                        \n \
                        \nset windowPosition to position of firstWindow \
                        \nset windowSize to size of firstWindow \
                        \n \
                        \nif ((item 1 of windowPosition) is equal to %ld) and ((item 2 of windowPosition) is equal to %ld) and ((item 1 of windowSize) is equal to %ld) and ((item 2 of windowSize) is equal to %ld) then \
                        \nset ret to 1 \
                        \nend if \
                        \nend if \
                        \nend tell \
                        \nend tell \
                        \nget ret", processName, x, y, width, height, x, y, width, height];
    
    NSLog(@"[AppleScriptLog]-->%s-%d Before executing script:\n%@\n", __PRETTY_FUNCTION__, __LINE__, source);
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    if (!result)
    {
        NSLog(@"[AppleScriptLog]-->%s-%d Error execute script:\n%@\n", __PRETTY_FUNCTION__, __LINE__, errorDictionary);
    }
    else
    {
        // * @return
        // case 0: unexpected error.
        // case 1: succeeded
        // case 2: first window not found
        // case 4: no window found
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    
    NSLog(@"[AppleScriptLog]-->%s-%d After executing script with result:%d\n", __PRETTY_FUNCTION__, __LINE__, ret);
    
    return ret;
}

int script_resizeDocument(NSString *appName, NSString *fullPath, NSString *siblingTitle, NSInteger x, NSInteger y, NSInteger width, NSInteger height, BOOL autoArrange)
{
    if ([NSObject isEmpty:appName] || (width == 0) || (height == 0)) return 2;
    
    NSString *processName = appName;
    
    if ([appName containsString:@".app"])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - 4)];
    }
    
    int ret = 0;
    NSString *windowTitle = [[fullPath lastPathComponent] stringByDeletingPathExtension];
    NSString *siblingWindowTitle = (siblingTitle == nil) ? @"" : [[siblingTitle lastPathComponent] stringByDeletingPathExtension];
    
    NSString *source = [NSString stringWithFormat:@" \
                        \nset ret to 0 \
                        \nset focusTitle to \"%@\" \
                        \nset siblingTitle to \"%@\" \
                        \n \
                        \ntell application \"System Events\" \
                        \ntell process \"%@\" \
                        \nset winList to windows \
                        \nset documentWindowFound to false \
                        \n \
                        \nrepeat with checkingWindow in winList \
                        \nset theWindow to contents of checkingWindow \
                        \nset theWindowCloseButton to (value of attribute \"AXCloseButton\" of theWindow) \
                        \nset theWindowMinimizeButton to (value of attribute \"AXMinimizeButton\" of theWindow) \
                        \n \
                        \nif theWindow is not missing value and theWindowCloseButton is not missing value and theWindowMinimizeButton is not missing value and (enabled of theWindowCloseButton is true) and (enabled of theWindowMinimizeButton is true) then \
                        \nset windowTitle to name of theWindow \
                        \n \
                        \nif windowTitle contains focusTitle then \
                        \nset documentWindowFound to true \
                        \nset isMinimized to (value of attribute \"AXMinimized\" of theWindow) \
                        \n \
                        \nif (isMinimized = 1) or (isMinimized is true) then \
                        \ntell theWindow to set value of attribute \"AXMinimized\" to false \
                        \nend if \
                        \n \
                        \nset position of theWindow to {%ld, %ld} \
                        \nset size of theWindow to {%ld, %ld} \
                        \n \
                        \nset windowPosition to position of theWindow \
                        \nset windowSize to size of theWindow \
                        \n \
                        \nif ((item 1 of windowPosition) is equal to %ld) and ((item 2 of windowPosition) is equal to %ld) and ((item 1 of windowSize) is equal to %ld) and ((item 2 of windowSize) is equal to %ld) then \
                        \nset ret to 1 \
                        \nend if \
                        \nelse \
                        \nif (siblingTitle is not equal to null) and (siblingTitle is not equal to \"\") then \
                        \nif (windowTitle does not contain siblingTitle) then \
                        \ntell theWindow to set value of attribute \"AXMinimized\" to true \
                        \nend if \
                        \nelse \
                        \ntell theWindow to set value of attribute \"AXMinimized\" to true \
                        \nend if \
                        \nend if \
                        \nend if \
                        \nend repeat \
                        \n \
                        \nif (count of winList) = 0 then \
                        \nset ret to 4 \
                        \nelse if not documentWindowFound then \
                        \nset ret to 2 \
                        \nend if \
                        \nend tell \
                        \nend tell \
                        \nget ret"
                        , windowTitle, siblingWindowTitle, processName, x, y, width, height, x, y, width, height];
    
    NSLog(@"[AppleScriptLog]-->%s-%d script:\n%@\n", __PRETTY_FUNCTION__, __LINE__, source);
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    if (!result)
    {
        NSLog(@"[AppleScriptLog]-->%s-%d Error execute script:\n%@\n", __PRETTY_FUNCTION__, __LINE__, errorDictionary);
    }
    else
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
        
        // @param: ret
        // ret = 0: resizing but would not be complete because when set position and size for the window both would not be all affective at the same time
        // ret = 1: already resized
        // ret = 2: application does not have the document window
    }
    
    return ret;
}

int script_openURLInCurrentTab(NSString *url, NSString *appName)
{
    if ([NSObject isEmpty:appName]) return 0;
    
    NSString *source = @"";
    
    if ([[appName uppercaseString] isEqualToString:@"SAFARI"])
    {
        source = [NSString stringWithFormat:@" \
                  \n tell application \"Safari\" \
                  \n tell front window \
                  \n set URL of current tab to \"%@\" \
                  \n end tell \
                  \n end tell", url];
    }
    else if ([[appName uppercaseString] isEqualToString:@"GOOGLE CHROME"] || [[appName uppercaseString] isEqualToString:@"CHROME"])
    {
        source = [NSString stringWithFormat:@" \
                  \n tell application \"Google Chrome\" \
                  \n tell front window \
                  \n set URL of active tab to \"%@\" \
                  \n end tell \
                  \n end tell", url];
    }
    else
    {
        source = [NSString stringWithFormat:@" \
                  \n repeat until (the clipboard) is equal to \"%@\"\
                  \n    set the clipboard to \"%@\"\
                  \n end repeat\
                  \n tell application \"%@\" \
                  \n    activate \
                  \n    tell application \"System Events\" \
                  \n        keystroke \"l\" using {command down} \
                  \n        delay 0.5\
                  \n        keystroke \"v\" using {command down} \
                  \n        delay 0.5\
                  \n        key code 36\
                  \n    end tell \
                  \n end tell", url, url, appName];
    }
    
    NSLog(@"[AppleScriptLog]-->%s-%d script:\n%@\n", __PRETTY_FUNCTION__, __LINE__, source);
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    [script executeAndReturnError:&errorDictionary];
    
    int ret = 1;
    
    if (errorDictionary != nil)
    {
        NSLog(@"[AppleScriptLog]-->%s-%d Error execute script:\n%@\n", __PRETTY_FUNCTION__, __LINE__, errorDictionary);
        
        ret = [[errorDictionary objectForKey:NSAppleScriptErrorNumber] intValue];
    }
    
    return ret;
}

@implementation AppleScript

@end
