---
title: "Adjusting Git Commit Times"
date: 2024-05-25T23:31:13+09:00
tags: ["Git", "Version Control", "Development"]
draft: false
---

## Introduction

There may be situations where you need to adjust the time of a Git commit. For example:

- Organizing commit history across different time zones
- Maintaining a chronological commit history of a project
- Adjusting timestamps of restored code from a backup

However, adjusting commit times should be done with caution, especially in collaborative projects.

## Methods to Adjust Commit Times

### 1. Specify Time When Creating a New Commit

When creating a new commit, you can specify a specific time:

```bash
# Using ISO 8601 format
git commit --date="2024-05-25T23:31:13+09:00" -m "feat: Implement login feature"

# Specifying relative time
git commit --date="2 days ago" -m "docs: Update README"
```

### 2. Modify Time of Recent Commit

To modify the time of just the most recent commit:

```bash
# Modifying time only
git commit --amend --date="2024-05-25T23:31:13+09:00" --no-edit

# Modifying both time and message
git commit --amend --date="2024-05-25T23:31:13+09:00" -m "Amended commit message"
```

### 3. Modify Time of Past Commits

To modify the time of a specific past commit, use interactive rebase:

```bash
# Modify last 3 commits
git rebase -i HEAD~3

# Modify from a specific commit onwards
git rebase -i <commit-hash>
```

In the rebase editor:

```
edit abc1234 First commit message
pick def5678 Second commit message
pick ghi9012 Third commit message
```

Then:

```bash
git commit --amend --date="2024-05-25T23:31:13+09:00" --no-edit
git rebase --continue
```

## Practical Use Cases

### Scenario 1: Syncing Offline Work

```bash
# Commit your yesterday's work
git add .
git commit --date="yesterday 14:30" -m "feat: Offline work"
```

### Scenario 2: Adjust for Time Zone Difference

```bash
# Set commit time in UTC
git commit --date="2024-05-25T14:31:13Z" -m "docs: Update API specification"
```

## Precautions

1. **Usage in Collaborative Projects**

    - Avoid modifying time of already-pushed commits
    - Consult with teammates beforehand
    - Create a separate branch to work in

2. **Maintaining Git History**

    - Modifying commit time changes history
    - May require force push
    - Backup is recommended

3. **Best Practices**

    ```bash
    # Backup current state before changes
    git branch backup/before-rebase

    # Force push if necessary after changes
    git push origin master --force-with-lease
    ```

## Conclusion

Adjusting commit times is a useful Git feature, but it should be used with caution. Especially in collaborative projects, consider team policies and Git workflow before using it.
