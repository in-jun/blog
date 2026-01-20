---
title: "Effective Commit Message Writing Guidelines"
date: 2024-07-12T08:48:08+09:00
tags: ["git", "commit", "conventional-commits", "version-control"]
description: "Commit message conventions started with Tim Pope's guidelines in 2008 and evolved into the Conventional Commits standard in 2017, with key principles including 50-character subject limit, imperative mood, type prefixes, and explaining what and why in the body"
draft: false
---

## History and Importance of Commit Messages

Systematic guidelines for writing commit messages became widely known in 2008 when Tim Pope proposed the 50/72 rule (50-character subject, 72-character body line wrap) in his blog post "A Note About Git Commit Messages." In 2014, the commit message convention developed by the Angular team for the AngularJS project gained industry attention. In 2017, Conventional Commits 1.0.0 was released based on this foundation, and it has since become the most widely used standard in open source projects.

Commit messages are important because Git history serves as documentation of a project's change history. Well-written commit messages allow understanding of a project's evolution through `git log` alone, enable immediate comprehension of which change caused a problem when using `git bisect` to find bug-introducing commits, and significantly reduce the time code reviewers spend understanding the intent behind changes.

## Commit Message Structure

A commit message consists of three parts: subject, body, and footer, each separated by a blank line.

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Subject Line Rules

The subject summarizes the commit's core content in one line and follows these rules.

**Keep it under 50 characters**: Exceeding 50 characters causes truncation in `git log --oneline` or GitHub's commit list, so the message should convey only the essentials concisely.

**Use imperative mood**: Since Git's auto-generated messages (Merge branch, Revert commit) use imperative mood, write "Add feature" for consistency rather than "Added feature" or "Adding feature."

**Omit the period**: The subject is a title, not a sentence, so no period is needed. This saves space and provides visual consistency.

**Capitalize the first letter**: In English, start with a capital letter to improve readability and give a professional impression.

```bash
# Good examples
feat: Add user authentication
fix: Resolve null pointer exception in UserService
refactor: Extract payment logic into separate module

# Bad examples
feat: added user authentication.  # Past tense, period
Fix null pointer  # Lowercase type, insufficient description
```

### Body Rules

The body explains details that cannot be conveyed in the subject alone. While not required for every commit, it should be written when explaining complex changes or non-obvious decisions.

**Focus on What and Why**: Since "How" the code changed can be seen by looking at the code itself, the body should explain "what was changed" and "why this change was necessary." The "why" is particularly important as it provides essential context for future developers (including yourself) to understand the reasoning behind the change.

**72-character line wrap**: Wrap at 72 characters for readability when viewing `git log` in a terminal. This width provides optimal readability in an 80-character terminal when accounting for indentation and margins.

```
fix: Resolve race condition in payment processing

The payment service occasionally processed duplicate charges when
users clicked the submit button multiple times in quick succession.

This fix introduces a debounce mechanism that:
- Disables the submit button immediately on click
- Uses a unique idempotency key per transaction
- Adds server-side duplicate detection within 5-second window

The 5-second window was chosen based on analysis of production logs
showing 99% of duplicate requests occur within 3 seconds.

Closes #456
```

### Footer Rules

The footer records metadata such as issue linking, Breaking Change declarations, and co-author attribution, following the `Key: Value` format.

```
feat(api): Add pagination to user list endpoint

Implement cursor-based pagination for better performance with large
datasets. Page size defaults to 20 with maximum of 100.

BREAKING CHANGE: Response format changed from array to object with
`data` and `nextCursor` fields.

Closes #789
Co-authored-by: Jane Doe <jane@example.com>
Reviewed-by: John Smith <john@example.com>
```

## Conventional Commits Types

The types defined in the Conventional Commits standard allow immediate recognition of a commit's nature, with each type having a clear purpose.

