---
title: "Git Branch Naming Conventions"
date: 2024-07-23T20:54:17+09:00
tags: ["Git", "Version Control"]
description: "Branch naming rules and prefix usage in Git workflows."
draft: false
---

## History and Importance of Branch Naming

Git branch naming conventions began to be systematized when Vincent Driessen introduced Git Flow in his 2010 blog post "A successful Git branching model." Since then, various branching strategies emerged including GitHub Flow (2011) and GitLab Flow (2014), establishing prefix-based naming conventions like feature/, bugfix/, hotfix/, and release/ as industry standards. Consistent branch naming improves project readability, facilitates CI/CD pipeline automation, and significantly enhances the efficiency of code reviews and task tracking.

## Basic Naming Rules

When creating branch names, use only lowercase letters and separate words with hyphens (-). Write in English to ensure compatibility in international collaboration environments. Keep names concise within 5-7 words while clearly conveying the branch's purpose. Avoid underscores (_), periods (.), and special characters (!, @, #) as they may have reserved meanings in Git or cause compatibility issues across operating systems.

```bash
# Good examples
feature/user-authentication
bugfix/login-error

# Bad examples
Feature_User_Authentication  # Uppercase, underscores
fix#123  # Special characters
johns-branch  # Unclear purpose
```

## Branch Prefixes

Use prefixes to immediately identify a branch's purpose. The most widely used prefixes include `feature/` for new feature development, `bugfix/` for general bug fixes, `hotfix/` for urgent production fixes, `release/` for new version release preparation, `refactor/` for code structure improvements, `docs/` for documentation updates, `test/` for test additions and modifications, `chore/` for build and configuration changes, `perf/` for performance improvements, and `style/` for code style changes.

| Prefix | Purpose | Example |
|--------|---------|---------|
| feature/ | New feature development | feature/oauth-login |
| bugfix/ | General bug fixes | bugfix/null-pointer-error |
| hotfix/ | Urgent production fixes | hotfix/security-patch |
| release/ | Release preparation | release/v2.1.0 |
| refactor/ | Code refactoring | refactor/extract-service |
| docs/ | Documentation updates | docs/api-reference |
| test/ | Test additions/modifications | test/unit-coverage |
| chore/ | Build/configuration changes | chore/update-deps |
| perf/ | Performance improvements | perf/query-optimization |
| style/ | Code style changes | style/lint-fixes |

## Issue Tracker Integration

When using issue trackers like JIRA, GitHub Issues, or Linear, including the issue ID in the branch name establishes traceability between issues and branches. This enables immediate reference to related issues during code review, and GitHub or GitLab automatically links issues and branches. The common format places the issue ID immediately after the prefix followed by a brief description.

```bash
feature/AUTH-123-oauth-login
bugfix/BUG-456-fix-null-check
hotfix/SEC-789-xss-patch
```

## Long-lived Branches

Continuously maintained long-lived branches in a project typically include `main` (or `master`) where production code is deployed, `develop` as the integration branch for the next release, and optionally `staging` for staging environments. Since GitHub changed the default branch name from master to main in 2020, most new projects use main.

## Temporary Work Branches

For personal experiments or incomplete work, use the `wip/` (Work In Progress) prefix to explicitly indicate that the branch is not yet ready for review or merge. These branches should be renamed with appropriate prefixes or deleted after work completion.

```bash
wip/experiment-new-algorithm
wip/spike-redis-caching
```

## Naming Strategies by Team Size

### Small Teams (2-5 people)

In small teams where direct communication is smooth, simple prefixes (`feat/`, `fix/`, `docs/`) suffice and issue numbers can be omitted. Short, concise formats like `feat/login` and `fix/typo` are efficient.

### Large Teams (10+ people)

In large teams, use additional namespaces to distinguish branches by module or team, and include issue numbers as mandatory. Formats like `frontend/feat/AUTH-123-oauth` and `backend/fix/API-456-timeout` clearly separate work areas.

### Open Source Projects

In open source projects with many external contributors, an option to include GitHub usernames for contributor identification may be provided. The format `feat/username/add-feature` enables tracking who is working on what.

## Integration with CI/CD Automation

Modern CI/CD pipelines can be configured to trigger different jobs based on branch name patterns. `feature/*` branches run only unit tests and lint checks, `release/*` branches auto-deploy to staging environments, and `hotfix/*` branches execute urgent production deployment pipelines. This automates deployment strategies based solely on branch names.

```yaml
# GitHub Actions example
on:
  push:
    branches:
      - 'feature/**'
      - 'release/**'
      - 'hotfix/**'
```

## Branch Naming Anti-Patterns

Branch name patterns to avoid include vague names like `fix`, `update`, `new-feature` where it's unclear what is being fixed; worker-centric names like `johns-branch`, `my-work` that focus on the worker rather than the purpose; date-based names like `2024-01-15`, `jan-update` that don't indicate content; names with special characters like `feature_login!`, `fix#123` that can cause Git issues; and excessively long names like `feature-add-new-user-authentication-system-with-oauth-jwt-mfa-support`.

## Conclusion

Git branch naming conventions have evolved steadily since Git Flow emerged in 2010, with prefix-based naming like feature/, bugfix/, hotfix/, and release/ now established as industry standards. The key practices are using lowercase letters and hyphens, including issue tracker IDs, and keeping names concise within 5-7 words. Adjusting rules to fit team size and project characteristics while maintaining consistency provides benefits in code review efficiency, task traceability, and CI/CD automation.
