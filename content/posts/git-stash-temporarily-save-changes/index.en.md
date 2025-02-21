---
title: "Using Git Stash: A Quick Guide to Saving and Restoring Changes"
date: 2024-07-26T14:39:46+09:00
tags: ["git", "stash"]
draft: false
---

## Introduction

Git, a well-known distributed version control system (DVCS), provides a comprehensive suite of features for managing a project's history and collaborating effectively. While working with Git, situations arise where you want to switch to a different branch while you have uncommitted changes. Attempting to switch branches without committing your changes results in an error message like the following:

```bash
error: Your local changes to the following files would be overwritten by checkout:
        file.txt
Please commit your changes or stash them before you switch branches.
Aborting
```

This error indicates that changes in the file `file.txt` are blocking the branch switch. In such scenarios, you have the option to either commit your changes or temporarily save them. In this tutorial, we'll explore how to temporarily save your changes using Git stash, allowing you to switch to a different branch.

## Understanding Git Stash

Git stash is a utility that temporarily stores changes made in your working directory. It enables you to save your current work-in-progress without committing it, giving you the flexibility to switch branches. Stashes are stored in a stack-like manner, allowing you to retrieve them when needed.

## Using Git Stash

### 1. Save Your Changes

To save the modifications in your current working directory to a stash, use the following command:

```bash
git stash
```

This command stores changes in tracked files in a stash, leaving your working directory in a clean state.

### 2. List Stashed Changes

To view a list of your saved stashes, execute this command:

```bash
git stash list
```

This command displays a list of your stashes. Each stash is referenced by a unique identifier.

### 3. Apply Changes from a Stash

To reintroduce changes from a saved stash, use the following command:

```bash
git stash apply
```

This command applies the most recent stash to your working directory. If you want to apply changes from a specific stash, you can specify its stash name:

```bash
git stash apply stash@{2}
```

### 4. Drop a Stash

To remove an applied stash, use the following command:

```bash
git stash drop
```

To remove a specific stash, specify its stash name:

```bash
git stash drop stash@{1}
```

To remove all stashes, use the `clear` command:

```bash
git stash clear
```

If you want to apply and remove a stash in one step, you can use the `pop` command:

```bash
git stash pop
```

## Practical Examples of Git Stash

1. When an urgent bug fix is required in a different branch while you're working on a feature:

    ```bash
    git stash
    git checkout bugfix-branch
    # Work on the bug fix
    git checkout original-branch
    git stash pop
    ```

2. Before fetching changes from a remote Git repository:

    ```bash
    git stash
    git pull origin master
    git stash pop  # Reapply after resolving any conflicts if they arise
    ```

3. Managing multiple stashes:

    ```bash
    git stash save "Description of work 1"
    git stash save "Description of work 2"
    git stash list
    git stash apply stash@{1}
    ```

## Points to Note

1. Untracked files are generally excluded from stashes. To include them, use the `-u` option:

    ```bash
    git stash -u
    ```

2. Ignored files are not included in stashes by default. To include them, use the `-a` option:

    ```bash
    git stash -a
    ```

3. Stashes are not branch-specific. This means they can be applied from any branch.

4. Be cautious when applying stashes, as conflicts can occur.

## Conclusion

Git stash is a powerful tool that enables you to temporarily save your ongoing work and restore it later. It increases the flexibility of your workflow and can be especially useful when handling urgent tasks or switching branches. By leveraging the capabilities of Git stash, developers can optimize their Git workflow and maintain a streamlined development environment.
