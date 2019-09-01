#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%
Global TargetDir, file
Global YesDelete := True
Global YesLog := True
Global BitRate := 192
; Common bitrates:
; 192
; 224
; 256
; 320 - Near lossless
If YesLog
{
    FileRead, LogFile, ConvertFtoMLog.txt
    Loop, Parse, LogFile , `n
    {
        IfInString, A_LoopField, %A_YYYY%-%A_MM%-%A_DD%
        {
            LogString := LogString . A_LoopField
        }
    }
    FileDelete, ConvertFtoMLog.txt
    FileAppend, %LogString%, ConvertFtoMLog.txt
}

Loop %0%  ; For each parameter (or file dropped onto a script):
{
    IfInString, %A_Index%, lidarr_artist_path
    {
        EnvGet, TargetDir, lidarr_artist_path
        if YesLog
            FileAppend, %A_YYYY%-%A_MM%-%A_DD%  %TargetDir%     lidarr_artist_path`n, ConvertFtoMLog.txt
        Gosub, ProcessFolder
    }
    Else IfInString, %A_Index%, lidarr_trackfile_path
    {
        EnvGet, file, lidarr_trackfile_path
        IfInString, file, .mp3
        {
            ExitApp
        }
        if YesLog
           FileAppend, %A_YYYY%-%A_MM%-%A_DD%  %file%     lidarr_trackfile_path`n, ConvertFtoMLog.txt
        Gosub, ProcessFile
    }
    Else
    {
        TargetDir := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
        Gosub, ProcessFolder
    }
}
If (%0%)
    ExitApp


Gui, Show, w220 h70
Gui, add, Button, gSelectFolder w200,Select New Folder
Gui, add, Button, gProcessFolder w200,Run!
Return

SelectFolder:
FileSelectFolder, TargetDir
SetWorkingDir %TargetDir%  ; Ensures a consistent starting directory.
Return

ProcessFolder:
FLACList:={}
Loop, Files, %TargetDir%\*.flac, R
{
    FLACList[A_LoopFileLongPath] := A_LoopFileDir
}
for file in FLACList
{
    fileArr := StrSplit(file, A_Space, , 1)
    file := fileArr[1]
    StringReplace, o, file, flac, mp3
    If YesLog
        FileAppend, %A_YYYY%-%A_MM%-%A_DD%  %file%  Converted To   %o%`n, ConvertFtoMLog.txt
    runwait, ffmpeg -y -i "%file%" -ab %BitRate%k -map_metadata 0 -id3v2_version 3 -y "%o%" , ,Hide
    If (YesDelete)
        FileDelete, %file%
}
If !(%0%)
    MsgBox Completed conversion!
Return

ProcessFile:
    StringReplace, o, file, flac, mp3
    If (FileExist("%o%"))
        FileDelete, %o%
    If YesLog
        FileAppend, %A_YYYY%-%A_MM%-%A_DD% %file%   Converted To    %o%`n, ConvertFtoMLog.txt
    runwait, ffmpeg -y -i "%file%" -ab %BitRate%k -map_metadata 0 -id3v2_version 3 -y "%o%" , ,Hide
    If (YesDelete)
        FileDelete, %file%
Return

GuiClose:
ExitApp
