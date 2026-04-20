#Requires AutoHotkey v2.0
#SingleInstance Force

Persistent()
SetWorkingDir(A_ScriptDir)

IconPath := A_ScriptDir . "\lib\app.ico"
if FileExist(IconPath) {
    TraySetIcon(IconPath)
}

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

SyncDesktop(currentName) {
    allNames := []
    pendingLinks := []

    count := GetDesktopCount()
    loop count {
        name := GetDesktopName(A_Index - 1)
        if (name != "")
            allNames.Push(name)
    }

    ; remove old links
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

    ; add mklink command to queue
    QueueLink(source, target) {
        if FileExist(target)
            return
        SplitPath(source, , , &ext)
        if (StrLower(ext) = "lnk") {
            try FileCopy(source, target, 0)
            return
        }
        isDir := InStr(FileGetAttrib(source), "D") ? "/D " : ""
        pendingLinks.Push('mklink ' . isDir . '"' . target . '" "' . source . '"')
    }

    loop files Config.DesktopDataDir "\*", "D" {
        if (A_LoopFileName = currentName) {
            loop files A_LoopFileFullPath "\*", "FD" {
                QueueLink(A_LoopFileFullPath, Config.RealDesktop "\" A_LoopFileName)
            }
        } else {
            isSpecial := False
            for name in allNames {
                if (A_LoopFileName = name) {
                    isSpecial := True
                    break
                }
            }
            if !isSpecial
                QueueLink(A_LoopFileFullPath, Config.RealDesktop "\" A_LoopFileName)
        }
    }

    loop files Config.DesktopDataDir "\*", "F" {
        QueueLink(A_LoopFileFullPath, Config.RealDesktop "\" A_LoopFileName)
    }

    ; create new links
    if (pendingLinks.Length > 0) {
        batchCommand := ""
        for i, cmd in pendingLinks {
            batchCommand .= cmd . (i = pendingLinks.Length ? "" : " & ")
        }
        RunWait(A_ComSpec . ' /c ' . batchCommand, , "Hide")
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
