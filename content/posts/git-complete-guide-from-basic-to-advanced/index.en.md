---
title: "Git From Basics to Advanced Features"
date: 2024-07-08T20:52:04+09:00
tags: ["Git", "Version Control"]
description: "Git fundamentals and advanced features for version control."
draft: false
---

## History and Origins of Git

Git is a Distributed Version Control System (DVCS) developed by Linus Torvalds, the creator of the Linux kernel, in 2005. The development was triggered when the free license for BitKeeper, the commercial DVCS used for Linux kernel development at the time, was revoked. Torvalds needed an alternative and developed a new system in just two weeks that overcame the shortcomings of existing version control systems (slow speed, inefficient branching) while supporting fast operation even on large-scale projects and fully distributed environments. The first version was released on April 7, 2005.

The name "Git" is British slang for "unpleasant person." Torvalds jokingly explained that, like Linux which was named after himself, Git was also named after himself. The official manual also describes it as an acronym for "Global Information Tracker."

## Git's 4-Area Structure

Git consists of four areas: Working Directory, Staging Area, Local Repository, and Remote Repository. The Working Directory is where actual files exist and where you write and modify code. The Staging Area (also called Index) is an intermediate area where changes to be included in the next commit wait. The Local Repository is a database of committed versions stored in the `.git` directory. The Remote Repository is a repository located on servers like GitHub, GitLab, or Bitbucket that is shared with team members. Understanding the data flow between these four areas helps clarify how Git commands work.

## Repository Initialization: git init

The `git init` command initializes the current directory as a new Git repository. When executed, it creates a hidden directory called `.git` where Git stores all metadata needed for version control (object database, reference information, configuration files, etc.). This is the first command to run when starting to manage an existing project with Git or when starting a completely new project.

```bash
git init
```

## Checking Status: git status

The `git status` command shows the current state of the Working Directory and Staging Area. It provides information about which files have been modified, which files are staged and waiting to be committed, and which files are new and not yet tracked by Git. Using the `-s` or `--short` option outputs in a compact format, and adding the `-b` or `--branch` option also displays current branch information.

```bash
git status
git status -sb  # Compact format + branch info
```

## Staging Files: git add

The `git add` command adds changes from the Working Directory to the Staging Area to prepare them for the next commit. To stage a specific file, use `git add <filename>`. To stage all changes in the current directory, use `git add .`. The `-p` option allows you to interactively review each change in hunks and selectively stage them, which is useful for separating multiple logical changes in a single file into separate commits. The `-u` option stages only changes to already-tracked files.

```bash
git add <filename>
git add .
git add -p  # Interactive staging
```

## Unstaging: git restore

The `git restore` command, introduced in Git 2.23.0 (August 2019), restores file states. When used with the `--staged` option, it cancels changes added to the Staging Area and returns them to the modified state in the Working Directory. When used without options, it reverts modifications in the Working Directory to the last committed state. In earlier versions of Git, the same operation was performed with `git reset HEAD <filename>`.

```bash
git restore --staged <filename>  # Unstage
git restore <filename>  # Discard working directory changes
```

## Committing Changes: git commit

The `git commit` command records changes in the Staging Area as a new commit (snapshot) in the Local Repository. The `-m` option allows writing the commit message inline, or running without options opens the configured text editor for writing detailed commit messages. The `-a` option automatically stages and commits all changes to already-tracked files, performing `git add` and `git commit` in one step. The `--amend` option is used to modify the last commit's message or add missing changes.

```bash
git commit -m "feat: implement login feature"
git commit -am "fix: bug fix"  # add + commit
git commit --amend  # Modify last commit
```

## Undoing Commits: git reset and git revert

The `git reset` command cancels commits and moves the HEAD pointer to a previous commit. The `--soft` option cancels only the commit and keeps changes in the Staging Area. The `--mixed` option (default) cancels the commit and returns changes to the Working Directory. The `--hard` option completely deletes changes along with the commit, so it should be used with caution. `HEAD^` refers to the immediately previous commit, and `HEAD~3` refers to 3 commits back.

```bash
git reset --soft HEAD^   # Cancel commit, keep staging
git reset HEAD^          # Cancel commit, to working directory
git reset --hard HEAD^   # Cancel commit, delete changes
```

The `git revert` command creates a new commit that reverses the changes of a specific commit. It is used to safely undo commits that have already been pushed to a remote repository. Unlike reset, it maintains history while reverting changes, making it the recommended approach in collaborative environments.

```bash
git revert <commit-hash>
```

## Viewing Commit History: git log

The `git log` command shows the project's commit history in chronological order (most recent first). It displays each commit's hash, author, date, and commit message. The `--oneline` option displays each commit briefly on a single line. The `--graph` option visualizes branch and merge history as an ASCII graph. The `--stat` option shows statistics for files changed in each commit. The `--all` option displays history for all branches.

```bash
git log
git log --oneline --graph --all  # Full branch graph
git log --stat  # Changed file statistics
```

## Managing Remote Repositories: git remote

The `git remote` command manages remote repositories connected to the local repository. The `add` subcommand adds a new remote repository, `remove` removes a connection, and `set-url` changes an existing remote repository's URL. The `-v` option shows detailed names and URLs of registered remote repositories. By convention, the main remote repository is named `origin`.

```bash
git remote add origin <URL>
git remote -v  # List remote repositories
git remote set-url origin <new-URL>
```

## Synchronizing with Remote: git push and git pull

The `git push` command uploads commits from the Local Repository to the Remote Repository. The `git pull` command fetches changes from the Remote Repository and merges them into the current branch in the Local Repository. When pushing, the `--force` option forcibly overwrites the remote branch and should be used with caution in collaborative environments. When pulling, the `--rebase` option performs a rebase instead of a merge, maintaining a cleaner history.

```bash
git push origin main
git pull origin main
git pull --rebase origin main  # Rebase method
```

## Branch Management: git branch and git checkout

The `git branch` command creates, lists, and deletes branches. Running without arguments shows the list of local branches. Providing `<branch-name>` as an argument creates a new branch. The `-d` option deletes merged branches, and the `-D` option force-deletes regardless of merge status.

The `git checkout` command switches branches or moves to a specific commit. When used with the `-b` option, it creates a new branch and switches to it immediately. Since Git 2.23.0, the `git switch` command can also be used for branch switching.

```bash
git branch  # List branches
git branch <branch-name>  # Create branch
git checkout <branch-name>  # Switch branch
git checkout -b <branch-name>  # Create + switch
git switch <branch-name>  # Switch branch (Git 2.23+)
```

## Merging Branches: git merge

The `git merge` command integrates changes from the specified branch into the current branch. It finds the common ancestor commit of both branches and performs a 3-way merge. If conflicts occur, they must be manually resolved before committing. The `--no-ff` option always creates a new merge commit even when fast-forward is possible, maintaining clear branch history. The `--squash` option compresses all commits from the target branch into a single commit for merging.

```bash
git merge <branch-name>
git merge --no-ff <branch-name>  # Create merge commit
git merge --squash <branch-name>  # Squash merge
```

## Conclusion

Since its creation by Linus Torvalds in 2005, Git has established itself as the de facto standard version control system in software development. Understanding the 4-area structure of Working Directory → Staging Area → Local Repository → Remote Repository and mastering core commands like `init`, `add`, `commit`, `push`, `pull`, `branch`, and `merge` enables efficient code management for both personal projects and team collaboration. Learning advanced features like `reset`, `revert`, and `rebase` further equips you to handle complex development workflows flexibly.
