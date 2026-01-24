---
title: "How to Delete Merged Git Branches"
date: 2024-07-11T22:27:22+09:00
tags: ["Git", "Version Control", "Collaboration"]
description: "Safely deleting merged branches in Git."
draft: false
---

In Git, a branch is a core concept that provides an independent workspace, allowing developers to develop new features or fix bugs without affecting the main codebase. This branch-based workflow has been one of the key design philosophies since Linus Torvalds designed Git in 2005, which is also why Git branches are designed to be much lighter and faster than other version control systems like SVN or CVS. However, deleting branches after merging is just as important as creating them in the first place. This article comprehensively covers the necessity of branch deletion, specific methods, automation, and recovery procedures.

## Branch-Based Development Workflow

The branch-based development workflow in Git has become the standard in most modern software development teams. The general process of this workflow proceeds as follows, and each step can be adjusted or automated depending on the project characteristics and team size.

### Common Branch Workflow

**1. Create a new branch**: Branch off from the main branch (main or develop), naming the branch to clearly indicate the work content. You can use a command like `git checkout -b feature/user-authentication` to create and checkout the branch simultaneously.

**2. Add commits**: Make code changes in the new branch and commit them in meaningful units. Each commit should contain a single logical change, and commit messages should clearly describe the changes.

**3. Push to remote repository**: Upload your working branch to the remote repository using the `git push origin feature/user-authentication` command, allowing other team members to review and check your work.

**4. Create a Pull Request**: Create a Pull Request (or Merge Request) on platforms like GitHub, GitLab, or Bitbucket to request merging of changes. This process includes describing the work and assigning reviewers.

**5. Code review**: Team members review the code, provide feedback, and request modifications if necessary. This is an important step for improving code quality and promoting knowledge sharing.

**6. Execute Merge**: Once reviews are complete and approval is received, merge the Pull Request into the main branch. At this point, choose a merging strategy that fits the team's policy, such as Merge Commit, Squash Merge, or Rebase.

**7. Delete branch**: Once merging is complete, the branch is no longer needed, so delete it to keep the repository clean.

## Branch Lifecycle and Types

Branches have a clear lifecycle of creation, use, merge, and deletion. Proper management at each stage is necessary. Through this lifecycle management, you can reduce repository complexity and increase collaboration efficiency. Branches are broadly classified into two types based on their lifespan and purpose.

### Short-lived Branches

> **What are short-lived branches?**
>
> Branches created for specific tasks that are quickly merged and deleted. Their lifecycle typically completes within days to weeks, and it is recommended to delete them immediately after merging.

**Feature branches** are the most common type of short-lived branch, created for new feature development. They branch from develop or main to proceed with feature development. After development completion, they undergo code review and are merged. The general practice is to delete them immediately after merging to keep the repository clean.

**Bugfix branches** are created for bug fixes and have a similar lifecycle to feature branches, but typically have a shorter lifespan. They are used for non-urgent bug fixes and deleted after merging.

**Hotfix branches** are created to fix urgent bugs discovered in the production environment. They branch directly from main (or production), and after fixes are complete, they are merged to both main and develop. They should be deleted immediately after merging to clearly indicate completion of the urgent fix.

**Release branches** are created for deployment preparation. They branch from develop to proceed with deployment preparation tasks such as version number updates, final bug fixes, and documentation. After deployment completion, they are merged to both main and develop and then deleted.

### Long-lived Branches

> **What are long-lived branches?**
>
> Branches maintained throughout the entire project duration. They are continuously updated and serve as merge targets for multiple short-lived branches. These branches should never be deleted.

**main (or master)** branch contains stable code deployed to the production environment. Direct commits are discouraged, and only merges from other branches occur. All commits must maintain a deployable state.

**develop** branch is where development work for the next release is integrated. It serves as the target for feature branch merges and maintains a state ahead of the main branch while preparing for the next deployment.

**production** or **staging** branches are additional long-lived branches operated depending on the project. They correspond to production and staging environments respectively and are maintained continuously.

## Why Delete Branches After Merging

