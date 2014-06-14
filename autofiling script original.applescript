-- Adapted from a copyrighted script by Mark Hunte 2013 
-- http://www.markosx.com/thecocoaquest/automatically-save-attachments-in-mail-app/
-- Changed script to parse out the first part of the email address as the folder name, eliminated time stamp folder
-- Changed to run as triggered script vs email rule
-- explanation of what and why at scrubbs.me


-- set up the attachment folder path

tell application "Finder"
    set folderName to "Attachments"
    set homePath to (path to home folder as text) as text
    set attachmentsFolder to (homePath & folderName) as text
end tell


tell application "Mail"
    
    set theMessages to selection
    repeat with eachMessage in theMessages
        
        -- set the sub folder for the attachments to the first part of senders email before a period
        -- All future attachments from this sender will the be put here.
        -- parse email name by @ and . to get to first part of email name
        
        set subName to (sender of eachMessage)
        set AppleScript's text item delimiters to "<"
        set fName to text item 2 in subName
        set AppleScript's text item delimiters to "@"
        set fName to text item 1 in fName
        set AppleScript's text item delimiters to "."
        set subFolder to text item 1 in fName
        
        
        -- use the unix /bin/test command to test if the timeStamp folder  exists. if not then create it and any intermediate directories as required
        if (do shell script "/bin/test -e " & quoted form of ((POSIX path of attachmentsFolder) & "/" & subFolder) & " ; echo $?") is "1" then
            -- 1 is false
            do shell script "/bin/mkdir -p " & quoted form of ((POSIX path of attachmentsFolder) & "/" & subFolder)
            
        end if
        try
            -- Save the attachment
            repeat with theAttachment in eachMessage's mail attachments
                
                set originalName to name of theAttachment
                set savePath to attachmentsFolder & ":" & subFolder & ":" & originalName
                try
                    save theAttachment in file (savePath)
                end try
            end repeat
        end try
    end repeat
    
end tell