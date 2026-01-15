---
title: "Deleting Branches After Merge: Why and How"
date: 2024-07-11T22:27:22+09:00
tags: ["git", "version control", "collaboration"]
description: "A comprehensive guide covering the entire Git branch lifecycle from creation to deletion, methods to safely verify and delete merged branches, automation scripts, GitHub/GitLab auto-delete settings, and recovery procedures for accidentally deleted branches."
draft: false
---

## Step-by-step Breakdown of Merging

1. **Create a new branch**: Create a new branch from the main branch using `git checkout -b <new-branch-name>`.

2. **Add commits to the branch**: Make code changes in the new branch and commit them in meaningful units.

3. **Push to remote repository**: Upload your working branch to the remote using `git push origin <branch-name>`.

4. **Create a pull request**: Create a pull request on platforms like GitHub to request merging of your changes.

5. **Conduct code reviews**: Team members review the code and request changes if needed.

6. **Perform merge**: Merge the pull request into the main branch once reviews are complete.

This process enables teams to efficiently collaborate while maintaining code quality. Steps can be adjusted or automated based on the specifics of your project.

## Branch Lifecycle

Branches have a clear lifecycle consisting of creation, use, merge, and deletion. Proper management at each stage is necessary. This reduces repository complexity and enhances collaboration efficiency.

### Short-lived Branches vs Long-lived Branches

Branches are classified into two types based on their lifespan. Each has distinct characteristics and purposes. Projects typically use a combination of both types according to their workflow.

**Short-lived branches** are created for specific tasks and are quickly merged and deleted. Feature branches and Hotfix branches fall into this category. Their lifecycle typically completes within days to weeks. It's recommended to delete them immediately after merging.

**Long-lived branches** are maintained throughout the entire project duration. These include main, master, develop, and production branches. They are continuously updated and serve as merge targets for multiple short-lived branches. They should never be deleted.

### Lifecycle by Branch Type

**Feature branches** are created for new feature development. They branch from develop or main. After feature completion, they undergo code review and are merged. They should be deleted immediately after merging to keep the repository clean.

**Release branches** are created for deployment preparation. They branch from develop. Version-related work and bug fixes are performed here. After deployment completion, they are merged to both main and develop, then deleted.

**Hotfix branches** are created for urgent production bug fixes. They branch directly from main. After fixes are complete, they are merged to both main and develop. They should be deleted immediately after merging.

## Why Delete Branches After Merging

Deleting branches after merging provides several important benefits. Firstly, it keeps your repository clean and less cluttered, leading to greater clarity in your development process. It also enhances the performance of Git operations and aids in workflow management by clearly marking the completion of work cycles.

Eliminating unnecessary branches prevents accidental commits to outdated branches and saves storage space. This results in a cleaner Git history for your project, facilitating easier history management.

In terms of team collaboration, deleting branches serves as a signal for work completion and improves communication. From a security standpoint, it reduces potential risks by limiting access to outdated code.

Lastly, minimizing the number of active branches helps developers stay focused on the work at hand, contributing to overall productivity.

## Pre-deletion Verification

Before deleting a branch, you must verify its merge status. This prevents accidentally losing unmerged work. Git provides various commands for this purpose.

### Verifying Merged Branches

To check the list of branches already merged into the current branch, use the `git branch --merged` command. This command displays branches that have been fully merged and can be safely deleted.

```bash
git branch --merged
```

Conversely, to check branches that haven't been merged yet, use the `git branch --no-merged` command. These branches contain unique commits and require caution when deleting.

```bash
git branch --no-merged
```

You can also check merge status based on a specific branch. For example, to check branches merged into the main branch, execute the following.

```bash
git branch --merged main
```

### Checking Local and Remote Branch Status

Verifying the synchronization status between local and remote branches is also important. Use the `-r` option to see remote branch lists, and the `-a` option to see all branches.

```bash
# Remote branch list
git branch -r

# Display both local and remote branches
git branch -a
```

To check the remote tracking status of a specific branch, use the `-vv` option. This shows which remote branch your local branch is tracking and how far ahead or behind it is.

```bash
git branch -vv
```

### Checking Unmerged Commits

You can review differences between branches to check for unmerged commits. Use the `git log` command for this purpose.

```bash
# Check commits only in feature branch and not in main
git log main..feature

# Check bidirectional differences
git log main...feature
```

## How to Delete Branches After Merge

### Local Branch Deletion Commands

Git provides two options for deleting local branches. Each has different purposes and safety levels. You should choose appropriately based on the situation.

**Safe deletion (`-d` option)** only deletes branches that have been merged. It refuses deletion if unmerged commits exist, preventing data loss. This is the generally recommended method.

```bash
git branch -d <branch-name>
```

When attempting to delete an unmerged branch, the following error message is displayed. This indicates the branch contains work that hasn't been merged yet.