Deleting merged branches is not just a cleanup task but an essential practice for healthy repository management. The benefits are diverse and contribute to improved productivity for the entire team.

### Repository Readability and Management Efficiency

Deleting merged branches keeps the repository clean so developers can only see currently active work. When dozens or hundreds of old branches accumulate, the output of the `git branch` command becomes cluttered and it becomes difficult to find branches that are actually being worked on. This can be a serious problem especially in large-scale projects. Additionally, a clean branch list helps new team members joining the project understand the current ongoing work and allows them to understand the overall state of the project at a glance.

### Git Performance Optimization

Git can experience performance degradation in some operations as the number of branches increases. Commands like `git branch -a`, `git fetch`, and `git gc` are particularly affected by the number of branches. In large-scale projects with thousands of branches, the execution time of these commands can noticeably increase. Regular branch cleanup helps maintain the overall performance of Git operations.

### Mistake Prevention and Workflow Clarification

When old merged branches remain, developers can accidentally commit to those branches. This can cause code to be reflected in the wrong place or cause merge conflicts. Such mistakes are particularly easy to make when multiple branches with similar names exist. Branch deletion also serves as a clear signal of work completion, functioning as a communication tool to inform team members that the feature or fix has been completed and integrated into the main codebase.

### Storage Space and Security

Branches themselves don't take up much storage space (Git branches are essentially just pointers to specific commits). However, maintaining branches in the remote repository means those references are cloned together with each clone, and unnecessary data can accumulate over time. From a security perspective, old branches may contain sensitive information or code with vulnerabilities, and cleaning them up can reduce potential security risks.

## Pre-Deletion Verification

Before deleting a branch, you must verify its merge status. This prevents accidentally losing unmerged work. Git provides various commands for this verification.

### Verifying Merged Branches

The `git branch --merged` command displays a list of branches already merged into the currently checked-out branch. Branches appearing in this list can be safely deleted because all commits from those branches are included in the current branch.

```bash
# List branches merged into the current branch
git branch --merged

# List branches merged into a specific branch (e.g., main)
git branch --merged main

# List remote branches that are merged
git branch -r --merged main
```

Conversely, the `git branch --no-merged` command is used to check branches that haven't been merged yet. These branches have unique commits and require caution when deleting as work may be lost.

```bash
# List branches not yet merged
git branch --no-merged

# Branches not merged into a specific branch
git branch --no-merged main
```

### Checking Local and Remote Branch Status

Understanding the synchronization status between local and remote branches is also important. The `-r` option shows only remote branches, the `-a` option shows both local and remote branches, and the `-vv` option shows detailed tracking status and commit differences for each branch.

```bash
# Remote branch list
git branch -r

# Display both local and remote branches
git branch -a

# Include tracking status and ahead/behind information
git branch -vv
```

Example output of `git branch -vv` shows which remote branch each branch is tracking and how many commits ahead or behind the remote it is.

```
* main              abc1234 [origin/main] Latest commit message
  feature/login     def5678 [origin/feature/login: ahead 2] Add login feature
  bugfix/typo       ghi9012 [origin/bugfix/typo: gone] Fix typo
```

In the above output, branches marked as `gone` indicate that they have already been deleted from the remote but the tracking branch remains locally.

### Checking Commit Differences Between Branches

Before deleting a branch, it's good to check if there are commits that exist only in that branch. You can use the range specification syntax of the `git log` command to check commit differences between branches.

```bash
# Check commits only in feature branch and not in main
git log main..feature

# Check bidirectional differences (show commits only in either side)
git log main...feature --oneline

# Check only the number of commits
git log main..feature --oneline | wc -l
```

## Branch Deletion Methods

### Local Branch Deletion

Git provides two options for deleting local branches, each with different safety levels and purposes. Choose appropriately based on the situation.

> **Safe deletion (-d option)**
>
> The `git branch -d <branch-name>` command only deletes branches that have been merged. If unmerged commits exist, it refuses deletion to prevent accidental data loss.

```bash
# Safe deletion (merged branches only)
git branch -d feature/user-authentication

# Delete multiple branches at once
git branch -d feature/login feature/signup bugfix/typo
```

