---
title: "Maximizing Productivity with i3wm Tiling Window Manager"
date: 2025-05-05T22:01:34+09:00
draft: false
description: "Installing and configuring the i3 tiling window manager."
tags: ["Linux", "i3wm", "Productivity"]
---

## Meeting i3wm: A Choice for Productivity

![i3wm basic layout](image.png)

The i3 window manager (i3wm) is a tiling window manager focused on efficiency and productivity. It was first developed in 2009 by German developer Michael Stapelberg to overcome the limitations of the existing wmii window manager. The name "i3" stands for "improved tiling wm". Written in C with approximately 10,000 lines of concise code, i3 provides lightweight yet powerful functionality. It has gained significant popularity among developers, system administrators, and power users who prefer keyboard-only workflows with minimal mouse usage. It shows particularly high adoption rates among Arch Linux, Gentoo, and NixOS users.

i3 operates in the traditional X Window System (X11) environment and runs independently of the X Display Manager, making it compatible with any login manager such as LightDM, GDM, or SDDM. Recently, Sway (an i3-compatible Wayland compositor) has been developed to support the next-generation display server protocol Wayland. It is now widely used, leveraging Wayland's improved security and performance while maintaining nearly identical i3 configuration and key bindings. i3's design philosophy follows the Unix philosophy of "do one thing and do it well". It completely eliminates unnecessary visual decorations and animation effects, maximizes screen space utilization for actual work content, and provides multi-monitor support, efficient window management, and highly customizable text-based configuration files.

