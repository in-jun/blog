---
title: "Vim Text Editor Tutorial"
date: 2024-07-06T20:17:05+09:00
tags: ["Vim", "Linux", "Editor"]
description: "Vim editor basics and essential commands."
draft: false
---

Vim, which stands for Vi IMproved, was developed by Bram Moolenaar in 1991 as an extended and improved version of the vi editor that Bill Joy created for BSD Unix in 1976. It adds modern features like syntax highlighting, multiple undo, plugin support, and split windows while preserving vi's core philosophy of modal editing, enabling extremely fast editing using only the keyboard. Vim comes pre-installed on nearly all Unix-like systems, making it essential for server management. It enables powerful editing without GUI editors in SSH environments, and its value is supported by nearly 50 years of accumulated community knowledge and a robust plugin ecosystem.

## History of Vim

> **From Vi to Vim**
>
> Vi was an editor designed by Bill Joy in 1976 to work efficiently in the slow terminal environments of the era, introducing the concept of modal editing. Vim was developed by Bram Moolenaar in 1991 as an extension of vi. True to its name, Vi IMproved, it includes all of vi's functionality while adding modern features.

### Major Development Timeline

| Year | Event | Significance |
|------|-------|--------------|
| **1976** | vi born (Bill Joy) | Text editor for BSD Unix introducing modal editing |
| **1991** | Vim 1.0 released (Bram Moolenaar) | Developed for Amiga, extended features while maintaining vi compatibility |
| **1998** | Vim 5.0 | Syntax highlighting, scripting language support |
| **2006** | Vim 7.0 | Tab pages, spell checking, omni completion added |
| **2014** | Neovim project started | Vim fork with async plugins, built-in LSP support |
| **2016** | Vim 8.0 | Asynchronous operations, terminal window support |
| **2023** | Bram Moolenaar passed away | Transition to community-driven development |

### Vim vs Neovim

Neovim is a project that began in 2014 by forking Vim's codebase. It cleaned up Vim's legacy code and redesigned it with modern architecture, supporting asynchronous plugins, built-in LSP client, and Lua scripting. Both editors are actively developed, and their basic usage is nearly identical.

| Characteristic | Vim | Neovim |
|----------------|-----|--------|
| **Philosophy** | Traditional stability, backward compatibility | Modern innovation, extensibility |
| **Scripting** | Vimscript | Vimscript + Lua |
| **Plugins** | Synchronous execution focus | Native async support |
| **LSP** | Plugin required (coc.nvim, etc.) | Built-in LSP client |
| **Default Settings** | Minimal defaults | Sensible defaults |
| **GUI Support** | GVim | Various GUI frontends |

## Philosophy of Modal Editing

> **What is Modal Editing?**
>
> Modal editing separates editor operations into multiple modes where the same key performs different functions depending on the mode. In regular editors, pressing `j` inputs the character 'j'. In Vim's Normal mode, pressing `j` moves the cursor down.

Modal editing allows all character keys on the keyboard to be used as commands, enabling concise expression of hundreds of commands without modifier keys like Ctrl or Alt. It clearly separates text input from editing, preventing unintended text input, and allows combining commands (composability) to express complex editing tasks simply. The initial learning curve is steep, but learning just 20-30 basic commands enables everyday editing, and after a few months, you experience editing speeds far faster than conventional editors.

### Why People Still Use Vim

| Reason | Explanation |
|--------|-------------|
| **Server Environment** | Pre-installed on almost all Unix/Linux systems, immediately available via SSH |
| **Speed** | Lighter than GUI editors, keyboard-centric is faster than mouse |
| **Versatility** | Vim key bindings supported in VS Code, JetBrains, browsers, and more |
| **Customization** | Infinite configuration possibilities, build your own workflow |
| **Community** | 50 years of accumulated knowledge, tutorials, plugins |

## Vim Mode Overview

Vim operates with four main modes, each designed for different purposes.

| Mode | Entry Method | Purpose | Exit Method |
|------|--------------|---------|-------------|
| **Normal** | `Esc` or when Vim starts | Movement, editing commands | - |
| **Insert** | `i`, `a`, `o`, etc. | Text input | `Esc` |
| **Visual** | `v`, `V`, `Ctrl+v` | Text selection | `Esc` or command execution |
| **Command** | `:` | File operations, settings, search/replace | `Enter` or `Esc` |

