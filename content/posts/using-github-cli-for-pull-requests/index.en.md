---
title: "Creating Pull Requests with GitHub CLI"
date: 2024-07-19T00:39:08+09:00
tags: ["github", "cli", "pr"]
draft: false
---

Let's dive into a detailed explanation of how to create Pull Requests (PRs) using GitHub CLI. GitHub CLI is a tool that allows you to perform GitHub operations directly from the terminal, enabling efficient work without going through the GUI interface.

## 1. Introduction to GitHub CLI

GitHub CLI (`gh`) is GitHub's official command-line tool that enables you to use most GitHub features from the terminal. The main benefits of this tool include:

-   **Efficiency**: Perform GitHub operations using only the keyboard, without using a mouse
-   **Automation**: Integrate GitHub operations into scripts
-   **Consistency**: Use the same commands across all platforms

## 2. Installing GitHub CLI

The installation method for GitHub CLI varies depending on your operating system. Here are the installation methods for major platforms:

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install gh
```

### macOS

```bash
brew install gh
```

### Windows

Windows users can download and install the installer from the [GitHub CLI installation page](https://cli.github.com/).

After installation, you can verify the installation by checking the version:

```bash
gh --version
```

## 3. GitHub CLI Authentication

Before using GitHub CLI, you need to authenticate with your GitHub account. Start the authentication process with:

```bash
gh auth login
```

If you choose browser authentication, a browser window will open requesting GitHub login. After logging in, return to the CLI to complete authentication.

To verify successful authentication:

```bash
gh auth status
```

This command shows current authentication status and connected account information.

## 4. Preparing Local Repository

Before creating a PR, you need to prepare your local repository. Follow these steps:

1. **Navigate to your repository**:

    ```bash
    cd path/to/your/repository
    ```

2. **Fetch latest changes**:

    ```bash
    git fetch origin
    git pull origin main # or your default branch name
    ```

3. **Create and switch to new branch**:

    ```bash
    git checkout -b feature/new-feature
    ```

4. **Make changes**: Apply necessary changes to your code

5. **Stage and commit changes**:

    ```bash
    git add .
    git commit -m "feat: add new feature"
    ```

6. **Push new branch to remote**:
    ```bash
    git push -u origin feature/new-feature
    ```

## 5. Creating a PR

Now you're ready to create a PR. Here's how to create one using GitHub CLI:

```bash
gh pr create
```

This command will prompt you for the following information:

1. PR title
2. PR body (description)
3. Target branch for the PR (typically `main` or `master`)

You can also provide this information directly using command-line options:

```bash
gh pr create --title "Add new feature" --body "This PR adds XXX feature." --base main
```

Key options:

-   `--title`, `-t`: PR title
-   `--body`, `-b`: PR body
-   `--base`: Target branch for the PR
-   `--draft`: Create as draft PR
-   `--assignee`, `-a`: User to assign to PR
-   `--label`, `-l`: Labels to add to PR
-   `--milestone`, `-m`: Milestone to connect to PR

For example, to create a draft PR and assign yourself:

```bash
gh pr create --draft --assignee @me
```

## 6. Managing PRs

After creating a PR, you can perform various management tasks using GitHub CLI.

### Viewing PR List

To see the list of open PRs in the current repository:

```bash
gh pr list
```

You can use various filter options:

```bash
gh pr list --assignee @me --label bug --state all
```

This shows all PRs (open/closed) assigned to you with the 'bug' label.

### Viewing PR Details

To view details of a specific PR:

```bash
gh pr view <PR-number>
```

To view PR for current branch:

```bash
gh pr view
```

### Checking Out a PR

To checkout a specific PR locally for review:

```bash
gh pr checkout <PR-number>
```

### Assigning Reviewers

Assigning reviewers is an important part of the code review process. You can easily assign reviewers using GitHub CLI:

```bash
gh pr edit <PR-number> --add-reviewer username1,username2
```

You can assign multiple reviewers at once, separated by commas. To assign a team as reviewer, prefix the team name with organization name:

```bash
gh pr edit <PR-number> --add-reviewer org-name/team-name
```

### Performing PR Reviews

As a reviewer, you can review PRs using GitHub CLI. The review process includes:

1. **Check PR content**:

    ```bash
    gh pr view <PR-number>
    ```

2. **Review changes**:

    ```bash
    gh pr diff <PR-number>
    ```

3. **Submit review**:
    ```bash
    gh pr review <PR-number>
    ```

Various review options are available:

-   **Approve**:

    ```bash
    gh pr review <PR-number> --approve -b "Changes reviewed and approved."
    ```

-   **Request changes**:

    ```bash
    gh pr review <PR-number> --request-changes -b "Please modify the following: ..."
    ```

-   **Add comment only**:
    ```bash
    gh pr review <PR-number> --comment -b "Here are some suggestions: ..."
    ```

### Approving and Merging PRs

Once review is complete and all requirements are met, you can approve and merge the PR:

Approve PR:

```bash
gh pr review <PR-number> --approve
```

Merge PR:

```bash
gh pr merge <PR-number>
```

Various merge options are available:

```bash
gh pr merge <PR-number> --merge  # standard merge
gh pr merge <PR-number> --squash # squash merge
gh pr merge <PR-number> --rebase # rebase merge
```

## 7. Advanced Usage

### Using Templates

You can maintain consistent PR format using templates. Create a `.github/PULL_REQUEST_TEMPLATE.md` file in your repository to define the PR template.

### Checking CI Status

To check CI status of a PR:

```bash
gh pr checks <PR-number>
```

### PR Automation

You can automate PR processes by combining GitHub Actions with GitHub CLI. This allows automatic PR creation, reviewer assignment, and status updates based on specific conditions.

## 8. Tips and Tricks

1. **Use aliases**: Create aliases for frequently used commands:

    ```bash
    gh alias set prc 'pr create --draft --assignee @me'
    ```

2. **Use configuration file**: Configure GitHub CLI defaults through `~/.config/gh/config.yml`

3. **JSON output**: Get output in JSON format for scripting:

    ```bash
    gh pr view <PR-number> --json number,title,state
    ```

4. **Open in browser**: Open PR directly in web browser:

    ```bash
    gh pr view <PR-number> --web
    ```

5. **Update GitHub CLI**: Regularly update GitHub CLI for new features:
    ```bash
    gh release upgrade
    ```

## 9. Conclusion

Now you know how to create and manage Pull Requests using GitHub CLI. Using GitHub CLI allows you to perform GitHub operations directly from the terminal, making your workflow more efficient. Master these PR creation and management methods, and utilize GitHub CLI's various features to improve your development process.
