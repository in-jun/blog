---
title: "Adjusting Git Commit Timestamps"
date: 2024-05-25T23:31:13+09:00
tags: ["Git", "Version Control"]
description: "Methods for modifying AuthorDate and CommitDate in Git commits."
draft: false
---

## Structure of Git Timestamps

Git's timestamp system was designed to record two separate times from when Linus Torvalds designed Git in 2005. This was because in Linux kernel development, the time a patch was written and the time it was actually committed could differ.

### AuthorDate and CommitDate

Git commits have two timestamps.

**AuthorDate** represents when the code was first written, meaning when the original author made the change. It is set via the `git commit --date` option or the `GIT_AUTHOR_DATE` environment variable.

**CommitDate** represents when the commit was actually recorded in the repository. It is updated whenever a commit is regenerated through rebase, cherry-pick, amend, etc., and can be set using the `GIT_COMMITTER_DATE` environment variable.

```bash
# Check both timestamps
git log --format=fuller

# Example output
# commit abc1234
# Author:     John Doe <john@example.com>
# AuthorDate: Sat May 25 14:30:00 2024 +0900
# Commit:     John Doe <john@example.com>
# CommitDate: Sun May 26 10:15:42 2024 +0900
```

In the example above, AuthorDate and CommitDate differ because the original author wrote the code on Saturday, but the commit was regenerated through rebase or amend and newly recorded on Sunday.

### When Timestamps Differ

There are several situations where AuthorDate and CommitDate differ.

- **git cherry-pick**: When bringing a commit from another branch, AuthorDate preserves the original, CommitDate becomes current time
- **git rebase**: When reapplying commits, only CommitDate is updated
- **git commit --amend**: When modifying a commit, CommitDate is updated to current time
- **Applying patches (git am)**: When applying patches received via email, AuthorDate preserves the original author's time

## Methods to Adjust Commit Times

### Specifying Time When Creating New Commits

When creating a new commit, you can specify AuthorDate with the `--date` option, which supports various date formats.

```bash
# ISO 8601 format (most clear and recommended)
git commit --date="2024-05-25T14:30:00+09:00" -m "feat: Add login feature"

# RFC 2822 format
git commit --date="Sat, 25 May 2024 14:30:00 +0900" -m "feat: Add login feature"

# Relative time (interpreted by Git)
git commit --date="2 days ago" -m "docs: Update README"
git commit --date="yesterday 14:30" -m "fix: Resolve bug"

# Unix timestamp
git commit --date="@1716613800" -m "feat: Add feature"
```

### Modifying Last Commit Time

To modify the time of the most recent commit, use `--amend` together with `--date`.

```bash
# Change only AuthorDate (CommitDate will be updated to current time)
git commit --amend --date="2024-05-25T14:30:00+09:00" --no-edit

# Set both AuthorDate and CommitDate to the same value
GIT_COMMITTER_DATE="2024-05-25T14:30:00+09:00" \
git commit --amend --date="2024-05-25T14:30:00+09:00" --no-edit

# Also modify the message
git commit --amend --date="2024-05-25T14:30:00+09:00" -m "feat: Add login feature"
```

### Modifying Past Commit Times

To modify the time of a specific past commit, use interactive rebase.

```bash
# Modify last 3 commits
git rebase -i HEAD~3
```

In the editor, change the commit to modify to `edit`.

```
edit abc1234 First commit message
pick def5678 Second commit message
pick ghi9012 Third commit message
```

When rebase stops at that commit, modify the time and continue.

```bash
# Modify time
GIT_COMMITTER_DATE="2024-05-25T14:30:00+09:00" \
git commit --amend --date="2024-05-25T14:30:00+09:00" --no-edit

# Proceed to next commit
git rebase --continue
```

### Batch Modifying Multiple Commits

When you need to modify times of multiple commits at once, you can use `filter-branch` or `filter-repo`, but these rewrite the entire history so must be used with extreme caution.

```bash
# filter-branch example (deprecated, filter-repo recommended)
git filter-branch --env-filter '
if [ "$GIT_COMMIT" = "abc1234..." ]
then
    export GIT_AUTHOR_DATE="2024-05-25T14:00:00+09:00"
    export GIT_COMMITTER_DATE="2024-05-25T14:00:00+09:00"
fi' -- --all

# Using git-filter-repo (faster and safer)
# Install with: pip install git-filter-repo
git filter-repo --commit-callback '
if commit.original_id == b"abc1234...":
    commit.author_date = b"1716613800 +0900"
    commit.committer_date = b"1716613800 +0900"
'
```

## Practical Use Scenarios

### Syncing Offline Work

Use this when you want to commit work done in offline environments like airplanes or subways with the actual work time.

```bash
# Commit work done yesterday at 2 PM
git add .
git commit --date="yesterday 14:30" -m "feat: Add offline feature"

# Match both AuthorDate and CommitDate
GIT_COMMITTER_DATE="yesterday 14:30" \
git commit --date="yesterday 14:30" -m "feat: Add offline feature"
```

### Time Zone Conversion

Use this when you worked during overseas travel or need to match a collaborating team's time zone.

```bash
# Commit in UTC time
git commit --date="2024-05-25T14:30:00Z" -m "feat: Add feature"

# Commit in US Eastern Time (EST)
git commit --date="2024-05-25T14:30:00-05:00" -m "feat: Add feature"
```

### GitHub Contribution Graph

When you want to display a commit on a specific date in GitHub's Contribution graph, adjust the AuthorDate. GitHub calculates Contributions based on AuthorDate.

```bash
# Leave contribution record on specific date
git commit --date="2024-01-01T12:00:00+09:00" -m "chore: Happy new year commit"
```

## Precautions

### Collaboration Considerations

Modifying the time of commits already pushed to a remote repository changes the commit hash, requiring `--force` push. This can cause conflicts with other team members' local history, so avoid using it on shared branches.

```bash
# Force push (dangerous - be cautious in collaboration)
git push --force origin feature/my-branch

# Safer method (fails if someone else has pushed)
git push --force-with-lease origin feature/my-branch
```

### Backup Recommended

Backing up the current state before time modification allows recovery if problems occur.

```bash
# Create backup branch before work
git branch backup/before-time-adjustment

# Recover if problems occur
git reset --hard backup/before-time-adjustment
```

### Ethical Considerations

While adjusting commit times is technically possible, using it to manipulate work time records or falsify work history can be ethically problematic. It should only be used for legitimate purposes like syncing offline work or adjusting time zones.

## Conclusion

Git's timestamp system is divided into AuthorDate (original author's writing time) and CommitDate (repository recording time), a design that reflects the characteristics of distributed version control systems. You can specify new commit AuthorDate with the `--date` option, modify the last commit with `--amend`, adjust past commits with interactive rebase, and use the `GIT_COMMITTER_DATE` environment variable to also change CommitDate. However, modifying times of already-pushed commits requires history rewriting, so it should be used carefully in collaborative environments.
