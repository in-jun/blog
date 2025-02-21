---
title: "Vim Usage Guide"
date: 2024-07-06T20:17:05+09:00
tags: ["vim", "editor", "tool"]
draft: false
---

Vim is an advanced version of the Vi editor that provides more features while including the features of Vi. Vim can be operated with just the keyboard, enabling users to edit text rapidly without using a mouse. This post will summarize the basic usage and commands of Vim.

## Vim Modes

Vim is divided into three main modes.

1. Normal mode: This is the basic mode in which you can edit text or enter commands.
2. Insert mode: This mode allows you to enter text, and you can add or modify text.
3. Visual mode: This mode enables you to select text, and you can copy or delete the selected text.

### Normal Mode

When you launch Vim, it starts in Normal mode by default. You can use the following commands in Normal mode.

-   `i`: Switch to Insert mode
-   `v`: Switch to Visual mode
-   `dd`: Delete the current line
-   `yy`: Copy the current line
-   `p`: Paste
-   `u`: Undo
-   `Ctrl + r`: Redo
-   `:q`: Exit Vim
-   `:w`: Save
-   `:wq`: Save and exit
-   `:q!`: Exit without saving

### Insert Mode

Press `i` in Normal mode to switch to Insert mode. In Insert mode, you can enter or modify text. You can use the following commands in Insert mode.

You can switch to Insert mode using various commands, such as `i`, `a`, `o`, `O`, `I`, and `A`.

-   `a`: Insert after the cursor
-   `o`: Insert a new line after the cursor
-   `O`: Insert a new line before the cursor
-   `I`: Insert at the beginning of the line
-   `A`: Insert at the end of the line

Press the `Esc` key in Insert mode to switch to Normal mode.

### Visual Mode

Press `v` in Normal mode to switch to Visual mode. In Visual mode, you can select text. You can use the following commands in Visual mode.

-   `d`: Delete selected text
-   `y`: Copy selected text
-   `p`: Paste

Press the `Esc` key in Visual mode to switch to Normal mode.

### Additional Practice

If you want to practice Vim more, enter the `vimtutor` command in the terminal to run the Vim tutorial. The Vim tutorial helps you learn various Vim commands and functions. Consistent practice is necessary to get the most out of Vim. Enhance your ability to edit text efficiently with Vim.

### Summary

Vim is a powerful text editor that enables you to edit text quickly using various commands. This post has covered the basic usage of Vim. Vim can be challenging to use at first, but it is a compelling editor that can help you edit text efficiently once you become familiar with it. Explore more features and commands as you use Vim.
