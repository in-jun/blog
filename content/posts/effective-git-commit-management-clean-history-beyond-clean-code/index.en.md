---
title: "Git Commit Management and Clean History"
date: 2024-07-13T09:41:43+09:00
tags: ["Git", "Version Control"]
description: "Managing Git history with interactive rebase and squash."
draft: false
---

## History and Importance of Commit Management

Git's commit management features were one of the core design principles when Linus Torvalds developed Git in 2005. The rebase feature existed from Git's early versions, and when interactive rebase was introduced in Git 1.5 in 2007, it became a powerful tool for fine-grained editing of commit history.

Commit history management is important because the Git log serves as documentation of a project's change history. A well-organized history enables understanding of a project's evolution through `git log` alone, allows clear comprehension of each commit's intent when tracking bugs with `git bisect`, and helps new team members quickly grasp the codebase's history when joining a project.

## Applying Single Responsibility Principle to Commits

### Background of the Principle

The Single Responsibility Principle (SRP), one of the SOLID principles of software design, is a concept established by Robert C. Martin in 2003 stating that "a class should have only one reason to change." Applied to Git commits, this becomes "a commit should contain only one logical change."

### Why It Matters

Single responsibility commits are important for several reasons. First, code reviewers can focus on one change at a time, improving review quality. Second, when problems occur, specific changes can be reverted with `git revert`, making rollback easy. Third, `git cherry-pick` can bring specific features to other branches, increasing flexibility. Fourth, narrowing down bug causes with `git bisect` becomes easier.

### Implementation Methods

Concrete methods for applying the single responsibility principle to commits are as follows.

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

The benefits of committing frequently include being able to track changes in detail so you can easily return to a specific point in time, reduced risk of data loss during work, and prevention of large merge conflicts by syncing more frequently with team members.

### WIP Commit Strategy

When committing Work In Progress states, use the `WIP:` prefix with the assumption of cleaning up later. These commits are squashed or cleaned up with rebase before creating a PR.

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

When starting interactive rebase, an editor opens where you can specify actions to perform on each commit.

```bash
git rebase -i HEAD~5  # Edit last 5 commits
```

Available commands in the editor are as follows.

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

The result is only two clean commits:

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

Since `--amend` and `rebase` change the commit's SHA-1 hash, using them on already-pushed commits causes history divergence requiring `--force` push. This can cause conflicts with other team members' local history during collaboration, so avoid using them on shared branches.

```bash
# Before push: safe to use
git commit --amend

# After push: requires force push (caution in collaboration)
git push --force-with-lease origin feature/my-branch
```

`--force-with-lease` is a safer option than `--force` as it fails if someone else has pushed changes, preventing unintended overwrites.

## Reverting Commits with reset

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

Git commit management techniques have continued to evolve since Git's creation in 2005, with features like interactive rebase (2007) and autosquash (2010) being added. The core principles are applying the single responsibility principle to commits to contain only one logical change, committing frequently locally but organizing before push, and maintaining clean history with interactive rebase and fixup/squash. Clean history is as important as clean code, and well-organized commit history improves project quality in all aspects including code review, bug tracking, and new team member onboarding.