| Type | Purpose | Example |
|------|---------|---------|
| feat | New feature addition | feat: Add OAuth2 social login |
| fix | Bug fix | fix: Resolve memory leak in cache |
| docs | Documentation changes | docs: Update API documentation |
| style | Code formatting (no behavior change) | style: Apply prettier formatting |
| refactor | Refactoring (not feature/bugfix) | refactor: Extract validation logic |
| perf | Performance improvement | perf: Optimize database queries |
| test | Test addition/modification | test: Add unit tests for UserService |
| build | Build system/external dependency changes | build: Upgrade webpack to v5 |
| ci | CI configuration changes | ci: Add GitHub Actions workflow |
| chore | Other changes (outside src/test) | chore: Update .gitignore |
| revert | Reverting previous commit | revert: Revert "feat: Add login" |

### Using Scope

Scope specifies the module or component affected by the change, written in parentheses. It's recommended to define a consistent scope list for each project.

```bash
feat(auth): Add two-factor authentication
fix(api): Handle timeout errors gracefully
docs(readme): Add installation instructions
refactor(core): Simplify event handling logic
```

### Indicating Breaking Changes

Changes that break API compatibility can be indicated in two ways: by appending `!` after the type or by specifying `BREAKING CHANGE:` in the footer.

```bash
# Method 1: Using ! after type
feat(api)!: Change authentication endpoint response format

# Method 2: Using footer
feat(api): Change authentication endpoint response format

BREAKING CHANGE: The /auth/login endpoint now returns a JSON object
instead of a plain token string. Clients must update to extract the
token from the `accessToken` field.
```

## Automation Tools

Tools for enforcing and utilizing commit message rules have evolved over time.

**Commitlint**, which emerged in 2016, automatically validates whether commit messages follow defined rules and can be used with Husky to perform checks via Git hooks before commits.

**Commitizen** provides an interactive CLI that makes it easy to write commit messages following the rules, accepting type, scope, and description step by step through the `git cz` command.

**standard-version** and **semantic-release** are tools that analyze Conventional Commits messages to automatically determine semantic versions and generate CHANGELOGs. Feat commits increment the minor version, fix commits increment the patch version, and BREAKING CHANGE increments the major version.

```json
// package.json example
{
  "scripts": {
    "commit": "cz",
    "release": "standard-version"
  },
  "devDependencies": {
    "@commitlint/cli": "^17.0.0",
    "@commitlint/config-conventional": "^17.0.0",
    "commitizen": "^4.0.0",
    "cz-conventional-changelog": "^3.0.0",
    "husky": "^8.0.0",
    "standard-version": "^9.0.0"
  },
  "config": {
    "commitizen": {
      "path": "cz-conventional-changelog"
    }
  }
}
```

## Practical Examples

### Feature Addition

```
feat(auth): Implement JWT refresh token mechanism

Add automatic token refresh to prevent session expiration during
active use. The refresh token is stored in an HTTP-only cookie
for security.

Implementation details:
- Refresh tokens expire after 7 days of inactivity
- Access tokens are refreshed 5 minutes before expiration
- Failed refresh attempts redirect to login page

Security considerations:
- Refresh tokens are rotated on each use
- Old refresh tokens are invalidated immediately

Closes #234
```

### Bug Fix

```
fix(payment): Prevent duplicate charges on network timeout

Users were occasionally charged twice when the payment gateway
response timed out but the charge actually succeeded.

Root cause: The frontend retried the request without checking
if the original transaction completed.

Solution:
- Generate idempotency key before first request attempt
- Store pending transactions in local state
- Check transaction status before retry

Affected users have been identified and refunds are being processed
separately (see issue #567).

Closes #543
```

### Refactoring

```
refactor(core): Replace callback pattern with async/await

Modernize the codebase by converting callback-based async operations
to async/await syntax for improved readability and error handling.

Changes:
- Convert 47 files from callbacks to async/await
- Add proper try/catch blocks for error handling
- Remove callback utility functions that are no longer needed

No functional changes; all existing tests pass.

Related to #890
```

## Conclusion

Commit message conventions evolved from Tim Pope's 50/72 rule in 2008 through the Angular convention in 2014 to the Conventional Commits standard in 2017. The key principles are an imperative summary under 50 characters for the subject, explaining what and why in the body, specifying types like feat/fix/docs, and declaring Breaking Changes. By utilizing tools like Commitlint, Commitizen, and standard-version, rule compliance can be automated and linked to semantic version management and CHANGELOG generation. Consistent commit messages become the foundation of an automated release pipeline, going beyond simple documentation.