## Normal Mode

Normal mode is Vim's core mode. Vim starts in this mode by default, and you spend most of your time here.

### Movement Commands

| Command | Action | Description |
|---------|--------|-------------|
| `h`, `j`, `k`, `l` | Left, down, up, right | Basic cursor movement (use instead of arrow keys) |
| `w` | Next word start | Short for word |
| `b` | Previous word start | Short for back |
| `e` | Current/next word end | Short for end |
| `0` | Line start | The number 0 |
| `$` | Line end | Same as regex end |
| `^` | First non-blank character | Similar to regex start |
| `gg` | First line of file | Short for go |
| `G` | Last line of file | Capital G |
| `{n}G` | Go to line n | Example: `10G` goes to line 10 |
| `f{char}` | Move to character in current line | Short for find |
| `t{char}` | Move to just before character | Short for till |
| `%` | Jump to matching bracket | Navigate between (), {}, [] |

### Editing Commands

| Command | Action | Description |
|---------|--------|-------------|
| `x` | Delete character at cursor | delete character |
| `r{char}` | Replace character at cursor | replace |
| `dd` | Delete current line | delete line |
| `yy` | Copy current line | yank line |
| `p` | Paste after cursor | paste after |
| `P` | Paste before cursor | paste before |
| `u` | Undo | undo |
| `Ctrl+r` | Redo | redo |
| `.` | Repeat last change | One of the most powerful commands |

### Combining Operators and Motions

Vim's true power lies in combining operators with motions. The format `{operator}{motion}` enables various editing operations.

| Combination | Meaning | Description |
|-------------|---------|-------------|
| `dw` | delete word | Delete from cursor to word end |
| `d$` | delete to end | Delete from cursor to line end |
| `d0` | delete to start | Delete to line start |
| `diw` | delete inner word | Delete entire word |
| `daw` | delete a word | Delete word and surrounding whitespace |
| `ci"` | change inner quotes | Change content inside quotes |
| `ca(` | change a parenthesis | Change content including parentheses |
| `yiw` | yank inner word | Copy word |
| `>}` | indent to paragraph end | Indent to paragraph end |

## Insert Mode

Insert mode is where you actually input text. You can enter it in various ways, each starting at a different position.

| Command | Action | Description |
|---------|--------|-------------|
| `i` | Input at cursor position | insert |
| `a` | Input after cursor position | append |
| `I` | Input at line start | Insert at line start |
| `A` | Input at line end | Append at line end |
| `o` | Create new line below and input | open line below |
| `O` | Create new line above and input | Open line above |
| `s` | Delete character then input | substitute character |
| `S` | Delete line then input | Substitute line |
| `c{motion}` | Delete range then input | change |

Pressing `Esc` in Insert mode returns you to Normal mode. Many Vim users remap `Caps Lock` to `Esc` because the `Esc` key is far away, or use custom mappings like `Ctrl+[` or `jk`.

## Visual Mode

Visual mode allows you to visually select text for editing. There are three types.

| Command | Selection Type | Use Case |
|---------|----------------|----------|
| `v` | Character-wise | General text selection |
| `V` | Line-wise | Select entire lines |
| `Ctrl+v` | Block-wise | Rectangular region selection (like multiple cursors) |

Key commands available after selecting in Visual mode include `d` (delete), `y` (copy), `c` (change), `>` (indent), `<` (unindent), `~` (toggle case), `u` (lowercase), and `U` (uppercase).

## Command Mode

Command mode is where you enter commands starting with `:` to perform file operations, change settings, and execute search/replace operations.

### File Operations

| Command | Action |
|---------|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` or `:x` | Save and quit |
| `:q!` | Force quit without saving |
| `:e {file}` | Open file |
| `:w {file}` | Save as |

### Setting Changes

| Command | Action |
|---------|--------|
| `:set number` | Display line numbers |
| `:set relativenumber` | Display relative line numbers |
| `:set tabstop=4` | Set tab size |
| `:set expandtab` | Convert tabs to spaces |
| `:syntax on` | Enable syntax highlighting |

## Search and Substitution

### Search

Vim's search supports regular expressions and is very powerful.

| Command | Action |
|---------|--------|
| `/pattern` | Search downward |
| `?pattern` | Search upward |
| `n` | Next result |
| `N` | Previous result |
| `*` | Search word at cursor |
| `#` | Reverse search word at cursor |

