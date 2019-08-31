#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
Global TargetDir
Global YesDelete := True
Global BitRate := 192
; Common bitrates:
; 192
; 224
; 256
; 320 - Near lossless

Loop %0%  ; For each parameter (or file dropped onto a script):
{
    IfInString, %A_Index%, lidarr 
    {
        EnvGet, TargetDir, %A_Index%
    }
    Else
        TargetDir := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
    Gosub, ProcessFolder
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
    StringReplace, o, file, flac, mp3
    If !(%0%)
       ToolTip % "Original Filename: " file "`nConverted MP3 Name: " o
    runwait, ffmpeg  -i "%file%" -ab %BitRate%k -map_metadata 0 -id3v2_version 3 "%o%" , ,Hide
    If YesDelete
        FileDelete, %file%
    If !(%0%)
        ToolTip
}
If !(%0%)
    MsgBox Completed conversion!
Return

GuiClose:
ExitApp
