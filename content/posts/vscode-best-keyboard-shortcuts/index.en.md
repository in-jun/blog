---
title: "VS Code Best Keyboard Shortcuts"
date: 2024-06-21T00:18:52+09:00
tags: ["VS Code", "Productivity", "Editor"]
description: "Essential VS Code keyboard shortcuts for productivity."
draft: false
---

Visual Studio Code (VS Code) is a free open-source code editor released by Microsoft in 2015. Built on the Electron framework, it provides the same experience across Windows, macOS, and Linux. With its lightweight execution speed and rich extension ecosystem, it has become the most widely used editor among developers worldwide. To maximize VS Code productivity, mastering shortcuts is essential. Minimizing mouse usage and working keyboard-centrically significantly improves coding speed. This guide organizes VS Code's core shortcuts by category and explains practical usage.

## VS Code Overview

> **What is Visual Studio Code?**
>
> VS Code is a free open-source code editor developed by Microsoft, written in TypeScript and JavaScript, and built on the Electron framework. It supports IntelliSense, built-in Git, debugging, terminal, and rich extensions, providing IDE-like functionality.

### VS Code vs Other Editors

| Feature | VS Code | Vim | JetBrains IDE | Sublime Text |
|---------|---------|-----|---------------|--------------|
| **Price** | Free | Free | Paid (Community free) | Paid |
| **Speed** | Fast | Very Fast | Slow | Very Fast |
| **Extensibility** | Very High | High | High | High |
| **Learning Curve** | Low | High | Medium | Low |
| **Debugging** | Built-in | Plugin | Built-in | Plugin |
| **Git Integration** | Built-in | Plugin | Built-in | Plugin |

## Essential Shortcuts Summary

The most frequently used core shortcuts are summarized first.

| Shortcut | Function | Importance |
|----------|----------|------------|
| `Ctrl+P` | Quick file open | Essential |
| `Ctrl+Shift+P` | Command palette | Essential |
| `Ctrl+D` | Multi-select same word | Essential |
| `Alt+↑/↓` | Move line | Essential |
| `Ctrl+/` | Toggle comment | Essential |
| `Ctrl+B` | Toggle sidebar | Frequent |
| `Ctrl+`` ` | Toggle terminal | Frequent |
| `F12` | Go to definition | Frequent |
| `Ctrl+Shift+F` | Search all files | Frequent |
| `Ctrl+\` | Split editor | Frequent |

## General Commands

| Shortcut | Function |
|----------|----------|
| `Ctrl+Shift+P` or `F1` | Open command palette |
| `Ctrl+P` | Quick Open file |
| `Ctrl+Shift+N` | Open new window |
| `Ctrl+W` | Close current tab |
| `Ctrl+,` | Open settings |
| `Ctrl+K Ctrl+S` | Open keyboard shortcuts settings |

The command palette (`Ctrl+Shift+P`) is the core tool for accessing all VS Code features. Typing `>` searches commands, `@` searches symbols, and `#` searches workspace symbols.

## Basic Editing

### Text Manipulation

| Shortcut | Function |
|----------|----------|
| `Ctrl+X` | Cut line (current line when no selection) |
| `Ctrl+C` | Copy line (current line when no selection) |
| `Ctrl+Shift+K` | Delete line |
| `Alt+↑/↓` | Move line up/down |
| `Shift+Alt+↑/↓` | Copy line up/down |
| `Ctrl+Enter` | Insert blank line below |
| `Ctrl+Shift+Enter` | Insert blank line above |

### Indentation and Formatting

| Shortcut | Function |
|----------|----------|
| `Ctrl+]` | Indent |
| `Ctrl+[` | Outdent |
| `Ctrl+Shift+I` | Format document |
| `Ctrl+K Ctrl+F` | Format selection |

### Comments

| Shortcut | Function |
|----------|----------|
| `Ctrl+/` | Toggle line comment |
| `Ctrl+Shift+A` | Toggle block comment |
| `Ctrl+K Ctrl+C` | Add line comment |
| `Ctrl+K Ctrl+U` | Remove line comment |

### Code Folding

| Shortcut | Function |
|----------|----------|
| `Ctrl+Shift+[` | Fold region |
| `Ctrl+Shift+]` | Unfold region |
| `Ctrl+K Ctrl+0` | Fold all regions |
| `Ctrl+K Ctrl+J` | Unfold all regions |

## Multi-Cursor and Selection

> **What is Multi-Cursor?**
>
> Multi-cursor is a feature that places cursors at multiple positions simultaneously to perform the same edit at once. It dramatically reduces repetitive text modification work and is one of VS Code's most powerful features.

| Shortcut | Function |
|----------|----------|
| `Alt+Click` | Add cursor at click position |
| `Ctrl+Alt+↑/↓` | Add cursor above/below |
| `Ctrl+D` | Add next occurrence of current selection |
| `Ctrl+Shift+L` | Select all occurrences of current selection |
| `Ctrl+F2` | Select all occurrences of current word |
| `Shift+Alt+I` | Insert cursor at end of each selected line |
| `Ctrl+U` | Undo last cursor operation |
| `Shift+Alt+drag` | Column (block) selection |

