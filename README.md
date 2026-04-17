# VDFiles-Mapper

## 🌟 Introduction
VDFiles-Mapper(*Virtual Desktop Files Mapper*) is a lightweight AutoHotkey v2 script for Windows 11, allowing you to have a unique set of files and folders for every virtual desktop.

## 📂 How It Works

VDFiles-Mapper utilizes a Repository-to-View logic:

1. **The Repository** (e.g. `D:\DesktopData`): You store your actual folders here (e.g., `Work`, `Gaming`, `Thesis`).

2. **The Mapping**: When you switch to a Virtual Desktop named "Work," the script identifies the matching folder in your repository and "projects" its content onto your actual desktop as symlinks.

3. **The Cleanup**: Upon switching, the script identifies and removes symlinks from the previous session, keeping the desktop pristine.

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
