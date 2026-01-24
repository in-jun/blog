---
title: "Installing Wine on Ubuntu 24.04 LTS"
date: 2025-02-23T04:51:24+09:00
draft: false
description: "Installing and configuring Wine on Ubuntu 24.04 LTS."
tags: ["Linux", "Ubuntu", "Wine"]
---

## Wine Concept and How It Works

Wine (Wine Is Not an Emulator) is a compatibility layer that enables Windows programs to run on UNIX-compatible operating systems such as Linux, macOS, and BSD, including Ubuntu 24.04 LTS. It is an open-source project started by Bob Amstadt and Eric Youngdale in 1993, with over 30 years of development history. The name Wine is a recursive acronym meaning "Wine Is Not an Emulator," chosen to emphasize that Wine is not a simple emulator.

Wine works fundamentally differently from virtual machines or emulators. It translates Windows API calls in real-time to POSIX-compatible system calls. While virtualization software like VirtualBox or VMware runs a complete Windows operating system in a virtual environment and consumes significant system resources, Wine translates API (Application Programming Interface) functions called by Windows programs into a form that the Linux system can understand, providing near-native performance. For example, when a Windows program calls the `CreateFile` function to open a file, Wine converts it to the Linux `open` system call and executes it.

### Key Features and Benefits of Wine

Wine operates without requiring a separate virtual machine or Windows license, efficiently using system resources with less memory usage and faster program execution compared to virtualization methods. It supports graphics APIs such as DirectX, OpenGL, and Vulkan, enabling Windows games to run. Valve's Proton (based on Wine) has made many Steam games playable on Linux. Various Windows-only programs such as Microsoft Office, Adobe products, and business software can be used on Ubuntu, making Wine an essential tool for users considering switching to Linux.

### Limitations of Wine

