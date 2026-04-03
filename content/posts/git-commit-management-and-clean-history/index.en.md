---
title: "Git Commit Management and Clean History"
date: 2024-07-13T09:41:43+09:00
tags: ["Git", "Version Control"]
description: "Managing Git history with interactive rebase and squash."
draft: false
---

## History and Importance of Commit Management

Thoughtful commit management has been part of Git's design since Linus Torvalds created it in 2005. Rebase existed from the early days, and interactive rebase, introduced in Git 1.5 in 2007, turned it into a powerful tool for fine-grained history editing.

Commit history management matters because the Git log serves as documentation for a project's evolution. A well-organized history makes it easier to understand how the project changed over time. It also makes each commit's intent clearer when tracking bugs with `git bisect` and helps new team members get up to speed faster.

## Applying Single Responsibility Principle to Commits

### Background of the Principle

The Single Responsibility Principle (SRP), one of the SOLID principles of software design, is a concept established by Robert C. Martin in 2003 stating that "a class should have only one reason to change." Applied to Git commits, this becomes "a commit should contain only one logical change."

### Why It Matters

Single responsibility commits matter for several reasons. First, code reviewers can focus on one change at a time, which improves review quality. Second, when problems occur, you can revert a specific change with `git revert`, making rollback easier. Third, `git cherry-pick` lets you bring a specific feature to another branch more flexibly. Fourth, `git bisect` becomes more effective when each commit has a narrow scope.

### Implementation Methods

Here are a few practical ways to apply the single responsibility principle to commits.

**Separate by logical units**: Bug fixes, feature additions, and refactoring should each be separate commits. For example, if you fix an existing bug while adding a login feature, separate the bug fix commit from the feature addition commit.

**The "and" test**: If "and" appears in your commit message, it's a signal that the commit should be split. "Add login feature and fix signup form" should be separated into two commits.

**Utilize Staging Area**: Using `git add -p` (patch mode) allows selective staging of changes within a file, which is useful when there are multiple logical changes in a single file.

```bash
# Stage only part of a file's changes
git add -p filename.js

# Select in interactive mode
# y: stage this hunk
# n: skip this hunk
# s: split hunk into smaller pieces
# e: manually edit
```

## Commit Frequently

### Benefits

Committing frequently makes it easier to trace changes in detail and return to a specific point in time. It also reduces the risk of losing work and helps prevent large merge conflicts by encouraging more frequent syncs with teammates.

### WIP Commit Strategy

When committing work in progress, use the `WIP:` prefix and plan to tidy it up later. Before opening a PR, squash or reorganize these commits with rebase.

```bash
# WIP commit examples
git commit -m "WIP: Add login form skeleton"
git commit -m "WIP: Connect login to API"
git commit -m "WIP: Add error handling"

# Clean up before PR
git rebase -i HEAD~3
# Squash three commits into one complete commit
```

### Considerations

Too frequent commits can fragment history, so commit frequently locally but organize into logical units before pushing to remote. Use rebase and squash for this purpose.

## Cleaning History with Interactive Rebase

### History of Rebase

While `git rebase` existed from Git's early versions, interactive rebase (`git rebase -i`) was introduced in Git 1.5.4 in 2007. Developed by Johannes Schindelin, this feature is a powerful tool for fine-grained editing of commit history and remains a core feature of Git workflows today.

### Basic Usage

When you start an interactive rebase, Git opens an editor where you can choose an action for each commit.

```bash
git rebase -i HEAD~5  # Edit last 5 commits
```

The editor supports the following commands.

| Command | Abbreviation | Description |
|---------|--------------|-------------|
| pick | p | Keep commit as-is |
| reword | r | Modify commit message only |
| edit | e | Stop to amend commit |
| squash | s | Combine with previous commit and merge messages |
| fixup | f | Combine with previous but discard message |
| drop | d | Delete commit |

### Practical Example: Cleaning Up Commits

Working locally can result in commit history like this:

```
abc1234 Add login feature
def5678 Fix typo in login
ghi9012 Add missing import
jkl3456 Fix login button style
mno7890 Add logout feature
```

To clean this up:

```bash
git rebase -i HEAD~5
```

In the editor:

```
pick abc1234 Add login feature
fixup def5678 Fix typo in login
fixup ghi9012 Add missing import
fixup jkl3456 Fix login button style
pick mno7890 Add logout feature
```

This results in just two clean commits:

```
abc1234 Add login feature
mno7890 Add logout feature
```

### Using autosquash

The `--autosquash` option introduced in Git 1.7.4 automatically arranges commits with `fixup!` or `squash!` prefixes in their messages. This allows marking commits to be cleaned up later in advance.

```bash
# Original commit
git commit -m "Add user authentication"

# Later modification needed
git commit --fixup=abc1234  # Commits with message "fixup! Add user authentication"

# Auto-arranges during rebase
git rebase -i --autosquash HEAD~3
```

## Modifying Last Commit with amend

### Use Scenarios

`git commit --amend` is used to modify a just-created commit. Since it modifies an existing commit rather than creating a new one, history remains clean.

```bash
# When you forgot to add a file
git add forgotten-file.js
git commit --amend --no-edit

# When you want to modify the commit message
git commit --amend -m "feat: Add user authentication with JWT"

# Modify both file and message
git add extra-file.js
git commit --amend -m "feat: Add user authentication with JWT and refresh token"
```

### Precautions

Since `--amend` and `rebase` change a commit's SHA-1 hash, using them on commits that have already been pushed causes history divergence and requires a force push. That can conflict with other team members' local history, so avoid using them on shared branches.

```bash
# Before push: safe to use
git commit --amend

# After push: requires force push (caution in collaboration)
git push --force-with-lease origin feature/my-branch
```

`--force-with-lease` is a safer option than `--force` as it fails if someone else has pushed changes, preventing unintended overwrites.

## Resetting Commits with reset

### Difference Between soft, mixed, and hard

`git reset` changes HEAD's position, with different effects on Staging Area and Working Directory depending on the option.

| Option | HEAD | Staging Area | Working Directory |
|--------|------|--------------|-------------------|
| --soft | moves | preserved | preserved |
| --mixed (default) | moves | reset | preserved |
| --hard | moves | reset | reset |

```bash
# soft: undo commit only, keep changes staged
git reset --soft HEAD~1

# mixed: undo commit, keep changes unstaged
git reset HEAD~1

# hard: delete commit and all changes (caution!)
git reset --hard HEAD~1
```

### Practical Use: Alternative to squash

Soft reset can be used as a simple way to combine multiple commits into one.

```bash
# Combine last 3 commits into one
git reset --soft HEAD~3
git commit -m "feat: Add complete user authentication system"
```

## Conclusion

Git commit management techniques have continued to evolve since Git was created in 2005, with features like interactive rebase (2007) and autosquash (2010) added along the way. The core principles are simple: keep each commit focused on one logical change, commit frequently during local work, and clean up history before pushing. Clean history matters as much as clean code, and a well-organized commit log improves code review, bug tracking, and onboarding.
