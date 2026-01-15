---
title: "Vim Usage Guide"
date: 2024-07-06T20:17:05+09:00
tags: ["vim", "editor", "tool"]
description: "A comprehensive vim guide covering the history and evolution of vim, the philosophy of modal editing and its powerful editing features, detailed commands for Normal/Insert/Visual/Command modes, search and substitution techniques, the useful plugin ecosystem, vimrc configuration methods, and practical tips and keyboard shortcuts for real-world usage."
draft: false
---

Vim is an extended version of the Vi editor, including Vi's functionality while providing many more features. Vim can be operated entirely with the keyboard, allowing fast editing without mouse usage. With nearly 50 years of history, it is a powerful and proven tool. In this post, we will comprehensively cover everything from Vim's history to practical usage.

## History and Evolution of Vim

### The Birth of vi

The vi editor was developed by Bill Joy in 1976 for BSD Unix. It was designed to work efficiently even in the slow terminal environments of that era. By introducing the concept of modal editing, it enabled fast editing using only the keyboard. This philosophy remains valid even in modern development environments.

### The Emergence of vim

vim stands for Vi IMproved and was developed by Bram Moolenaar in 1991 for the Amiga computer. It is an extended and improved version of vi. It added modern features such as syntax highlighting, multiple undo, plugin support, and graphical interfaces. Released as open source, it has evolved through contributions from developers worldwide.

### vim vs neovim

neovim is a project that started in 2014 by forking the vim codebase. It provides asynchronous plugin support, built-in LSP client, Lua scripting, and better default settings. vim emphasizes traditional stability and compatibility, while neovim pursues innovation tailored to modern development environments. Both editors are actively developed, and their basic usage is nearly identical.

### Why vim is Still Used in 2025-2026

vim is pre-installed on almost all Unix-like systems, making it immediately available in server environments. It is much lighter and faster than GUI editors when connecting via SSH. The keyboard-centric workflow provides significantly faster editing speed than using a mouse once you become familiar with it. Additionally, the powerful plugin ecosystem and customization possibilities, along with nearly 50 years of accumulated community knowledge and resources, support vim's continued popularity.

## The Philosophy of Modal Editing

### What is Modal Editing

Modal editing is a method that separates the editor's operations into multiple modes, where the same key performs different functions depending on the mode. In regular editors, pressing a character key always inputs that character. In vim, Normal mode executes commands, while Insert mode inputs text. This separation can be confusing at first, but becomes a very powerful editing tool once you get used to it.

### Why Modal Editing is Powerful

Modal editing allows all keys on the keyboard to be used as commands. You can use hundreds of commands concisely without modifier keys like Ctrl or Alt. It clearly separates text input from editing, reducing wrist strain. Commands can be combined to express complex editing tasks simply. It is optimized for repetitive tasks, maximizing productivity with macros and the dot command.

### Learning Curve and Long-term Productivity

vim's initial learning curve is steep. However, learning just 20-30 basic commands enables everyday editing. After a few weeks of use, you can work at speeds similar to your previous editor. After a few months, you'll experience editing speeds much faster than before. The time invested returns as a skill you can use for decades. vim key bindings are supported by many tools and can be utilized in various environments.

## Vim Modes

Vim has four main modes.

1. Normal mode: The default mode where you can edit text or enter commands.
2. Insert mode: The mode where you can input text, allowing text entry or modification.
3. Visual mode: The mode where you can select text, allowing copying or deleting of selected text.
4. Command mode: The mode where you enter commands starting with a colon to perform file saving, searching, substitution, etc.

## Detailed Commands by Mode

### Normal Mode

When you launch Vim, it starts in Normal mode by default. Normal mode is the core of vim, and you will spend most of your time in this mode.

#### Movement Commands

-   `h`, `j`, `k`, `l`: Move left, down, up, right by one character
-   `w`: Move to the start of the next word
-   `b`: Move to the start of the previous word
-   `e`: Move to the end of the current word
-   `gg`: Move to the first line of the file
-   `G`: Move to the last line of the file
-   `0`: Move to the beginning of the line
-   `$`: Move to the end of the line
-   `f{char}`: Move forward to the character in the current line
-   `F{char}`: Move backward to the character in the current line
-   `t{char}`: Move forward until just before the character
-   `T{char}`: Move backward until just after the character

#### Editing Commands

-   `x`: Delete the character at cursor position
-   `X`: Delete the character before the cursor
-   `r{char}`: Replace the character at cursor position with another character
-   `R`: Enter Replace mode for continuous replacement
-   `c{motion}`: Delete the specified range and enter Insert mode
-   `C`: Delete from cursor to end of line and enter Insert mode
-   `s`: Delete the character at cursor position and enter Insert mode
-   `S`: Delete the entire current line and enter Insert mode
-   `dd`: Delete the current line
-   `yy`: Copy the current line
-   `p`: Paste after the cursor
-   `P`: Paste before the cursor
-   `u`: Undo
-   `Ctrl + r`: Redo

### Insert Mode

Insert mode is the mode where you actually input text. You can enter it in various ways, each starting at a different position.

-   `i`: Start input at cursor position
-   `a`: Start input after the cursor position
-   `o`: Create a new line below and start input
-   `O`: Create a new line above and start input
-   `I`: Start input at the beginning of the line
-   `A`: Start input at the end of the line

In Insert mode, pressing the `Esc` key returns you to Normal mode. Many vim users remap `Caps Lock` to `Esc` because the `Esc` key is far away, or they use the `Ctrl + [` shortcut.

### Visual Mode

Visual mode is a mode where you can visually select text for editing. There are three types.

-   `v`: Enter character-wise Visual mode
-   `V`: Enter line-wise Visual mode
-   `Ctrl + v`: Enter block-wise Visual mode to select rectangular regions

