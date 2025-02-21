---
title: "How to Use Git: From Basic to Advanced"
date: 2024-07-08T20:52:04+09:00
tags: ["git", "version control", "collaboration"]
draft: false
---

## About: Git is a must-have distributed version control system for developers. It tracks changes to source code over time and helps multiple developers collaborate more efficiently. In this post, we'll take an in-depth look at the core concepts of Git, cover essential commands in detail, along with real-world use cases and useful options of each command.

## Understanding the Basic Structure of Git

Git consists of four major areas:

1. Working Directory: The place where the actual files reside. This is where you write and modify your code.
2. Staging Area: A place to temporarily hold changes that are ready to be committed.
3. Local Repository: Where your committed versions are stored.
4. Remote Repository: A repository on a server that is shared with your team.

Understanding this structure will help you grasp the behavior of Git commands more easily.

## Guide to Essential Git Commands

### 1. Initializing Git: `git init`

```bash
git init
```

**Usage:** Use this when starting a new project. This command initializes the current directory as a Git repository.

**What it does:** Creates a hidden directory called `.git`, where Git stores all the information it needs for version control.

### 2. Checking File Status: `git status`

```bash
git status
```

**Usage:** Use this to check the state of your working directory and staging area. You can see which files have been modified and which are ready to be committed.

**Important Options:**

- `-s` or `--short`: Output the status in a compact format.
- `-b` or `--branch`: Shows the current branch information as well.

### 3. Staging Files: `git add`

```bash
git add <file-name>
```

**Usage:** Adds modified files to the staging area in order to include them in the next commit.

**Important Options:**

- `.`: Stage all changes in the current directory.
- `-p`: Allows you to review and stage each change individually.
- `-u`: Stages only the files that are already tracked.

**Example Usage:**

```bash
git add -p
```

Using this command, you can go through each change one by one and select to stage them, which allows for more precise commits.

### 4. Unstaging Files: `git restore`

```bash
git restore --staged <file-name>
```

**Usage:** Use this to move files you have added to the staging area back to your working directory.

**Important Options:**

- `--staged`: Unstage staged changes.
- No option: Unstage modifications in the working directory.

**Example Usage:**

```bash
git restore --staged .
```

This command will unstage all staged changes.

**Note:** Versions of Git before 2.23.0 used the `git reset` command for this purpose:

```bash
git reset HEAD <file-name>
```

### 5. Committing Changes: `git commit`

```bash
git commit -m "commit message"
```

**Usage:** Records your staged changes as a new version in the repository.

**Important Options:**

- `-m`: Write the commit message inline.
- `-a`: Automatically stage and commit all changes in tracked files.
- `--amend`: Amends the last commit.

**Example Usage:**

```bash
git commit -am "fix: resolve login error"
```

This command stages all changes in tracked files and commits them in one go.

If you don't use the `-m` option, Git will open your default text editor to let you type in the commit message. The commit message should be a concise description of what the changes represent.

### 6. Undoing Commits: `git reset` and `git revert`

**Undoing a Commit:**

```bash
git reset HEAD^
```

**Usage:** Use this to undo the latest commit and revert those changes back to the working directory.

**Important Options:**

- `--soft`: Undo the commit but keep the changes in the staging area.
- `--mixed`: (Default) Undo the commit and revert the changes to the working directory.
- `--hard`: Undo the commit and delete the changes entirely. Use with caution.

**Example Usage:**

```bash
git reset --soft HEAD~3
```

This command will undo the last 3 commits and keep those changes in the staging area.

**Undoing a Commit that's Pushed to Remote:**

```bash
git revert <commit-hash>
```

**Usage:** Use this to safely undo a commit that has already been pushed to a remote repository. It creates a new commit that reverses the previous changes.

**Example Usage:**

```bash
git revert abc123
```

This command will create a new commit that undoes the commit with the hash 'abc123'.

### 7. Checking Commit History: `git log`

```bash
git log
```

**Usage:** Use this to view the commit history of your project. You can see who, when, and what changes were made.

**Important Options:**

- `--oneline`: Show each commit in a single, compact line.
- `--graph`: Display the branch and merge history as a graph.
- `--stat`: Show statistics for changed files in each commit.

**Example Usage:**

```bash
git log --oneline --graph --all
```

This command will show the commit history of all branches, in a graphical and compact way.

### 8. Managing Remote Repositories: `git remote`

```bash
git remote add origin <remote-repository-url>
```

**Usage:** Use this to connect your local repository to a remote repository.

**Important Commands:**

- `add`: Add a new remote repository.
- `remove`: Remove a remote repository.
- `set-url`: Change the URL of an existing remote repository.

**Example Usage:**

```bash
git remote set-url origin https://github.com/username/repo.git
```

This command changes the URL of the remote repository named 'origin'.

### 9. Synchronizing with Remotes: `git push` and `git pull`

```bash
git push origin main
git pull origin main
```

**Usage:**

- `push`: Uploads your local commits to the remote repository.
- `pull`: Fetches and merges changes from the remote repository into your local repository.

**Important Options:**

- `--force`: Force the remote branch to be overwritten when pushing. Use with caution.
- `--rebase`: Perform a rebase instead of a merge when pulling.

**Example Usage:**

```bash
git pull --rebase origin main
```

This command fetches changes from the remote and rebases your local commits in the process.

### 10. Managing Branches: `git branch` and `git checkout`

```bash
git branch <branch-name>
git checkout <branch-name>
```

**Usage:**

- `branch`: Create new branches or manage existing ones.
- `checkout`: Switch to a different branch.

**Important Options:**

- `-b`: (with checkout) Create a new branch and switch to it immediately.
- `-d`: (with branch) Delete a branch.

**Example Usage:**

```bash
git checkout -b A
```

This command creates a new branch named 'A' and switches to it immediately.

### 11. Merging Branches: `git merge`

```bash
git merge <branch-name>
```

**Usage:** Use this to integrate changes from one branch into another.

**Important Options:**

- `--no-ff`: Always create a new commit when merging.
- `--squash`: Squash all commits from the branch into a single commit when merging.

**Example Usage:**

```bash
git merge --squash A
```

This command will merge all changes from the 'A' branch into the current branch, squashing them into a single commit.

## Conclusion

Git is a powerful and versatile version control tool. By mastering the basics covered in this post, you'll be able to manage your code efficiently, whether it's for personal projects or collaborative team development. Learning more advanced features of Git will further equip you to handle even complex development projects with ease.
