---
title: "Temporarily Saving Changes with Git Stash"
date: 2024-07-26T14:39:46+09:00
tags: ["Git", "Version Control"]
description: "Temporarily saving changes with Git stash."
draft: false
---

## Concept and History of Git Stash

Git stash is a feature first introduced in Git version 1.5.3 in 2007. It provides a mechanism to save changes in the Working Directory (modified tracked files and staged changes) to a stack-based temporary storage without committing, allowing restoration later. This feature is useful when you need to urgently switch to another branch while working, or when you need to fetch changes from a remote repository but your current work is not ready for a commit.

When attempting to switch branches with uncommitted changes, Git displays the following error message and refuses the switch. This happens because changes in the current Working Directory might conflict with files in the branch you're trying to checkout.

```bash
error: Your local changes to the following files would be overwritten by checkout:
        file.txt
Please commit your changes or stash them before you switch branches.
Aborting
```

## Basic Usage

### Saving Changes: git stash

The `git stash` command saves changes from the Working Directory and Staging Area to the stash stack and reverts the Working Directory to a clean state matching the last commit. By default, it only saves changes to tracked files (files already being tracked by Git) and does not include untracked files or files ignored by .gitignore.

```bash
git stash
```

To save with a message, use the `save` subcommand (or `push -m`). This is useful for identifying what each stash represents when managing multiple stashes.

```bash
git stash save "Working on login feature"
git stash push -m "Working on login feature"  # Recommended since Git 2.13+
```

### Viewing Stash List: git stash list

This command displays a list of saved stashes. Each stash is referenced by an index in the format `stash@{n}`, with the most recently saved being `stash@{0}`. The branch name and commit message are also displayed, helping identify under what circumstances each stash was created.

```bash
git stash list
# stash@{0}: WIP on main: abc1234 feat: implement login
# stash@{1}: On develop: def5678 fix: bug fix
```

### Applying Stash: git stash apply vs pop

Two commands apply a saved stash back to the Working Directory: `apply` and `pop`. `apply` applies the stash but keeps it in the stack, allowing the same stash to be applied to multiple branches. `pop` applies and simultaneously removes from the stack, which is the recommended approach for typical use. To apply a specific stash, you can specify its index.

```bash
git stash apply           # Apply most recent, keep in stack
git stash pop             # Apply most recent and remove from stack
git stash apply stash@{2} # Apply specific stash
```

An important difference is that when using `pop`, if a conflict occurs, the stash is not automatically removed and remains in the stack, requiring manual `drop` after resolving the conflict.

### Removing Stash: git stash drop and clear

To remove a specific stash from the stack, use `drop`. To remove all stashes at once, use `clear`. Without specifying an index, `drop` removes the most recent stash (`stash@{0}`).

```bash
git stash drop            # Remove most recent stash
git stash drop stash@{1}  # Remove specific stash
git stash clear           # Remove all stashes
```

## Advanced Options

### Including Untracked Files: -u option

By default, stash only saves changes to tracked files. To include newly created files that haven't been `git add`ed yet (untracked files), use the `-u` or `--include-untracked` option.

```bash
git stash -u
```

### Including Ignored Files: -a option

To stash everything including files ignored by .gitignore, use the `-a` or `--all` option. This is used in special cases where build artifacts or cache files need to be temporarily saved.

```bash
git stash -a
```

### Viewing Stash Contents: git stash show

You can view changes stored in a stash like a commit. Adding the `-p` option shows detailed changes in diff format, which is useful for checking what's in a stash before applying it.

```bash
git stash show            # List of changed files
git stash show -p         # Detailed view in diff format
git stash show stash@{1}  # View specific stash
```

## Conflict Resolution

Conflicts may occur when applying a stash if the current Working Directory contents differ. When conflicts occur, conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) appear in files just like merge conflicts. After manually resolving conflicts, stage with `git add`. If you used `pop`, the stash remains in the stack and must be removed with `git stash drop`.

```bash
# When conflict occurs
Auto-merging file.txt
CONFLICT (content): Merge conflict in file.txt

# Resolution steps
# 1. Open file and manually resolve conflict markers
# 2. git add file.txt
# 3. git stash drop (when using pop)
```

## Practical Usage Scenarios

### Emergency Bug Fix

When an urgent bug fix request comes in while developing a feature, save current work with stash, switch to the bug fix branch, complete the fix, return to the original branch, and restore the stash.

```bash
git stash push -m "Working on feature/login"
git checkout hotfix/critical-bug
# Bug fix work and commit
git checkout feature/login
git stash pop
```

### Fetching Remote Changes

When you need to fetch the latest changes from a remote repository while having uncommitted local changes, save local changes with stash, perform pull, then reapply. If conflicts occur, resolve them before proceeding.

```bash
git stash
git pull origin main
git stash pop  # Resolve conflicts if any, then git stash drop
```

## Conclusion

Since its introduction in Git 1.5.3 in 2007, Git stash has become an essential feature for temporarily saving uncommitted changes and restoring them later. Understanding the difference between `apply` and `pop` (whether to remove from stack), including untracked files with the `-u` option, and knowing that manual `drop` is required after conflict resolution enables flexible management of workflows in various situations such as branch switching, urgent tasks, and remote synchronization.