```bash
error: The branch 'feature-branch' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature-branch'.
```

**Force deletion (`-D` option)** forcibly deletes a branch regardless of merge status. It deletes even if unmerged commits exist. Recovery can be difficult after deletion, so use it carefully.

```bash
git branch -D <branch-name>
```

This command is useful for discarding experimental branches or unnecessary work. However, you must verify that no important work is included.

### Deleting Remote Branches

There are several ways to delete branches in the remote repository. The most commonly used method is using the `git push` command. This must be performed independently from local deletion.

```bash
# Standard method
git push origin --delete <branch-name>

# Alternative syntax (same functionality)
git push origin :<branch-name>
```

When you delete a remote branch, it's removed from the remote repository. However, tracking branches may still remain in other developers' local repositories. Separate commands are needed to clean these up.

### Cleaning Up Remote Branch References in Local Repository

Cleaning up local references to remotely deleted branches is important for keeping the repository tidy. You can use the `--prune` option of the `git fetch` command to remove stale remote-tracking branches.

```bash
# Fetch latest state of all remote repositories and remove deleted branch references
git fetch --all -p

# Or target only a specific remote repository
git fetch origin --prune
```

The `--prune` option automatically deletes local references to branches that no longer exist in the remote repository. This keeps the remote branch list shown by `git branch -r` up to date.

You can also change your Git configuration to automatically run prune. This way, cleanup occurs automatically with each fetch execution.

```bash
git config --global fetch.prune true
```

## Bulk Branch Deletion Automation

As projects progress and merged branches accumulate, manually deleting them one by one becomes tedious. In such cases, you can use scripts to batch clean branches. This is very useful for regular maintenance tasks.

### Batch Deleting Merged Local Branches

A script to delete all local branches merged into the current branch can safely clean up while protecting important branches like main, master, and develop. It can be written as follows.

```bash
# Delete merged branches except main
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d
```

This command gets the list of merged branches with `git branch --merged`. It excludes main, master, and develop branches with `grep -v`. It uses `xargs` to delete each branch.

You can also create a safer script that requests confirmation before deletion. This prevents accidentally deleting important branches.

```bash
# Preview the list of branches to delete
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop"

# Execute after confirmation
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 -p git branch -d
```

Adding the `-p` option requests confirmation before deleting each branch. You can respond with y/n to selectively delete branches.

### Cleaning Up Local Tracking Branches for Remotely Deleted Branches

A script to find and delete local tracking branches for branches deleted from the remote repository can be written as follows. This is useful for cleaning up local branches that remain even after pruning.

```bash
# Find and delete local branches with broken remote tracking
git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
```

This command first cleans up remote branch references with `git fetch -p`. It checks tracking status with `git branch -vv`. It finds branches marked as `gone` and deletes them.

## Precautions When Deleting Branches

Branch deletion is a difficult operation to undo, so proceed carefully. Keeping several important precautions in mind during work can prevent mistakes. It can maintain your team's workflow safely.

### Protecting Main Branches

Long-lived branches like main, master, develop, and production are core branches of the project and should never be deleted. To prevent accidental deletion, set up Git branch protection rules or explicitly exclude them in scripts.

Platforms like GitHub or GitLab allow you to set branch protection rules to prevent deletion, force pushes, and direct commits to specific branches. This can be configured in repository settings.

### Communicating with Team Members

Before deleting a remote branch, verify that no team members are working on that branch. For shared branches or branches that other team members might use, discuss with the team before deletion. Sudden deletion can cause confusion in collaboration.

### Using Tags for Backup When Needed

If there's a possibility you'll need to reference the work in the branch you're deleting later, you can create a tag before deleting the branch as a backup. Tags are immutable references pointing to specific commits and persist even after branch deletion.

```bash
# Create a tag before deleting the branch
git tag archive/feature-name feature-name
git push origin archive/feature-name

# Then delete the branch
git branch -d feature-name
git push origin --delete feature-name
```

This way, the branch is deleted but the code at that point is always accessible through the tag. If needed, you can create a new branch from the tag to resume work.

## GitHub/GitLab Auto-Delete Settings

GitHub and GitLab provide functionality to automatically delete branches after Pull Requests or Merge Requests are merged. Utilizing this reduces the effort of manually cleaning branches. It automatically keeps the repository tidy.

### GitHub Auto-Delete Settings

In GitHub, you can enable an option in repository settings to automatically delete head branches after Pull Request merges. This is configured per repository. It can also be selected individually when merging PRs.

1. Navigate to the repository's Settings tab.
2. Enable the "Automatically delete head branches" option in the General section.
3. Now source branches are automatically deleted whenever PRs are merged.