### Selection Expand/Shrink

| Shortcut | Function |
|----------|----------|
| `Shift+Alt+→` | Expand selection |
| `Shift+Alt+←` | Shrink selection |
| `Ctrl+L` | Select current line |
| `Ctrl+Shift+\\` | Jump to matching bracket |

## Search and Replace

| Shortcut | Function |
|----------|----------|
| `Ctrl+F` | Find in current file |
| `Ctrl+H` | Find and replace in current file |
| `Ctrl+Shift+F` | Find in all files |
| `Ctrl+Shift+H` | Find and replace in all files |
| `F3` / `Shift+F3` | Next/previous search result |
| `Alt+Enter` | Select all search results |
| `Ctrl+D` | Add next match to selection |
| `Ctrl+K Ctrl+D` | Skip current selection and select next match |

To use regular expressions in the search box, press `Alt+R` to enable regex mode.

## Navigation and Movement

| Shortcut | Function |
|----------|----------|
| `Ctrl+G` | Go to specific line |
| `Ctrl+P` | Go to file |
| `Ctrl+Shift+O` | Go to symbol (current file) |
| `Ctrl+T` | Go to symbol (workspace) |
| `F12` | Go to definition |
| `Alt+F12` | Peek definition |
| `Shift+F12` | Show references |
| `Ctrl+Shift+M` | Open problems panel |
| `F8` / `Shift+F8` | Go to next/previous error |
| `Ctrl+Alt+-` | Go to previous location (back) |
| `Ctrl+Shift+-` | Go to next location (forward) |

## Editor Management

### Window Splitting

| Shortcut | Function |
|----------|----------|
| `Ctrl+\` | Split editor |
| `Ctrl+1/2/3` | Focus editor group 1/2/3 |
| `Ctrl+K Ctrl+←/→` | Focus previous/next editor group |
| `Ctrl+K ←/→` | Move editor group |

### Tab Management

| Shortcut | Function |
|----------|----------|
| `Ctrl+Tab` | Go to next tab |
| `Ctrl+Shift+Tab` | Go to previous tab |
| `Ctrl+W` | Close current tab |
| `Ctrl+K Ctrl+W` | Close all tabs |
| `Ctrl+Shift+T` | Reopen closed tab |

## Display

| Shortcut | Function |
|----------|----------|
| `F11` | Toggle full screen |
| `Ctrl+B` | Toggle sidebar |
| `Ctrl+Shift+E` | Open explorer |
| `Ctrl+Shift+F` | Open search panel |
| `Ctrl+Shift+G` | Open source control panel |
| `Ctrl+Shift+D` | Open debug panel |
| `Ctrl+Shift+X` | Open extensions panel |
| `Ctrl+=` / `Ctrl+-` | Zoom in/out |
| `Ctrl+K Z` | Zen mode (focus mode) |

## File Management

| Shortcut | Function |
|----------|----------|
| `Ctrl+N` | New file |
| `Ctrl+O` | Open file |
| `Ctrl+S` | Save |
| `Ctrl+Shift+S` | Save as |
| `Ctrl+K P` | Copy active file path |
| `Ctrl+K R` | Reveal file in explorer |
| `Ctrl+K O` | Open file in new window |

## Code Intelligence

| Shortcut | Function |
|----------|----------|
| `Ctrl+Space` | Show autocomplete suggestions |
| `Ctrl+Shift+Space` | Show parameter hints |
| `Ctrl+.` | Quick Fix |
| `F2` | Rename symbol (refactoring) |
| `Ctrl+K Ctrl+I` | Show hover information |

## Debugging

| Shortcut | Function |
|----------|----------|
| `F5` | Start/continue debugging |
| `Shift+F5` | Stop debugging |
| `F9` | Toggle breakpoint |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift+F11` | Step Out |

## Integrated Terminal

| Shortcut | Function |
|----------|----------|
| `` Ctrl+` `` | Toggle terminal |
| `` Ctrl+Shift+` `` | Create new terminal |
| `Ctrl+Shift+C` | Copy selected text |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+↑/↓` | Terminal scroll |

## Customizing Shortcuts

VS Code shortcuts can be changed in the keyboard shortcuts settings opened with `Ctrl+K Ctrl+S`. For more detailed configuration, you can directly edit the `keybindings.json` file. If frequently used commands lack shortcuts or existing shortcuts are inconvenient, setting up your own shortcuts is recommended.

## Conclusion

Mastering VS Code shortcuts allows you to work keyboard-centrically with minimal mouse usage, significantly improving coding speed and productivity. Rather than trying to memorize all shortcuts at first, it is effective to naturally use core shortcuts like `Ctrl+P` (open file), `Ctrl+Shift+P` (command palette), `Ctrl+D` (multi-select), and `Ctrl+/` (comment), gradually adding other shortcuts. The complete shortcut list can be found in the VS Code official documentation's [Keyboard Shortcuts Reference](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf).
