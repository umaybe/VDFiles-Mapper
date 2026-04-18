# VDFiles-Mapper <img src="./lib/app.ico" alt="VDFiles-Mapper" width="4%">

## 🌟 Introduction
VDFiles-Mapper(*Virtual Desktop Files Mapper*) is a lightweight AutoHotkey v2 script for Windows 11, allowing you to have a unique set of files and folders for every virtual desktop.

## 📂 How It Works

VDFiles-Mapper utilizes a **Repository-to-View** logic with a built-in filter for global items:

1. **The Repository** (D:\DesktopData): This is your central storage.

2. **Mapping Logic**:

   - **Desktop-Specific Folders**: Any folder in the repository whose name **matches** an active Virtual Desktop (e.g., a folder named "Work" for a desktop named "Work") is considered a Private Container. Its contents are linked to the desktop.

   - **Global/Public Items**: Any file or folder in the repository whose name **does not match** any existing Virtual Desktop name is treated as a Global Item. These items will appear on every virtual desktop.

   - **Smart Linking**: The script automatically detects .lnk files (shortcuts) and performs a **direct copy** instead of a symlink to ensure icon stability and proper path resolution.

3. **The Mapping Process**: When switching to a desktop (e.g., "Work"):

   - The script links all **Global Items** first.

   - Then, it "projects" the **contents** of the "Work" folder specifically.

4. The Cleanup: Upon switching, the script safely removes only the symlinks, leaving the source files in the repository and any native files on your desktop untouched.

## 🛠️ Quick Start

1. Prerequisites

   - AutoHotkey v2.0+ installed.

   - VirtualDesktopAccessor.dll placed in the \lib folder relative to the script.

2. Setup the Repository

    - Create a folder at D:\DesktopData.

   - Create subfolders named exactly after your Virtual Desktops (e.g., if your desktop is named "Dev", create D:\DesktopData\Dev).

3. Run the Script

   - Run VDFiles-Mapper.ahk.

## 📜license

This project is licensed under the MIT License.

*Special thanks to the [VirtualDesktopAccessor.dll](https://github.com/Ciantic/VirtualDesktopAccessor) contributors for providing the low-level API hooks.*