When attempting to delete an unmerged branch with the `-d` option, Git displays the following error message, warning that the branch contains unique work that hasn't been merged to another branch.

```
error: The branch 'feature-branch' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature-branch'.
```

> **Force deletion (-D option)**
>
> The `git branch -D <branch-name>` command forcibly deletes a branch regardless of merge status. Since it deletes even if unmerged commits exist, recovery can be difficult after deletion. Use it carefully.

```bash
# Force deletion (regardless of merge status)
git branch -D experimental-feature

# Used when discarding experimental or no longer needed work
git branch -D spike/prototype
```

Force deletion is useful when discarding experimental branches, when deciding to re-implement in a different direction, or when cleaning up incorrectly created branches. However, you must verify that no important work is included.

### Remote Branch Deletion

Deleting branches in the remote repository is an operation independent of local deletion. You can use the `git push` command to delete remote branches, and two syntaxes perform the same function.

```bash
# Standard syntax (recommended)
git push origin --delete feature/user-authentication

# Alternative syntax (using colon)
git push origin :feature/user-authentication

# Delete multiple branches at once
git push origin --delete feature/login feature/signup
```

When you delete a remote branch, it is removed from the remote repository. However, other developers' local repositories may still have tracking references to that remote branch (`origin/feature/user-authentication`). Separate commands are needed to clean these up.

### Cleaning Up Remote Branch References (Prune)

Cleaning up local tracking references to remotely deleted branches is important for keeping the repository tidy. You can use the `--prune` option of the `git fetch` command to automatically remove local references to branches that no longer exist in the remote.

```bash
# Fetch latest state from remote repository and remove deleted branch references
git fetch origin --prune

# Execute for all remote repositories
git fetch --all --prune

# Abbreviated form
git fetch -p
```

You can also change Git settings to automatically run prune with every fetch. This way, cleanup always occurs without specifying the `--prune` option separately.

```bash
# Enable auto prune as global setting
git config --global fetch.prune true

# Set for specific repository only
git config fetch.prune true
```

## Bulk Branch Deletion Automation

As projects progress and merged branches accumulate, manually deleting them one by one becomes tedious. In such cases, you can use scripts to clean up branches in bulk. This is very useful for regular maintenance tasks.

### Batch Deleting Merged Local Branches

The following script deletes all local branches merged into the current branch while protecting important branches like main, master, and develop for safe cleanup.

```bash
# Delete merged branches except main
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d
```

The working principle of this command is as follows:

1. `git branch --merged`: Output list of branches merged into current branch
2. `grep -v "\*"`: Exclude currently checked-out branch (marked with `*`)
3. `grep -v "main"` etc.: Exclude branch names to protect
4. `xargs -n 1 git branch -d`: Safely delete each branch one by one

A safer approach that requests confirmation before deletion is also available. Adding the `-p` option allows confirmation with y/n before each branch deletion.

```bash
# Preview list of branches to delete (dry run)
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop"

# Delete after confirmation for each branch
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 -p git branch -d
```

### Cleaning Up Local Tracking Branches for Remotely Deleted Branches

A script to find and delete local tracking branches for branches deleted from the remote repository is useful for cleaning up local branches that remain even after pruning. It finds and deletes branches marked as `gone`.

```bash
# Find and delete local branches with broken remote tracking
git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
```

This command first cleans up remote branch references with `git fetch -p`, checks tracking status with `git branch -vv`, finds branches marked as `gone` (deleted from remote), and force deletes them.

### Reusable Cleanup Script

Creating a reusable script for regular branch cleanup is convenient. The following is an example script that performs cleanup work and reports results.

