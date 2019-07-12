//
//  AppleScript.m
//  Flow
//
//  Created by Trung Nguyen on 4/13/15.
//  Copyright (c) 2015 LCL. All rights reserved.
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

void script_positionApp2(NSString *appName, float x, float y, float width, float height)
{
    if ([NSObject isEmpty:appName]) return;
    
    NSString *source = [NSString stringWithFormat:@" \
                        \ntell application \"System Events\" \
                        \ntell application \"%@\" \
                        \nactivate \
                        \nend tell \
                        \nset condition to true \
                        \nset tryNumbers to 0 \
                        \nrepeat until condition is false \
                        \nset processWindows to windows of process \"%@\" \
                        \nset numeberOfWindows to the length of processWindows \
                        \nset tryNumbers to tryNumbers + 1 \
                        \nif (numeberOfWindows > 0) or (tryNumbers > 100) then \
                        \nset condition to false \
                        \nend if \
                        \nend repeat \
                        \ntell process \"%@\" \
                        \nset position of every window to {%f, %f} \
                        \nset size of every window to {%f, %f} \
                        \nend tell \
                        \nend tell", appName, appName, appName, x, y, width, height];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (![script executeAndReturnError:&errorDictionary])
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
    }
}

//static BOOL fixed = NO;

int script_presentApp(NSString *appName, NSString *bundle, float x, float y, float maxWidth, float maxHeight, BOOL needResize)
{
    if (maxWidth == 0 || maxHeight == 0 || [NSObject isEmpty:appName]) return 2;
    
    NSString *processName = appName;
    NSString *extension = @".app";
    
    if ([appName containsString:extension])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - extension.length)];
    }
    
    int ret = -1;
    float width = maxWidth;
    float height = maxHeight;
    
    NSString *source = [NSString stringWithFormat:@"set ret to 0 \
                        \ntell application \"System Events\" \
                        \ntell process \"%@\" \
                        \nset position of window 1 to {%f, %f} \
                        \nset size of window 1 to {%f, %f} \
                        \n\nset winposition to position of window 1 \
                        \n\nif (item 1 of winposition) is equal to %f then \
                        \nset ret to 1 \
                        \nend if \
                        \n\nset winposition to position of window 1 \
                        \nset winsize to size of window 1 \
                        \n\nif (ret = 1) and (((item 1 of winposition) is not equal to %f) or ((item 2 of winposition) is not equal to %f) or ((item 1 of winsize) is not equal to %f) or ((item 2 of winsize) is not equal to %f)) then \
                        \ntell window 1 of application \"%@\" to set bounds to {%f, %f, %f, %f} \
                        \nend if \
                        \nend tell \
                        \nend tell \
                        \n\nget ret", processName, x, y + 1, width, height, x, x, y + 1, width, height, processName, x, y + 1, width + x, height + y + 1];
    
    NSDictionary *errorDictionary = nil;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (!result)
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
        
        ret = 0;
    }
    else
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
        
        // @param: ret
        // ret = 0: has an unexpected error => we can't handle => need to reset script
        // ret = 1: successfull
        // ret = 2: has an error that can be managed
    }
    
    return ret;
}

int script_presentDocument(NSString *appName, NSString *title, NSString *siblingTitle, float x, float y, float w, float h, BOOL needResize)
{
    if ([NSObject isEmpty:appName]) return 1;
    
    NSString *processName = appName;
    
    if ([appName containsString:@".app"])
    {
        processName = [processName substringWithRange:NSMakeRange(0, processName.length - 4)];
    }
    
    int ret;
    BOOL documentWindow = [appName isEqualToString:@"Microsoft PowerPoint"];
    
    NSString *windowTitle = [[title lastPathComponent] stringByDeletingPathExtension];
    NSString *siblingWindowTitle = (siblingTitle == nil) ? @"" : [[siblingTitle lastPathComponent] stringByDeletingPathExtension];
    
    NSString *resizeWin = needResize ? [NSString stringWithFormat:@"set the bounds of win to {%f, %f, %f, %f}", x, y + 1, x + w, y + h + 1] : @"";
    
    NSString *source = siblingTitle == nil ? [NSString stringWithFormat:@" \
                                              \nset ret to 0 \
                                              \ntell application \"%@\" \
                                              \ntry \
                                              \nrepeat with i from 1 to (count of %@ windows) \
                                              \nset win to %@ window i \
                                              \nif name of win contains \"%@\" then \
                                              \n%@ \
                                              \ntell win to set active to true \
                                              \nset ret to 1 \
                                              \nelse \
                                              \nset miniaturized of win  to true\
                                              \ntell win to set collapsed to true \
                                              \nend if\
                                              \nend repeat \
                                              \nend try \
                                              \nend tell \
                                              \nget ret", processName, documentWindow ? @"document" : @"", documentWindow ? @"document" : @"", windowTitle, resizeWin]
    : [NSString stringWithFormat:@" \
       \nset ret to 0 \
       \ntell application \"%@\" \
       \ntry \
       \nrepeat with i from 1 to (count of %@ windows) \
       \nset win to %@ window i \
       \nif name of win contains \"%@\" then \
       \n%@ \
       \ntell win to set active to true \
       \nset ret to 1 \
       \nelse \
       \nerror number -128 \
       \nif not name of win contains \"%@\"  \
       \nset miniaturized of win to true\
       \ntell win to set collapsed to true \
       \nend if\
       \nend if\
       \nend repeat \
       \nend try \
       \nend tell \
       \nget ret", processName, documentWindow ? @"document" : @"", documentWindow ? @"document" : @"", windowTitle, resizeWin, siblingWindowTitle];
    
    NSDictionary *errorDictionary;
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorDictionary];
    
    DLog(@"AppleScript execute script:\n%@\n", source);
    
    if (!result)
    {
        DLog(@"Error execute script: %@. \n", errorDictionary);
        
        ret = -1;
    }
    else
    {
        NSData *data = [result data];
        [data getBytes:&ret length:data.length];
    }
    
    return ret;
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


@implementation AppleScript

@end