i3wm is renowned for its exceptional official documentation among open-source projects. All features and configuration options are clearly and systematically documented, allowing even beginners new to tiling window managers to learn step-by-step and build their own environment. The official documentation is available at [i3wm.org/docs](https://i3wm.org/docs/) and covers various topics including User's Guide, Configuration Reference, and IPC Protocol. Active information exchange also takes place in community forums and Reddit's r/i3wm subreddit.

### Philosophy and Structure of the Tiling System

![i3wm tiling layout example](image-1.png)

The most fundamental and core feature of i3wm is its 'tiling' window arrangement method. This is a fundamentally different approach from traditional stacking window managers like GNOME, KDE Plasma, Windows, and macOS. In stacking window managers, windows can overlap each other and users must manually adjust window positions and sizes. This requires essential mouse usage and causes inefficiency where significant screen space is unused or obscured. In contrast, i3 logically divides the screen and automatically arranges windows so all windows are non-overlapping and maximize screen space utilization. Users can focus solely on their work content without worrying about window placement.

**Key tiling characteristics of i3:**

-   **Automatic Layout**: When a new window opens, i3 automatically divides existing space and places the new window. There's no need to manually resize or reposition windows, and all windows are always fully visible on screen.

-   **Directional Split**: You can specify horizontal or vertical splitting to control where the next window will be placed relative to the current window. Complex layouts can be easily composed by combining these splits.

-   **Ratio Adjustment**: The boundaries between split windows can be adjusted with keyboard or mouse to freely change the space ratio each window occupies. Precise adjustments can be made in 10px or 10% increments.

-   **Layout Switching**: In addition to tiling mode, stacking and tabbed modes are supported. You can switch instantly with a single key to select the optimal layout for each situation, and different layouts can be applied per container.

i3's tiling algorithm is based on a binary tree data structure, an elegant design that applies computer science data structures to window arrangement. Each time a user opens a new window, the space occupied by the currently focused window is split as a tree node into two parts: one for the existing window and one for the new window. The split direction (horizontal or vertical) is either explicitly specified by the user or determined by i3's default behavior mode. Thanks to this tree structure, i3 can manage even very complex layouts in a consistent manner. The parent-child relationships between windows are clear, ensuring logically predictable behavior when moving or removing windows.

## Installing i3wm

i3wm is included in the official repositories of most major Linux distributions and can be easily installed through package managers. Distributions provide various package names such as `i3`, `i3-wm`, and `i3-gaps` (a fork version with inter-window gap support).

**Debian/Ubuntu-based**: The `sudo apt install i3` command installs basic components including i3-wm, i3status, and i3lock. It's recommended to also install `dmenu` or `rofi` (application launcher), `feh` or `nitrogen` (wallpaper setting), and `compton` or `picom` (compositor).

**Fedora**: Install with `sudo dnf install i3`. Fedora provides the i3-with-shmlog version by default and supports debugging through IPC sockets.

**Arch Linux**: Install with `sudo pacman -S i3-wm` or `sudo pacman -S i3-gaps`. Arch users can utilize various i3-related packages and themes through the AUR (Arch User Repository). The `i3-gnome` package allows using i3 together with GNOME.

After installation, log out and select the i3 session from the login screen to start i3. At first launch, a setup wizard automatically appears asking whether to create a configuration file (`~/.config/i3/config`) and to set up the mod key. The mod key is the core modifier key used in all i3 shortcuts. You typically choose between Alt (Mod1) or the Windows/Super key (Mod4). Personally, I recommend the Windows key (Mod4) because the Alt key is already used by many applications for shortcuts, which can cause conflicts.

![i3wm first run screen](image-2.png)

## Basic Key Combinations

Since i3wm provides a keyboard-centric environment, it's important to learn the basic key combinations.

![i3wm keyboard shortcuts reference-1](image-3.png)
![i3wm keyboard shortcuts reference-2](image-4.png)

### Basic Control

-   **$mod + Enter**: Launch the default terminal
-   **$mod + d**: Open the application launcher menu
-   **$mod + Shift + q**: Close the current window
-   **$mod + Shift + r**: Reload i3 configuration
-   **$mod + Shift + e**: Open i3 exit menu
-   **$mod + Shift + c**: Reload i3 configuration file

### Window Management

-   **$mod + j/k/l/;**: Move focus left/down/up/right (default)
-   **$mod + Shift + j/k/l/;**: Move current window left/down/up/right
-   **$mod + f**: Toggle fullscreen for current window
-   **$mod + h**: Horizontal split for next window
-   **$mod + v**: Vertical split for next window
-   **$mod + r**: Resize mode
-   **$mod + space**: Toggle between tiling and floating mode

Unlike vim, i3wm uses `jkl;` as directional keys by default. This design considers the natural position of the right hand on the keyboard home row, but may feel unfamiliar to users accustomed to vim. If needed, you can change to `hjkl` style in the configuration file (`~/.config/i3/config`). Personally, since I've been using `hjkl` as directional keys in vim, tmux, and many CLI tools, I found changing to `hjkl` in i3 much more intuitive and convenient. It allows maintaining consistent muscle memory with minimal transition cost.

### Workspace Management

-   **$mod + number(1-0)**: Switch to the workspace with that number
-   **$mod + Shift + number(1-0)**: Move current window to that workspace

## Configuring the i3wm Configuration File

i3wm is configured through a text-based configuration file (`~/.config/i3/config`).

### Configuration File Contents

1. Basic variable settings (mod key, font, etc.)
2. Autostart program settings
3. Dark mode and power management settings
4. Media key bindings
5. Basic window manipulation key bindings
6. Workspace settings
7. Window style and color settings
8. Bar (i3bar) settings

### Configuration Examples

```bash
# Basic variable settings
set $mod Mod1
font pango:JetBrains Mono 10

# Default programs
bindsym $mod+Return exec alacritty
bindsym $mod+d exec --no-startup-id rofi -show drun

# Default window movement keys (jkl;)
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Window splitting methods
bindsym $mod+h split h
bindsym $mod+v split v
```

## Efficiently Using Workspaces

i3wm's workspace system is highly efficient for task management. It provides 10 workspaces by default.

### Workspace Configuration

```bash
# Workspace definitions (concise number names)
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"

# Workspace switching
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2

# Moving windows to workspaces
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
```

In my configuration, I use concise workspace names with just numbers like `"1"`, `"2"`, `"3"`. This is a choice to minimize cognitive load and enable quick switching. Some users add colons and descriptions after numbers like `"1:web"`, `"2:code"`, `"3:term"` to specify the purpose of each workspace. However, I prefer using workspaces flexibly rather than for fixed purposes, so I found using only numbers more free and efficient. I maintain the flexibility to change names in the configuration file whenever needed.

## Customizing i3bar and i3status

i3wm provides a status bar at the bottom (or top) of the screen. It consists of i3bar (the bar rendering component) and i3status (the system information collection and formatting component). i3bar receives JSON-formatted data output by i3status and displays it visually. i3status monitors various system information including CPU usage, memory usage, disk space, network status, battery level, and time. You can freely customize the displayed information and format through the configuration file (`~/.config/i3status/config`). If you need more powerful features, you can use alternative status bar programs such as i3blocks, polybar, or bumblebee-status instead of i3status.

### i3bar Configuration

```bash
bar {
    position bottom
    status_command i3status
    tray_output primary
    font pango:JetBrains Mono 10

    mode hide  # Hidden by default
    hidden_state hide
    modifier $mod

    colors {
        background #1c1c1c
        statusline #c0c5ce
        focused_workspace  #2b303b #2b303b #c0c5ce
        inactive_workspace #1c1c1c #1c1c1c #888888
    }
}
```

Key features: It's hidden by default and only shows when the $mod key is pressed. It uses dark theme-based colors and allows volume control with the mouse wheel.

## Tips for Enhancing Productivity

### Resize Mode

Resize mode for precisely adjusting window sizes:

```bash
mode "resize" {
    # Size adjustment bindings
    bindsym j resize shrink width 10 px or 10 ppt
    bindsym k resize grow height 10 px or 10 ppt
    bindsym l resize shrink height 10 px or 10 ppt
    bindsym semicolon resize grow width 10 px or 10 ppt

    # Exit mode
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
```

### Key Binding Customization

Changing the default jkl; array to VI editor-style hjkl keys:

```bash
# VI style hjkl change
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Split key change (h is already in use)
bindsym $mod+b split h  # Horizontal split
```

### Useful Shortcut Settings

```bash
# Screenshot
bindsym Print exec --no-startup-id scrot '%Y-%m-%d_%H-%M-%S.png' -e 'mv $f ~/Pictures/'

# System control
bindsym $mod+Shift+x exec xtrlock  # Screen lock
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Do you want to exit?'"
```

More detailed configuration examples and my actual settings can be found in my GitHub repository ([github.com/in-jun/i3wm-setup](https://github.com/in-jun/i3wm-setup)).

## Conclusion

i3wm is a minimalist philosophy window manager that takes a fundamentally different approach from traditional desktop environments like GNOME, KDE Plasma, and Xfce. However, once you overcome the initial learning curve, you can experience remarkable productivity improvements by minimizing mouse usage and quickly performing all tasks with just the keyboard. The keyboard-centric interface, efficient window management through automatic tiling, high customization via text-based configuration files, and lightweight stability are very attractive features for developers, system administrators, and power users. It particularly shines in development workflows with heavy multitasking.

While the learning curve may feel somewhat steep, the official documentation ([i3wm.org/docs](https://i3wm.org/docs/)) is very detailed and systematically written, making it excellent for step-by-step learning. The r/i3wm community on Reddit and the i3 page on Arch Wiki also provide abundant examples and tips. Most importantly, the process of gradually improving your configuration while actually using it becomes an enjoyable and rewarding experience in itself.
