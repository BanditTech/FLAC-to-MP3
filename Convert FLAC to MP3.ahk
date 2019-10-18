#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%
Global spc := 0
Global TargetDir, file
Global YesDelete := True
Global YesLog := True
Global ShowGui := False
Global Log := "ConvertFtoM.log"
Global MusicFolder := "D:\Media\Music"
Global BitRate := 320
; Common bitrates:
; 192
; 224
; 256
; 320 - Near lossless

EnvGet, EventType, lidarr_eventtype
EnvGet, ArtistPath, lidarr_artist_path
FileAppend, %A_YYYY%-%A_MM%-%A_DD% Script Started - %EventType% - %ArtistPath%`n, %Log%
If (EventType="Test")
    ExitApp
Else If (EventType="AlbumDownload")
{
    TargetDir := ArtistPath
    GoSub, ProcessFolder
    ExitApp
}
Else If (EventType="Download")
{
    TargetDir := ArtistPath
    GoSub, ProcessFolder
    ExitApp
}


If YesLog
{
    FileRead, LogFile, %Log%
    Loop, Parse, LogFile , `n
    {
        IfInString, A_LoopField, %A_YYYY%-%A_MM%-%A_DD%
        {
            LogString := LogString . A_LoopField
        }
    }
    FileDelete, %Log%
    FileAppend, %LogString%, %Log%
}

Loop %0%  ; For each parameter (or file dropped onto a script):
{
    TargetDir := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
    Gosub, ProcessFolder
}
If (%0%)
    ExitApp

If ShowGui
{
Gui, Show, w220 h70
Gui, add, Button, gSelectFolder w200,Select New Folder
Gui, add, Button, gProcessFolder w200,Run!
}
Else
{
TargetDir := MusicFolder
GoSub, ProcessFolder
ExitApp
}

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
            FileAppend, %A_YYYY%-%A_MM%-%A_DD% Started Conversion, %Log%
        runwait, ffmpeg -y -i "%file%" -ab %BitRate%k -map_metadata 0 -id3v2_version 3 -y "%o%" , ,Hide
        If YesLog
        {
            FileGetSize, fs, %file%, M
            FileGetSize, os, %o%, M
            sp := fs - os
            spc += sp
            FileAppend, %A_Tab%Old: %fs%MB%A_Tab%New: %os%MB%A_Tab%Dif: %sp%MB%A_Tab%%file% CONVERTED TO %o%`n, %Log%
        }
        If (YesDelete)
            FileDelete, %file%
    }
    If spc > 0
        FileAppend, %A_YYYY%-%A_MM%-%A_DD% Completed Conversion - Total saved space: %spc%MB `n, %Log%
    Else
        FileAppend, %A_YYYY%-%A_MM%-%A_DD% Nothing Converted`n, %Log%
Return

GuiClose:
ExitApp
