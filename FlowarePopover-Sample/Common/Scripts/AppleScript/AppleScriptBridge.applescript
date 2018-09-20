
script ScriptHandler
    
    property parent : class "NSObject"
    -- Open file at Path function
    on testFunction_()
        display dialog "Hey Guy"
    end testFunction_
    
    on openFileAtPath_(pathName)
        set newFileName to pathName as string
        set newFile to (newFileName as POSIX file)
        tell application "Finder" to open newFile
    end openFileAtPath_
    
    -- resize Windows with Title and rect
    
    on resizeWindowWithTitle:title setWidth:width setHeight:height setX:x setY:y
        -- lookup which window has name like file -> resize it\
        set asWidth to width as integer
        set asHeight to height as integer
        set asX to x as integer
        set asY to y as integer
        set theTitle to title as string
        local flag
        set flag to "NO"
        tell application "System Events"
            repeat until flag is equal to "YES"
            repeat with theProcess in processes
                if not background only of theProcess then
                    tell theProcess
                        set processName to name
                        set theWindows to windows whose name contains theTitle
                    end tell
                    repeat with theWindow in theWindows
                        set windowTitle to name of theWindow
                            tell theWindow
                                set {size, position} to {{asWidth, asHeight}, {asX, asY}}
                                set flag to "YES"
                            end tell
                    end repeat
                   
                end if
            end repeat
            end repeat
        end tell
    end resizeWindowWithTitle:setWidth:setHeight:setX:setY:
    
    -- open application with app name and app id
    on openApplication:appName appID:appID setWidth:width setHeight:height setX:x setY:y
        set asWidth to width as integer
        set asHeight to height as integer
        set asX to x as integer
        set asY to y as integer
        set asAppName to appName as string
        set asAppID to appID as string
        tell application asAppName
        reopen
        activate
        end tell
        tell application "System Events"
            set appProc to item 1 of (processes whose bundle identifier is asAppID)
            tell appProc
                set processName to name
                set theWindow to the first windows
            end tell
        
            tell theWindow
                set {size, position} to {{asWidth, asHeight}, {asX, asY}}
            end tell
        end tell
        
    end openApplication: appID: setWidth: setHeight: setX: setY:
end script