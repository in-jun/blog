---
title: "Creating Pull Requests with GitHub CLI"
date: 2024-07-19T00:39:08+09:00
tags: ["github", "cli", "pr", "git", "devops"]
description: "GitHub CLI (gh) is the official command-line tool for performing GitHub operations in the terminal. It enables efficient handling of the entire workflow from PR creation to review and merge without GUI, and can also be used for automation and scripting."
draft: false
---

GitHub CLI (gh) is the official command-line interface tool released by GitHub in September 2020. It allows you to use core GitHub features directly from the terminal, enabling tasks that were previously performed through web browsers, such as creating Pull Requests, managing issues, and managing repositories, with a single command. Since developers often write code and manage versions in the terminal, using GitHub CLI allows maintaining a consistent workflow without context switching and can significantly improve productivity by automating repetitive tasks.

## Introduction to GitHub CLI

> **What is GitHub CLI?**
>
> GitHub's official command-line tool that enables using core GitHub features such as Pull Requests, Issues, Repositories, and GitHub Actions from the terminal. It wraps the REST API and GraphQL API to provide an intuitive command interface.

GitHub CLI was developed to replace the existing `hub` command. Since it is directly developed and maintained by GitHub, new GitHub features are quickly supported upon release. Written in Go language, it can run as a single binary on various platforms and is developed as open source, receiving community contributions.

### Key Benefits

**Improved Efficiency**: You can perform GitHub operations using only the keyboard without a mouse and web browser, keeping your development flow uninterrupted. You can create or review PRs directly from your IDE or terminal, reducing context switching costs.

**Automation Support**: GitHub operations can be integrated into scripts and CI/CD pipelines, enabling workflow automation such as automatically creating PRs, adding labels, or assigning reviewers under specific conditions. It supports JSON output for easy integration with other tools.

**Consistent Interface**: The same commands can be used across all platforms including macOS, Linux, and Windows, making it easy to share and document consistent workflows among team members. You can work the same way even in new environments.

**Rich Features**: In addition to PR and Issue management, it supports almost all GitHub features including repository creation and cloning, GitHub Actions management, Gist creation, release management, and Codespaces access.

## Installing GitHub CLI

Installation methods for GitHub CLI vary by operating system. It can be easily installed through each platform's package manager, and installation can be verified by checking the version after installation.

### Linux (Ubuntu/Debian)

On Ubuntu and Debian-based Linux, you can install through the apt package manager. Adding GitHub's official package repository allows you to maintain the latest version.

```bash
# Add GitHub CLI package repository
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install
sudo apt update
sudo apt install gh
```

Or you can simply install directly with apt.

```bash
sudo apt update
sudo apt install gh
```

### macOS

On macOS, you can easily install through Homebrew. If Homebrew is not installed, you need to install Homebrew first.

```bash
brew install gh
```

### Windows

On Windows, you can install in several ways using package managers such as winget, Chocolatey, or Scoop, or by downloading the official installer.

```bash
# Using winget
winget install --id GitHub.cli

# Using Chocolatey
choco install gh

# Using Scoop
scoop install gh
```