When merging individual PRs, a "Delete branch" button is automatically displayed. You can manually click it to delete, or if auto-delete is enabled, deletion occurs simultaneously with the merge.

### GitLab Auto-Delete Settings

GitLab also provides similar functionality. You can enable the option to delete source branches after merge when creating Merge Requests or in project settings. This can be applied project-wide or selected for individual MRs.

1. Navigate to the project's Settings > Merge requests.
2. Enable the "Enable 'Delete source branch' option by default" option.
3. Now the checkbox is selected by default when creating MRs.

### Pros and Cons of Automation

Automatic branch deletion has advantages of reducing management burden and keeping the repository clean. However, it's not suitable for all situations. You should decide considering the project's workflow and the team's working style.

**Advantages** include no manual deletion work needed, automatic repository cleanup, clear termination of branch lifecycle, and preventing accidental commits to outdated branches.

**Disadvantages** include inconvenience when wanting to keep branches, need for recovery if not backed up before auto-deletion, and team members might still be working locally. In such cases, it's better to disable auto-deletion or use it selectively.

## How to Recover Deleted Branches

If you accidentally delete a branch or discover needed work after deletion, you can recover the deleted branch using Git's reflog feature. Reflog stores all HEAD movement history, making it useful for undoing recent operations.

### Recovery Using reflog

The `git reflog` command shows all reference changes that occurred in the local repository in chronological order. Through this, you can find the last commit hash of the deleted branch. You can recover by creating a new branch from that commit.

```bash
# Check reflog
git reflog

# Example output
a1b2c3d HEAD@{0}: checkout: moving from feature-branch to main
e4f5g6h HEAD@{1}: commit: Add new feature
i7j8k9l HEAD@{2}: commit: Fix bug
```

If you've found the last commit hash of the deleted branch, you can recover by creating a new branch from that hash. The branch name can be the same as the original or a different name.

```bash
# Recover deleted branch from commit hash
git checkout -b feature-branch e4f5g6h

# Or recover with original branch name
git branch feature-branch e4f5g6h
```

### Recovering Deleted Remote Branches

If a remote branch is deleted, you can recover it by pushing again if the branch remains locally. If it's not local either, you need to fetch it from another team member's local repository or recover through reflog.

```bash
# If the branch remains locally, push to remote again
git push origin feature-branch

# If not local either, recover through reflog and push
git checkout -b feature-branch e4f5g6h
git push origin feature-branch
```

Reflog maintains records for 90 days by default, so recently deleted branches can be recovered. However, if too much time passes, records are cleaned up and recovery becomes difficult. Always verify important work before deletion.

## Integration with Team Workflow

Branch deletion policies should be integrated with the team's Git workflow to be effective. Clearly defining branch naming conventions, deletion timing, and assigned responsibilities prevents confusion and enables efficient collaboration.

### Branch Naming Conventions and Deletion Policies

Consistent branch naming conventions clarify the purpose and lifespan of branches. Through this, you can easily judge which branches should be deleted. It also helps with writing automation scripts.

```bash
# Naming convention examples
feature/user-authentication    # Feature development - delete after merge
bugfix/login-error            # Bug fix - delete after merge
hotfix/security-patch         # Urgent fix - delete after merge
release/v1.2.0                # Release preparation - delete after deployment
experiment/new-architecture   # Experimental work - delete or keep after decision
```

Defining deletion policies for each branch type enables team members to manage branches consistently. For example, you can create rules like feature and bugfix delete immediately after merge, release deletes after deployment completion, and experiment decides after team discussion.

### Regular Branch Cleanup Schedule

Including regular branch review and cleanup schedules in team processes can prevent the repository from becoming messy. It's good to perform branch cleanup tasks at sprint end, after releases, or on set dates each month.

During cleanup work, you can proceed in the order of checking the merged branch list, creating tags if needed, executing automation scripts for batch deletion, and sharing cleanup details with team members.

```bash
# Regular cleanup script example
#!/bin/bash

echo "=== Branch Cleanup Report ==="
echo "Date: $(date)"
echo ""

echo "Merged branches to be deleted:"
git branch --merged main | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop"

echo ""
echo "Proceeding with deletion..."
git branch --merged main | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d

echo ""
echo "Pruning remote references..."
git fetch --all -p

echo ""
echo "Cleanup completed!"
```

Including such scripts in the team's documented processes and executing them regularly can consistently keep the repository tidy. You can also integrate them into CI/CD pipelines for automation.

## Conclusion

Regular branch management is the core of an efficient Git workflow. By understanding the branch lifecycle, verifying merge status, using appropriate deletion commands, and utilizing automation, you can keep the repository clean and facilitate smooth team collaboration. Keeping precautions when deleting in mind and knowing recovery methods allows you to confidently manage branches without fearing mistakes. Integrating branch deletion policies into the team's workflow enables more systematic and efficient version control.