### Substitution

The substitution command uses `:s` (substitute) and can perform various substitutions by combining ranges and flags.

| Command | Action |
|---------|--------|
| `:s/old/new/` | Substitute first occurrence in current line |
| `:s/old/new/g` | Substitute all in current line |
| `:%s/old/new/g` | Substitute all in entire file |
| `:%s/old/new/gc` | Substitute with confirmation |
| `:5,10s/old/new/g` | Substitute in lines 5-10 |
| `:'<,'>s/old/new/g` | Substitute in Visual selection |

## Plugin Ecosystem

> **Plugin Managers**
>
> The most popular Vim plugin manager is vim-plug, characterized by concise syntax and fast parallel installation. Plugins can be batch installed with the `:PlugInstall` command and updated with `:PlugUpdate`.

### Essential Plugins

| Plugin | Function | Description |
|--------|----------|-------------|
| **NERDTree** | File explorer | Browse files in sidebar tree structure |
| **fzf.vim** | Fuzzy finder | Quick search for files, buffers, commands |
| **coc.nvim** | Autocompletion/LSP | VSCode-level IntelliSense |
| **vim-airline** | Status bar | Display mode, filename, Git status |
| **vim-fugitive** | Git integration | Run Git commands within Vim |
| **vim-surround** | Surround editing | Easily change brackets, quotes, etc. |
| **vim-commentary** | Comment toggle | Toggle comments with `gc` |

## vimrc Configuration

vimrc is Vim's configuration file, located at `~/.vimrc` (Unix) or `~/_vimrc` (Windows), and is automatically loaded when Vim starts.

```vim
" Basic settings
set nocompatible            " Disable vi compatibility mode
set encoding=utf-8          " UTF-8 encoding
set number                  " Display line numbers
set relativenumber          " Relative line numbers
syntax on                   " Syntax highlighting
set tabstop=4               " Tab size 4
set shiftwidth=4            " Indent size 4
set expandtab               " Convert tabs to spaces
set autoindent              " Auto indent
set smartindent             " Smart indent
set hlsearch                " Highlight search results
set incsearch               " Incremental search
set ignorecase              " Case insensitive
set smartcase               " Case sensitive when uppercase used
set cursorline              " Highlight current line
set wildmenu                " Command completion menu
set clipboard=unnamedplus   " Use system clipboard

" Leader key setting
let mapleader = " "

" Common mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
```

## Practical Tips

### Macros

Macros are a powerful feature for automating repetitive tasks. Start recording with `q{register}`, perform actions, end recording with `q`, then replay with `@{register}`. Use `@@` to repeat the last macro.

### Split Windows

| Command | Action |
|---------|--------|
| `:sp` or `:split` | Horizontal split |
| `:vs` or `:vsplit` | Vertical split |
| `Ctrl+w h/j/k/l` | Move between windows |
| `Ctrl+w =` | Equalize window sizes |
| `Ctrl+w _` | Maximize current window (horizontal) |
| `Ctrl+w \|` | Maximize current window (vertical) |

### Buffer Management

| Command | Action |
|---------|--------|
| `:ls` | List buffers |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:b{n}` | Go to buffer n |
| `:bd` | Delete buffer |

## Learning Methods

vimtutor is an interactive tutorial built into Vim. It runs by entering `vimtutor` in the terminal and takes about 30 minutes. A Korean version is also available (`vimtutor ko`). It is the best learning method for beginners as you can learn basic commands through hands-on practice. Learning one new command at a time while using Vim daily is effective. Vim key bindings are supported in many tools including VS Code (Vim extension), JetBrains IDE (IdeaVim), and browsers (Vimium), making it a high-value skill that can be used for a lifetime once learned.

## Conclusion

Vim is a text editor with nearly 50 years of history since vi's birth in 1976. Through the unique philosophy of modal editing, it enables extremely fast editing using only the keyboard. The initial learning curve is steep, but once familiar, it is more efficient than any other editor. It comes pre-installed on nearly all Unix/Linux systems, making it essential in server environments. Through plugins and configuration, it can achieve modern IDE-level functionality. Vim key bindings are supported in VS Code, JetBrains, browsers, and more, making it a skill you can use for a lifetime once learned.