Commands you can use after selecting in Visual mode are as follows.

-   `d`: Delete selected text
-   `y`: Copy selected text
-   `c`: Delete selected text and enter Insert mode
-   `>`: Indent selected text
-   `<`: Unindent selected text

### Command Mode

Command mode is where you enter commands starting with a colon to perform file operations, change settings, and execute complex editing tasks.

-   `:w`: Save file
-   `:q`: Quit vim
-   `:wq` or `:x`: Save and quit
-   `:q!`: Force quit without saving
-   `:e {filename}`: Open another file
-   `:set number`: Display line numbers
-   `:set tabstop=4`: Set tab size to 4
-   `:help {topic}`: View help

## Search and Substitution

### Search Functionality

vim's search functionality is very powerful and supports regular expressions.

-   `/pattern`: Search downward from current position
-   `?pattern`: Search upward from current position
-   `n`: Move to next search result in the same direction
-   `N`: Move to previous search result in the opposite direction
-   `*`: Search the word at cursor position downward
-   `#`: Search the word at cursor position upward

### Substitution Commands

Substitution commands are used for batch text changes. They become very powerful when used with regular expressions.

-   `:s/old/new/`: Substitute the first occurrence of old with new in the current line
-   `:s/old/new/g`: Substitute all occurrences of old with new in the current line
-   `:%s/old/new/g`: Substitute all occurrences of old with new in the entire file
-   `:%s/old/new/gc`: Substitute with confirmation throughout the entire file
-   `:5,10s/old/new/g`: Substitute from line 5 to line 10

## Useful Plugins

### vim-plug Plugin Manager

vim-plug is the most popular vim plugin manager. It makes plugin installation and updates easy to manage. You can install it with a single command from GitHub. After writing the plugin list in vimrc, you can batch install with the `:PlugInstall` command.

### NERDTree

NERDTree is a file explorer plugin. It displays the file system in a tree structure in the sidebar and allows file creation, deletion, and movement like a GUI. You can toggle it with the `:NERDTreeToggle` command. It is an essential plugin used by many developers.

### fzf

fzf is a fuzzy finder plugin. It allows quick searching of filenames, buffers, and tags. With substring matching, you can find files and open the desired file in a project instantly. It also supports command history search.

### coc.nvim

coc.nvim is a plugin that provides modern autocompletion and LSP client. It enables VSCode-like level of IntelliSense in vim. It provides modern IDE features such as code autocompletion, go to definition, find references, and error display. It supports various languages.

### vim-airline

vim-airline is a status bar plugin. It beautifully displays useful information at the bottom of the screen, including current mode, filename, line number, and Git branch. It supports various themes and integrates with other plugins to display additional information.

## vimrc Configuration Examples

vimrc is vim's configuration file, written in the `.vimrc` file in the home directory. Here is a basic configuration example.

```vim
" Basic settings
set number              " Display line numbers
set relativenumber      " Display relative line numbers
syntax on               " Syntax highlighting
set tabstop=4           " Tab size 4
set shiftwidth=4        " Indent size 4
set expandtab           " Convert tabs to spaces
set autoindent          " Auto indent
set smartindent         " Smart indent
set hlsearch            " Highlight search results
set incsearch           " Incremental search
set ignorecase          " Case insensitive search
set smartcase           " Case sensitive when uppercase is used

" Key mappings
let mapleader = " "     " Set leader key to space
nnoremap <leader>w :w<CR>                " Save with space+w
nnoremap <leader>q :q<CR>                " Quit with space+q
nnoremap <C-h> <C-w>h                    " Move to left window with Ctrl+h
nnoremap <C-l> <C-w>l                    " Move to right window with Ctrl+l
```

## Practical Tips and Keyboard Shortcuts

### Using Macros

Macros are a powerful feature for automating repetitive tasks. Start recording with `q{register}`, perform actions, then end recording with `q`. You can replay the macro with `@{register}`. Use `@@` to repeat the last macro. Using it with numbers like `10@a` executes it multiple times.

### Editing Multiple Files

In vim, you can open and edit multiple files simultaneously.

-   `:e filename`: Open a new file
-   `:bn`: Move to next buffer
-   `:bp`: Move to previous buffer
-   `:ls`: List open buffers
-   `:b number`: Move to buffer with that number

### Split Windows

You can split the screen to view multiple files simultaneously.

-   `:split` or `:sp`: Split horizontally
-   `:vsplit` or `:vs`: Split vertically
-   `Ctrl + w + h/j/k/l`: Move between split windows
-   `Ctrl + w + =`: Adjust all window sizes equally

### Repeating with the Dot Command

The dot (`.`) command is a very useful feature that repeats the last change. For example, after changing a word with `ciw` and entering a new word, pressing `.` at another location repeats the same action. This is suitable for simpler repetitive tasks than macros.

## Utilizing vimtutor

vimtutor is an interactive tutorial built into vim. It runs by entering the `vimtutor` command in the terminal. It takes about 30 minutes and is the best learning method for beginners as you can learn vim's basic commands through hands-on practice. Korean version is also supported. It's important to repeat it several times to get it into your muscle memory.

## Conclusion

Vim is a powerful text editor with nearly 50 years of history. Through the unique philosophy of modal editing, it enables very fast editing using only the keyboard. The initial learning curve is steep, but once familiar, it is more efficient than any other editor. It is an essential tool in server environments and can achieve modern IDE-level functionality through plugins and configuration. vim key bindings are supported by many tools, making it a high-value skill that can be used for a lifetime once learned. Starting with vimtutor and using it a little each day, you'll naturally become proficient. Eventually, you'll find yourself unable to edit without vim.