```bash
#!/bin/bash
# branch-cleanup.sh - Git branch cleanup script

echo "=== Git Branch Cleanup Report ==="
echo "Date: $(date)"
echo "Repository: $(basename $(git rev-parse --show-toplevel))"
echo ""

# List of branches to protect
PROTECTED_BRANCHES="main|master|develop|production|staging"

echo "Protected branches: $PROTECTED_BRANCHES"
echo ""

# Check merged branches
echo "Merged branches that can be deleted:"
git branch --merged main | grep -v "\*" | grep -Ev "($PROTECTED_BRANCHES)" | sed 's/^/  /'

echo ""
echo "Remote tracking branches with 'gone' status:"
git branch -vv | grep ': gone]' | awk '{print "  " $1}'

echo ""
read -p "Do you want to proceed with deletion? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting merged branches..."
    git branch --merged main | grep -v "\*" | grep -Ev "($PROTECTED_BRANCHES)" | xargs -n 1 git branch -d 2>/dev/null

    echo "Pruning remote references..."
    git fetch --all -p

    echo "Deleting gone tracking branches..."
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D 2>/dev/null

    echo ""
    echo "Cleanup completed!"
else
    echo "Cleanup cancelled."
fi
```

## Precautions When Deleting Branches

Branch deletion is an operation that is difficult to undo, so proceed carefully. Keeping a few important precautions in mind can prevent mistakes and maintain your team's workflow safely.

### Protecting Main Branches

Long-lived branches like main, master, develop, and production are core branches of the project and should never be deleted. To prevent accidental deletion, it is recommended to set up Branch Protection Rules on platforms like GitHub and GitLab, and these branches should be explicitly excluded in scripts.

**GitHub branch protection settings**:
1. Navigate to Repository Settings and then Branches
2. Click "Add rule" in "Branch protection rules"
3. Enter the branch pattern to protect (e.g., `main`)
4. Enable the "Prevent deletions" option

### Communication with Team Members

Before deleting a remote branch, verify that no team members are working on that branch. Shared branches or branches that others might use should be discussed with the team before deletion. Sudden deletion can cause confusion in collaboration. Branches with open Pull Requests or branches under review should not be deleted carelessly, and branches referenced by CI/CD pipelines also need verification before deletion.

### Using Tags for Backup

If there's a possibility you'll need to reference the work in the branch you're deleting later, you can create a tag before deleting the branch as a backup. Tags are immutable references pointing to specific commits and persist even after branch deletion, allowing access at any time later.

```bash
# Backup to tag before deleting branch
git tag archive/feature-user-auth feature/user-authentication
git push origin archive/feature-user-auth

# Then delete the branch
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication

# Recover from tag later if needed
git checkout -b feature/user-authentication-restored archive/feature-user-auth
```

Using the archive prefix makes it easier to distinguish from regular release tags and manage the tag list. You can set appropriate naming conventions according to team policy.

## GitHub/GitLab Auto-Delete Settings

GitHub and GitLab provide functionality to automatically delete source branches after Pull Requests or Merge Requests are merged. Utilizing this reduces the effort of manually cleaning branches and automatically keeps the repository tidy.

### GitHub Auto-Delete Settings

In GitHub, you can enable an option in repository settings to automatically delete head branches after Pull Request merges. This is configured per repository and can also be selected individually when merging PRs.

1. Navigate to Repository Settings and then General
2. Enable the "Automatically delete head branches" checkbox in the "Pull Requests" section
3. Source branches are automatically deleted whenever PRs are merged thereafter

The "Delete branch" button is also displayed on the individual PR merge screen. If auto-delete is configured, deletion occurs simultaneously with the merge. Even if not configured, you can manually click the button to delete.

### GitLab Auto-Delete Settings

GitLab also provides similar functionality. You can enable the option to delete source branches after merge when creating Merge Requests or in project settings. It can be applied project-wide or selected for individual MRs.

1. Navigate to Project Settings and then Merge requests
2. Enable "Enable 'Delete source branch' option by default" in the "Squash commits when merging" section
3. The delete option is selected by default when creating MRs thereafter

### Pros and Cons of Automation

Automatic branch deletion has the advantage of reducing management burden and keeping the repository clean. However, it's not suitable for all situations, and you should decide considering the project's workflow and team's working style.

**Advantages** include eliminating the need for manual deletion work, automatic repository cleanup, clear termination of branch lifecycle, and preventing accidental commits to outdated branches.

**Disadvantages** include needing separate measures if you want to keep branches, needing recovery work if not backed up before auto-deletion, team members may still be working locally, and some workflows may require keeping branches even after merging.

