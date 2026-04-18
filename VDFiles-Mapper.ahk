#Requires AutoHotkey v2.0
#SingleInstance Force

Persistent()
SetWorkingDir(A_ScriptDir)
TraySetIcon("shell32.dll", 162)

VDA_PATH := A_ScriptDir . "\lib\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall(
    "LoadLibrary",
    "Str", VDA_PATH,
    "Ptr"
)
GetDesktopNameProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "GetDesktopName",
    "Ptr"
)
GetCurrentDesktopNumberProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "GetCurrentDesktopNumber",
    "Ptr"
)
RegisterPostMessageHookProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "RegisterPostMessageHook",
    "Ptr"
)
GetDesktopCountProc := DllCall(
    "GetProcAddress",
    "Ptr", hVirtualDesktopAccessor,
    "AStr", "GetDesktopCount",
    "Ptr"
)

Config := {
    DesktopDataDir: "D:\DesktopData",
    RealDesktop: A_Desktop
}

GetDesktopCount() {
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

GetDesktopName(num) {
    utf8_buffer := Buffer(1024, 0)
    ran := DllCall(
        GetDesktopNameProc,
        "Int", num,
        "Ptr", utf8_buffer,
        "Ptr", utf8_buffer.Size,
        "Int"
    )
    name := StrGet(utf8_buffer, 1024, "UTF-8")
    return name
}

CreateLink(source, target) {
    if FileExist(target)
        return

    SplitPath(source, , , &ext)
    if (StrLower(ext) = "lnk") {
        try {
            FileCopy(source, target, 0)
        }
        return
    }

    isDir := InStr(FileGetAttrib(source), "D") ? 1 : 0
    cmdParam := ' /c mklink ' . (isDir ? '/D ' : '') . ' "' . target . '" "' . source . '"'
    RunWait(A_ComSpec . cmdParam, , "Hide")
}

LinkContents(dir) {
    loop files, dir "\*", "FD" {
        CreateLink(A_LoopFileFullPath, Config.RealDesktop "\" A_LoopFileName)
    }
}

SyncDesktop(currentName) {
    allNames := []
    count := GetDesktopCount()
    loop count {
        name := GetDesktopName(A_Index - 1)
        if (name != "")
            allNames.Push(name)
    }

    loop files Config.RealDesktop "\*", "FD" {
        attrib := FileGetAttrib(A_LoopFileFullPath)
        SplitPath(A_LoopFileFullPath, , , &ext)

        if InStr(attrib, "L") || (StrLower(ext) = "lnk") {
            try {
                if InStr(attrib, "D")
                    DirDelete(A_LoopFileFullPath)
                else
                    FileDelete(A_LoopFileFullPath)
            }
        }
    }

    loop files Config.DesktopDataDir "\*", "D" {
        folderName := A_LoopFileName
        folderPath := A_LoopFileFullPath

        if (folderName = currentName) {
            LinkContents(folderPath)
        }
        else {
            isSpecial := False
            for name in allNames {
                if (folderName = name) {
                    isSpecial := True
                    break
                }
            }
            if !isSpecial {
                CreateLink(A_LoopFileFullPath, Config.RealDesktop "\" A_LoopFileName)
            }
        }
    }

    loop files Config.DesktopDataDir "\*", "F" {
        CreateLink(A_LoopFileFullPath, Config.RealDesktop "\" A_LoopFileName)
    }
}

DllCall(
    RegisterPostMessageHookProc,
    "Ptr", A_ScriptHwnd,
    "Int", 0x1400 + 30,
    "Int"
)
OnMessage(0x1400 + 30, OnChangeDesktop)
OnChangeDesktop(wParam, lParam, msg, hwnd) {
    Critical(1)
    OldDesktop := wParam + 1
    NewDesktop := lParam + 1
    Name := GetDesktopName(NewDesktop - 1)
    SyncDesktop(Name)
}

CurrentNumber := DllCall(GetCurrentDesktopNumberProc, "Int")
if (CurrentNumber != -1) {
    SyncDesktop(GetDesktopName(CurrentNumber))
}