Not all Windows programs work perfectly in Wine. Programs that require kernel-level drivers (games with anti-cheat systems, programs that directly control hardware) or programs using the latest Windows APIs may not run or may encounter errors. The Wine project continuously improves Windows API compatibility, but the Wine development team faces the challenge of keeping up with each new Windows version released by Microsoft. You can check the Wine compatibility of specific programs in the WineHQ database (https://www.winehq.org/search), where each program is rated as Platinum (perfect), Gold (perfect after configuration), Silver (minor issues), Bronze (serious issues), or Garbage (cannot run).

## Installing Wine on Ubuntu 24.04 LTS

### 1. System Preparation

Before starting the Wine installation, it is important to update the system to the latest state. This refreshes package repository information and upgrades existing packages to prevent dependency conflicts.

```bash
sudo apt update
sudo apt upgrade
```

`apt update` refreshes package repository metadata to fetch the latest package lists, and `apt upgrade` upgrades installed packages to their latest available versions.

#### Enable 32-bit Architecture Support

Many Windows programs and games are compiled as 32-bit, so you must enable multi-architecture support to install and run 32-bit libraries on 64-bit Ubuntu 24.04 LTS. Ubuntu has only the 64-bit (amd64) architecture enabled by default, and the i386 (32-bit) architecture must be manually added.

```bash
sudo dpkg --add-architecture i386
```

This command adds the i386 architecture to the dpkg package management system, allowing you to install 32-bit packages with the `apt` command. Wine internally uses numerous 32-bit libraries, making this step essential. Skipping it will cause dependency errors during Wine installation.

### 2. Adding the WineHQ Official Repository

While Ubuntu's default repository includes Wine, using the WineHQ official repository allows you to choose between the latest stable version and development versions, and receive faster updates. WineHQ is the official website and repository of the Wine project, providing three versions of Wine: Stable, Development, and Staging.

#### Add GPG Key

You must add WineHQ's GPG (GNU Privacy Guard) public key to the system to verify the trustworthiness of the package repository. This confirms that the packages you download are genuine and signed by WineHQ, preventing man-in-the-middle attacks or malicious package installations.

```bash
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
```

The first command creates the `/etc/apt/keyrings` directory, with the `-p` option creating parent directories and the `-m755` option setting appropriate permissions. The second command downloads WineHQ's GPG key and saves it to that directory. Since Ubuntu 24.04, using the `/etc/apt/keyrings` directory is recommended for enhanced security.

#### Add Wine Repository File

Add WineHQ repository information to the system. The `lsb_release -sc` command automatically detects the codename (noble) of the current Ubuntu version and configures the repository for that version.

```bash
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources
```

For Ubuntu 24.04 LTS (codename: noble), this command downloads the `winehq-noble.sources` file. The `-N` option downloads only when the server's file is newer, and the `-P` option specifies the save location. The downloaded `.sources` file uses the DEB822 format to describe repository information, which is the modern repository management method introduced in Ubuntu 22.04 and later.

### 3. Installing Wine

Since you added a new repository, update the package list again to fetch package information from the WineHQ repository, then install the stable version of Wine.

```bash
sudo apt update
sudo apt install --install-recommends winehq-stable
```

The `apt update` command refreshes package metadata for all repositories, including the newly added WineHQ repository. `winehq-stable` refers to WineHQ's stable version package. The `--install-recommends` option instructs apt to install additional packages recommended by Wine, including Mono (Windows .NET Framework compatibility), Gecko (Internet Explorer compatibility), graphics drivers, and audio libraries necessary for most Windows programs to work properly.

#### Choosing a Wine Version

WineHQ provides three versions of Wine, each with a different balance between stability and cutting-edge features.

-   **winehq-stable**: The stable version undergoes thorough testing before release and is recommended for production environments or general users. It may lack the latest features but guarantees stability.
-   **winehq-devel**: The development version includes the latest features and bug fixes but may introduce new bugs, making it suitable for testing purposes or users who need the latest features.
-   **winehq-staging**: The experimental version includes experimental patches not yet merged into the main branch and should only be used when needed for specific game or program compatibility.

Generally, installing `winehq-stable` is the safest choice. You can switch to other versions later with commands like `sudo apt install winehq-devel`.

### 4. Wine Initial Configuration

Once Wine installation is complete, you must initialize the Wine environment and configure settings. Use the `winecfg` command to launch the Wine configuration tool.

```bash
winecfg
```

When you run this command for the first time, Wine creates a `~/.wine` directory in your home directory and builds the default Windows environment. This directory is called a Wine prefix and includes a virtual file system corresponding to Windows' `C:\` drive and registry files. Wine creates directory structures such as `C:\windows`, `C:\Program Files`, and `C:\users` to provide the environment expected by Windows programs, and the files and settings installed by each program are stored within this prefix.

![Wine Configuration Screen](image-2.png)

#### Key Options in Wine Configuration Tool

The winecfg configuration window allows you to adjust various options, with each tab managing settings for specific areas.

-   **Applications tab**: Configure the Windows version. You can select which version Wine should emulate (Windows XP, Vista, 7, 8, 10, or 11). Some programs require specific Windows versions, so you can set different versions for different programs.
-   **Libraries tab**: Set the loading order for DLL (Dynamic Link Library) files. You can choose whether to use Wine's built-in DLLs or native Windows DLLs. Some programs require specific DLLs to run in native mode for proper operation, making this setting important.
-   **Graphics tab**: Adjust screen resolution, virtual desktop mode, and DPI settings. Enabling virtual desktop mode makes Windows programs run in a separate window, isolated from the Linux desktop.
-   **Audio tab**: Select the audio driver. Options include ALSA, PulseAudio, and OSS. On Ubuntu 24.04, using PulseAudio or PipeWire is typical.

### 5. DirectX Library Configuration

Many Windows programs and games use DirectX to render graphics. DirectX is a collection of multimedia and game programming APIs developed by Microsoft, consisting of components such as Direct3D, DirectSound, and DirectInput. Wine partially supports DirectX, but some DirectX DLL files must be configured to load explicitly. The `d3dx11_43.dll` file related to Direct3D 11 is particularly essential for many modern games and 3D applications.

#### Configure DirectX DLL Override

Configuring specific DLLs to load in native mode in Wine settings improves compatibility by directly using Windows DLLs. Follow these steps for configuration.

1. Launch the Wine configuration tool.

```bash
winecfg
```

2. Navigate to the "Libraries" tab.
3. In the "New override for library" dropdown menu, enter or select `d3dx11_43`.

![Wine Configuration Screen](image-3.png)

4. Click the "Add" button to add it to the override list.
5. Click "Apply" and save the settings with "OK".

With this configuration, Wine loads `d3dx11_43.dll` in Native then Builtin mode, meaning it first tries to use the original Windows DLL and falls back to Wine's built-in implementation if unavailable.

#### Install Additional DirectX Components

To use more DirectX features, you can install additional components using Winetricks. Winetricks is a script tool that automatically installs libraries and settings frequently needed in Wine.

```bash
sudo apt install winetricks
winetricks d3dx9 d3dx10 d3dx11_43 dxvk
```

This command installs core libraries for DirectX 9, 10, and 11, along with DXVK (a layer that converts DirectX to Vulkan). DXVK is known to significantly improve performance for DirectX 11 and 12 games.

### 6. Running Windows Programs

Once Wine configuration is complete, you can directly run Windows executable files (.exe). You can specify the program path with the `wine` command in the terminal or double-click in the file manager to execute.

```bash
wine program.exe
```

For example, to run a `setup.exe` installation file in the Downloads folder, enter the following.

```bash
wine ~/Downloads/setup.exe
```

When a program is installed, Wine automatically installs it in the `~/.wine/drive_c/Program Files` directory. Installed programs create shortcuts in the menu or on the desktop, allowing execution with just a click next time.

#### Command-line Options and Environment Variables

Wine supports various environment variables and options to control program execution. Representative environment variables include the following.

-   **WINEPREFIX**: Specifies the Wine prefix path, allowing use of multiple independent Wine environments.

```bash
WINEPREFIX=~/.wine-custom wine program.exe
```

-   **WINEDEBUG**: Controls debug message output. Setting to `-all` hides all debug messages.

```bash
WINEDEBUG=-all wine program.exe
```

-   **WINEARCH**: Specifies Wine architecture, where `win32` means 32-bit and `win64` means 64-bit.

```bash
WINEARCH=win32 WINEPREFIX=~/.wine32 winecfg
```

#### Running from File Manager

Double-clicking an `.exe` file in Ubuntu's file manager (Nautilus) automatically launches Wine because Wine installation automatically sets up file associations. If double-clicking doesn't work, right-click the file, select "Open with another application," and choose Wine.

## Troubleshooting

### When Programs Don't Run

If a program doesn't run or encounters errors, you can try the following methods.

-   **Check WineHQ AppDB**: Visit https://appdb.winehq.org to check compatibility information and special settings for the program.
-   **Change Windows Version**: Change to a different Windows version setting in `winecfg`.
-   **DLL Override**: Configure specific DLLs to load in native mode.
-   **Check Debug Logs**: Generate detailed logs with `WINEDEBUG=+all wine program.exe 2>&1 | tee wine.log` to identify the error cause.

### When Korean Characters Are Broken

If Korean characters appear broken in Windows programs, installing Windows Korean fonts solves the problem.

```bash
winetricks corefonts cjkfonts
```

This command installs Windows default fonts and CJK (Chinese, Japanese, Korean) fonts in the Wine environment.

### When Performance Is Slow

If a program or game has slow performance, installing DXVK to convert DirectX to Vulkan can significantly improve performance.

```bash
winetricks dxvk
```

## Conclusion

Installing Wine on Ubuntu 24.04 LTS enables Windows-only programs to run in a Linux environment. You can use business software, games, and utilities without a virtual machine, lowering the barrier to Linux adoption. Wine is a mature project with over 30 years of development history, continuously improving Windows API compatibility and actively used in gaming through Valve's Proton. While not all Windows programs work perfectly, most programs can be run with appropriate settings and additional component installation. The WineHQ AppDB and community can greatly help resolve compatibility issues with specific programs.