## How to Recover Deleted Branches

If you accidentally delete a branch or discover needed work after deletion, you can recover the deleted branch using Git's reflog feature. Reflog stores all movement history of HEAD and branch references, making it very useful for undoing recent work.

### Understanding reflog

> **What is reflog?**
>
> Short for reference log, it's a mechanism that stores all records of HEAD and branch reference changes in the local repository. Records are maintained for 90 days by default and can be used to undo operations like branch deletion, commit modification, and rebase.

```bash
# Check reflog
git reflog

# Check reflog for a specific branch
git reflog show feature/user-authentication

# Example output
a1b2c3d HEAD@{0}: checkout: moving from feature-branch to main
e4f5g6h HEAD@{1}: commit: Add user authentication feature
i7j8k9l HEAD@{2}: commit: Create login form
m3n4o5p HEAD@{3}: checkout: moving from main to feature-branch
```

Each entry in the reflog output represents a point when HEAD pointed to that commit. You can use the `HEAD@{n}` format reference to access commits at specific points.

### Recovering Local Branches

If you've found the last commit hash of the deleted branch in reflog, you can recover by creating a new branch from that commit. The branch name can be the same as the original or a different name.

```bash
# Find last commit of deleted branch in reflog
git reflog | grep "feature-branch"

# Recover branch from that commit
git checkout -b feature-branch e4f5g6h

# Or create branch only (without checkout)
git branch feature-branch e4f5g6h

# Recovery using HEAD reference
git checkout -b feature-branch HEAD@{2}
```

### Recovering Remote Branches

If a remote branch is deleted, you can recover by pushing again if the branch remains locally. If it's not local either, you need to fetch from another team member's local repository or recover through reflog and then push.

```bash
# If the branch remains locally
git push origin feature-branch

# If not local either: recover through reflog and push
git checkout -b feature-branch e4f5g6h
git push -u origin feature-branch
```

Reflog exists only in the local repository and maintains records for 90 days by default. Recently deleted branches can be recovered, but if too much time passes, records are cleaned up and recovery becomes difficult. Important work should be verified before deletion and backed up with tags if necessary.

## Integrating Branch Deletion Policy into Team Workflow

Branch deletion policies should be integrated with the team's Git workflow to be effective. Clearly defining branch naming conventions, deletion timing, and assigned responsibilities prevents confusion and enables efficient collaboration.

### Deletion Policies by Branch Type

Consistent branch naming conventions clarify the purpose and lifespan of branches. Through this, you can easily judge which branches should be deleted and when. It also helps with writing automation scripts.

```bash
# Branch naming and deletion policy examples
feature/*      # Feature development - delete immediately after PR merge
bugfix/*       # Bug fix - delete immediately after PR merge
hotfix/*       # Urgent fix - delete immediately after merge
release/*      # Release preparation - delete after deployment (or preserve with tag)
experiment/*   # Experimental work - decide after team discussion
spike/*        # Technical verification - delete after verification complete
```

### Regular Branch Cleanup Schedule

Including regular branch review and cleanup schedules in team processes can prevent the repository from becoming messy. It's good to perform branch cleanup tasks at sprint end, after releases, or on set dates each month.

The general procedure for cleanup work is as follows:

1. Check the list of merged branches
2. Create tags for backup if needed
3. Execute automation scripts for batch deletion
4. Share cleanup details with team members

### CI/CD Pipeline Integration

Branch cleanup work can also be automated by integrating into CI/CD pipelines. For example, you can set up regularly scheduled jobs (Cron Jobs) to clean up old merged branches, or configure release pipelines to automatically delete release branches at the final stage.

## Conclusion

Regular branch management is the core of an efficient Git workflow. By understanding the branch lifecycle, verifying merge status, using appropriate deletion commands, and utilizing automation, you can keep the repository clean and facilitate smooth team collaboration. Keeping deletion precautions in mind and knowing recovery methods allows you to confidently manage branches without fearing mistakes. Integrating branch deletion policies into the team's workflow enables more systematic and efficient version control.