Alternatively, you can download the Windows installer from the [GitHub CLI official site](https://cli.github.com/).

### Verifying Installation

After installation, verify that it was installed correctly by checking the version.

```bash
gh --version
# Example output: gh version 2.40.0 (2024-01-15)
```

## GitHub CLI Authentication

Before using GitHub CLI, you must authenticate with your GitHub account. The authentication process supports two methods: browser-based OAuth authentication and Personal Access Token authentication. In most cases, browser-based authentication is simpler and more secure.

### Starting the Authentication Process

```bash
gh auth login
```

Running this command displays an interactive prompt that provides the following choices:

1. **GitHub.com vs GitHub Enterprise Server**: Select the GitHub instance to authenticate
2. **HTTPS vs SSH**: Select your preferred protocol
3. **Browser authentication vs token authentication**: Select the authentication method

If you choose browser authentication, a one-time code is displayed, the browser opens automatically, and after logging into GitHub and entering the code, authentication is complete. Returning to the terminal displays an authentication success message.

### Checking Authentication Status

To check current authentication status and connected account information, use the following command.

```bash
gh auth status
```

Example output shows the currently logged-in account, protocol in use, and token scopes.

```
github.com
  ✓ Logged in to github.com as username (oauth_token)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ✓ Token scopes: gist, read:org, repo, workflow
```

### Additional Authentication Options

If you use multiple GitHub accounts or need to authenticate with GitHub Enterprise Server, you can perform additional authentication.

```bash
# GitHub Enterprise Server authentication
gh auth login --hostname github.mycompany.com

# Authenticate with specific scopes
gh auth login --scopes "repo,read:org,workflow"

# Authenticate with Personal Access Token
gh auth login --with-token < token.txt
```

## Pull Request Creation Workflow

Before creating a PR, you need to properly prepare your local repository. Let's look at the entire workflow from branch creation to push and PR creation in order.

### Preparing Local Repository

**1. Navigate to the working repository and sync to latest state**

```bash
cd path/to/your/repository
git fetch origin
git pull origin main  # or your default branch name
```

**2. Create and switch to a new branch**

Name the branch to clearly indicate the work content, following your team's branch naming conventions.

```bash
git checkout -b feature/user-authentication
# or git switch -c feature/user-authentication
```

**3. Make code changes and commit**

Apply necessary changes to the code and commit in meaningful units.

```bash
git add .
git commit -m "feat: implement user authentication logic"
```

**4. Push branch to remote repository**

```bash
git push -u origin feature/user-authentication
```

The `-u` option sets the upstream branch so you can omit the branch name in subsequent `git push` and `git pull` commands.

### Creating a PR

Once local repository preparation is complete, you can create a PR with GitHub CLI. It supports both interactive and non-interactive modes.

**Interactive Mode**

```bash
gh pr create
```

Running this command displays an interactive prompt where you can sequentially enter PR title, body, target branch, etc. A text editor opens for writing detailed PR descriptions.

**Non-Interactive Mode (using command-line options)**

Suitable for scripts and automation, providing all information as command-line options.

```bash
gh pr create \
  --title "feat: implement user authentication" \
  --body "## Summary
- Add login/logout functionality
- Implement JWT token handling
- Add password validation

## Test Plan
- [ ] Unit tests for auth service
- [ ] Integration tests for login flow" \
  --base main \
  --assignee @me \
  --reviewer teammate1,teammate2 \
  --label "enhancement,auth"
```

### Key PR Creation Options

| Option | Short | Description |
|--------|-------|-------------|
| `--title` | `-t` | PR title |
| `--body` | `-b` | PR body (description) |
| `--base` | `-B` | Target branch to merge PR into |
| `--head` | `-H` | Source branch of the PR |
| `--draft` | `-d` | Create as draft PR |
| `--assignee` | `-a` | User to assign to PR (use `@me` for yourself) |
| `--reviewer` | `-r` | Assign reviewers (comma-separated) |
| `--label` | `-l` | Labels to add to PR (comma-separated) |
| `--milestone` | `-m` | Milestone to associate with PR |
| `--project` | `-p` | Project to add PR to |
| `--web` | `-w` | Open in web browser after creation |

### Practical PR Creation Examples

```bash
# Create draft PR (when not ready for review)
gh pr create --draft --title "WIP: refactor payment module"

# Assign yourself and specify a specific team as reviewer
gh pr create --assignee @me --reviewer myorg/backend-team

# Open PR page in web
gh pr create --web

# Read body from file
gh pr create --title "Release v2.0.0" --body-file CHANGELOG.md
```

## PR Management

After creating a PR, you can perform various management tasks using GitHub CLI, including listing, viewing details, checkout, and status monitoring.

### Listing PRs

List PRs in the current repository with various filter options to filter only the PRs you want.

```bash
# List open PRs (default)
gh pr list

# List PRs of all states
gh pr list --state all

# PRs assigned to yourself
gh pr list --assignee @me

# PRs with specific label
gh pr list --label bug

# Combined filters
gh pr list --assignee @me --label "bug,urgent" --state open

# PRs targeting a specific branch
gh pr list --base main

# Show only last 10
gh pr list --limit 10
```

You can also change the output format to JSON for use in scripts.

```bash
gh pr list --json number,title,author,state
```

### Viewing PR Details

View detailed information of a specific PR in the terminal by specifying the PR number or viewing the PR of the current branch.

```bash
# View specific PR
gh pr view 123

# View PR of current branch
gh pr view

# Open in web browser
gh pr view 123 --web

# View specific fields in JSON format
gh pr view 123 --json title,body,state,reviews
```

### Checking Out PRs

You can checkout another person's PR locally to test or review. This feature is very useful when you want to run code locally during code review.

```bash
# Checkout by PR number
gh pr checkout 123

# Return to original branch after checkout
git checkout -
```

### Monitoring PR Status

View the current status of PRs related to you at a glance, showing PRs you created, PRs requesting your review, and PRs mentioning you separately.

```bash
gh pr status
```

Example output:

```
Relevant pull requests in owner/repo

Created by you
  #123  feat: add user auth [feature/auth]
    - Checks passing - Review required

Requesting a code review from you
  #456  fix: resolve memory leak [bugfix/memory]
    - Checks passing - Changes requested

Involving you
  #789  docs: update API documentation [docs/api]
    - Checks failing
```

### Checking CI Check Status

View the execution status of PR's CI/CD pipeline, including success/failure status and details of each check.

```bash
# Check CI check status
gh pr checks 123

# Wait until checks complete
gh pr checks 123 --watch

# Show only failed checks
gh pr checks 123 --fail-only
```

## PR Review

GitHub CLI allows performing the entire PR review process in the terminal, including viewing changes, writing comments, and approving or requesting changes.

### Assigning Reviewers

Add or remove reviewers from a PR. Both individual users and teams can be assigned.

```bash
# Add reviewers
gh pr edit 123 --add-reviewer username1,username2

# Assign team as reviewer
gh pr edit 123 --add-reviewer myorg/frontend-team

# Remove reviewer
gh pr edit 123 --remove-reviewer username1

# Add reviewer to PR of current branch
gh pr edit --add-reviewer username1
```

### Viewing Changes

View PR diff directly in the terminal with color highlighting for easy identification of changes.

```bash
# View PR diff
gh pr diff 123

# View diff of specific file only (using pipe and grep)
gh pr diff 123 | grep -A 20 "filename.js"
```

### Submitting Reviews

When submitting a review, you can choose from three types: approve, request-changes, or comment.

```bash
# Approve
gh pr review 123 --approve --body "Code review complete, well written."

# Request changes
gh pr review 123 --request-changes --body "Please modify the following:
- Error handling needs to be added
- Test coverage is insufficient"

# Comment only (without approve/reject)
gh pr review 123 --comment --body "I have some suggestions..."

# Review in interactive mode (editor opens)
gh pr review 123
```

### Writing Comments

Write comments about the PR as a whole. Use this when leaving general comments separate from reviews.

```bash
# Add comment to PR
gh pr comment 123 --body "Build test completed. Works without issues."

# Open editor to write comment
gh pr comment 123 --editor
```

## PR Merging

Once review is complete and all requirements are met, you can merge the PR. GitHub CLI supports three merge strategies and provides branch deletion options after merge.

### Merge Commands

```bash
# Interactive mode (select merge strategy)
gh pr merge 123

# Standard merge (creates merge commit)
gh pr merge 123 --merge

# Squash merge (combines all commits into one)
gh pr merge 123 --squash

# Rebase merge (reapplies commits on top of target branch)
gh pr merge 123 --rebase
```

### Merge Options

```bash
# Delete source branch after merge
gh pr merge 123 --squash --delete-branch

# Auto-merge after all checks pass
gh pr merge 123 --auto --squash

# Specify merge commit message
gh pr merge 123 --merge --subject "feat: user authentication (#123)"

# Specify merge commit body
gh pr merge 123 --merge --body "Closes #100, #101"
```

### Enabling Auto-Merge

Using the `--auto` option enables automatic merging when all required reviews and CI checks pass. This feature requires auto-merge to be enabled in repository settings.

```bash
# Enable auto-merge
gh pr merge 123 --auto --squash --delete-branch

# Disable auto-merge
gh pr merge 123 --disable-auto
```

## Editing and Updating PRs

You can edit the title, body, labels, milestones, and more of created PRs using the `gh pr edit` command.

```bash
# Edit title
gh pr edit 123 --title "feat: implement user authentication v2"

# Edit body
gh pr edit 123 --body "Updated description..."

# Add/remove labels
gh pr edit 123 --add-label "priority:high" --remove-label "priority:low"

# Set milestone
gh pr edit 123 --milestone "v2.0"

# Add to project
gh pr edit 123 --add-project "Sprint 5"

# Change draft status
gh pr ready 123  # Change from draft to ready for review
```

## Advanced Features and Automation

### Setting Aliases

Set aliases for frequently used command combinations to increase productivity. Sharing the same aliases across the entire team helps maintain consistent workflows.

```bash
# Create aliases
gh alias set prc 'pr create --draft --assignee @me'
gh alias set prv 'pr view --web'
gh alias set prs 'pr status'
gh alias set prm 'pr merge --squash --delete-branch'

# Use aliases
gh prc  # Create draft PR and assign to self
gh prv  # View PR in web
gh prs  # Check PR status
gh prm 123  # Squash merge and delete branch

# List aliases
gh alias list

# Delete alias
gh alias delete prc
```

### Using JSON Output

JSON output can be used when integrating with scripts or other tools. Combined with JSON processing tools like `jq`, powerful automation is possible.

```bash
# Output specific fields as JSON
gh pr view 123 --json number,title,state,author,reviews

# Extract specific values with jq
gh pr view 123 --json title --jq '.title'

# Extract only PR numbers of open PRs
gh pr list --json number --jq '.[].number'

# Filter only review-approved PRs
gh pr list --json number,reviews --jq '.[] | select(.reviews | any(.state == "APPROVED")) | .number'
```

### Using PR Templates

Creating a `.github/PULL_REQUEST_TEMPLATE.md` file in the repository automatically fills PR descriptions with template content when creating PRs. To use multiple templates, create multiple markdown files in the `.github/PULL_REQUEST_TEMPLATE/` directory and select with the `--template` option.

```bash
# Use specific template
gh pr create --template bug_fix.md
```

### Integration with GitHub Actions

GitHub CLI can be used in CI/CD pipelines to build automated PR workflows. In GitHub Actions environments, `GITHUB_TOKEN` is automatically set, allowing use without separate authentication.

```yaml
# .github/workflows/auto-pr.yml example
name: Auto PR
on:
  push:
    branches:
      - 'feature/**'

jobs:
  create-pr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create PR
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr create --title "Auto PR: ${GITHUB_REF_NAME}" \
                       --body "Automated PR for feature branch" \
                       --base main
```

### Configuration File

GitHub CLI default settings can be configured through the `~/.config/gh/config.yml` file, including default editor, protocol, and aliases.

```yaml
# ~/.config/gh/config.yml example
git_protocol: ssh
editor: vim
prompt: enabled
pager: less
aliases:
  prc: pr create --draft --assignee @me
  prv: pr view --web
```

## Useful Tips

**Quick open in web browser**: Use the `--web` option when you want to view a PR in a web browser, and the PR page opens immediately.

```bash
gh pr view 123 --web
gh pr create --web
```

**Working with current branch**: If no PR number is specified, it works on the PR of the currently checked-out branch.

```bash
gh pr view      # View PR of current branch
gh pr edit      # Edit PR of current branch
gh pr merge     # Merge PR of current branch
```

**Updating GitHub CLI**: Update regularly to receive new features and bug fixes.

```bash
# macOS
brew upgrade gh

# Linux
sudo apt update && sudo apt upgrade gh
```

## Conclusion

GitHub CLI is a powerful tool that enables efficient GitHub operations from the terminal. It can handle the entire workflow from PR creation to review and merge with a single command, and can reduce repetitive work and increase productivity through automation and scripting. It is particularly useful for developers who prefer keyboard-centric workflows and helps maintain consistent PR processes across the entire team.
