---
title: "Git Branching Strategies, Git Flow, GitHub Flow, and GitLab Flow"
date: 2024-07-10T08:01:40+09:00
description: "Comparing Git Flow, GitHub Flow, and GitLab Flow branching models."
draft: false
tags: ["Git", "Version Control", "DevOps"]
---

## History and Background of Branching Strategies

The systematization of Git branching strategies began on January 5, 2010, when Dutch developer Vincent Driessen published his blog post "A successful Git branching model." The Git Flow introduced in this article resonated strongly in software development environments that required systematic release management at the time. In 2011, GitHub's Scott Chacon proposed a simpler model called GitHub Flow. Then in 2014, GitLab announced GitLab Flow, combining the advantages of both strategies. All three strategies continue to be widely used today depending on project characteristics.

Branching strategies became important as software development grew more complex. Teams needed a way to keep releases stable while multiple developers worked in parallel, handle urgent bug fixes without interrupting new feature development, and adapt to the spread of Continuous Integration/Continuous Deployment (CI/CD). Systematic branch management emerged as a practical response to those needs.

## Git Flow: Systematic Release Management

### Background and Design Philosophy

Git Flow was conceived by Vincent Driessen to solve the release management difficulties he experienced at the company where he worked. It was designed to systematize version management and enable simultaneous maintenance of multiple versions for software with clear release cycles such as desktop applications, mobile apps, and libraries.

### Roles of the 5 Branches

Git Flow uses five types of branches, each with a clear purpose and lifecycle.

| Branch | Lifespan | Purpose | Branch From | Merge To |
|--------|----------|---------|-------------|----------|
| main (master) | Permanent | Production releases | - | - |
| develop | Permanent | Development integration | main | - |
| feature/* | Temporary | Feature development | develop | develop |
| release/* | Temporary | Release preparation | develop | main, develop |
| hotfix/* | Temporary | Emergency fixes | main | main, develop |

The **main branch** contains only production-deployed code with version tags (v1.0.0, v1.1.0) on each commit. The **develop branch** is the integration branch for all features for the next release and serves as the merge target for feature branches.

**Feature branches** are created from develop for new feature development and merged back into develop after completion. The naming convention follows the `feature/feature-name` format.

**Release branches** are created from develop when release preparation is complete. They handle only release-necessary work such as bug fixes, documentation, and version number updates, then merge into both main and develop after completion.

**Hotfix branches** branch directly from main to fix urgent bugs discovered in production. After the fix is complete, they merge into both main and develop so the fix is reflected in the next release as well.

### Workflow

<img src="image-1.svg" alt="git-flow" style="width: 100%; max-width: 500px; filter: grayscale(1) saturate(0.15) contrast(0.95);" />

A typical Git Flow workflow proceeds as follows.

```bash
# 1. Create feature branch and develop
git checkout develop
git checkout -b feature/user-authentication

# Commit after development work
git commit -m "feat: implement user login"

# 2. Merge feature into develop
git checkout develop
git merge --no-ff feature/user-authentication
git branch -d feature/user-authentication

# 3. Prepare release
git checkout -b release/v1.2.0

# After bug fixes and version number update
git commit -m "chore: bump version to 1.2.0"

# 4. Complete release
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"

git checkout develop
git merge --no-ff release/v1.2.0
git branch -d release/v1.2.0

# 5. Emergency fix (if needed)
git checkout main
git checkout -b hotfix/v1.2.1

# After bug fix
git checkout main
git merge --no-ff hotfix/v1.2.1
git tag -a v1.2.1

git checkout develop
git merge --no-ff hotfix/v1.2.1
git branch -d hotfix/v1.2.1
```

### Advantages and Disadvantages

Git Flow offers clear release management. Version history stays on the main branch with tags for easy tracking, multiple versions can be maintained at the same time, develop helps protect main so production stays stable, and branch roles remain clear in larger teams.

Its drawbacks are equally clear: many branches increase complexity and raise the learning curve, frequent merges create extra conflict-resolution work, and the model is not well suited to Continuous Deployment (CD) environments. Vincent Driessen himself noted in 2020 that "GitHub Flow may be more suitable for web apps."

## GitHub Flow: Simplicity and Continuous Deployment

### Background

GitHub Flow was proposed in 2011 by GitHub's Scott Chacon as a simple model optimized for continuous deployment environments while reducing Git Flow's complexity. It organizes the workflow that was being used for GitHub's own development and is suitable for projects that need to maintain a constantly deployable state like web applications.

### Core Principles

GitHub Flow centers on three core principles.

1. **The main branch is always deployable**: Code merged to main should be immediately deployable to production.
2. **All work happens in feature branches**: Whether bug fixes or new features, work is done in branches created from main.
3. **Code review through Pull Requests**: PRs must be created and reviewed by team members before merging.

### Workflow

<img src="image-2.svg" alt="github-flow" style="width: 100%; max-width: 460px; filter: grayscale(1) saturate(0.15) contrast(0.95);" />

```bash
# 1. Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/add-search

# 2. Develop and commit
git commit -m "feat: add search functionality"
git push origin feature/add-search

# 3. Create Pull Request (on GitHub web)
# Team review, discussion, modifications

# 4. Merge to main after review passes
# Click "Merge pull request" on GitHub

# 5. Automatic or manual deployment after merge
```

### Advantages and Disadvantages

Advantages include that there are only two types of branches (main and feature) making it easy to understand, Pull Request-based code review happens naturally, integration with CI/CD pipelines is simple, and fast feedback and deployment are possible.

Disadvantages include difficulty maintaining multiple versions simultaneously, insufficiency for projects requiring release management, and the necessity of strong automated testing for main to always remain in a deployable state.

## GitLab Flow: An Environment-Based Branching Strategy

### Background

GitLab Flow was proposed in 2014 by GitLab as a balance point between Git Flow's structure and GitHub Flow's simplicity. It supports both continuous deployment and release management by introducing environment branches (production, staging).

### Branch Structure

GitLab Flow is better understood as a main-centered family of workflows rather than one fixed structure, and two variants are commonly described.

The **environment branch approach** has code flowing in the order main (development) to staging (testing) to production (deployment), with automatic deployment to each environment when merged to its branch.

The **release branch approach** maintains version-specific release branches (release/1.0, release/2.0), suitable for libraries or packages that need to support multiple versions simultaneously.

<img src="image-3.svg" alt="gitlab-flow" style="width: 100%; max-width: 500px; filter: grayscale(1) saturate(0.15) contrast(0.95);" />

The diagram above is closest to the environment-branch variant described in GitLab's own docs. It shows how feature work continues through main-branch integration while changes move downstream through environment branches such as test and production.

```bash
# Environment branch approach example
git checkout main
git checkout -b feature/new-feature

# Merge to main after development complete (development environment deployment)
git checkout main
git merge feature/new-feature

# Merge to staging when test-ready
git checkout staging
git merge main

# When production deployment ready
git checkout production
git merge staging
```

## Strategy Selection Guide

The table below shows how each branching strategy fits different project characteristics.

| Criteria | Git Flow | GitHub Flow | GitLab Flow |
|----------|----------|-------------|-------------|
| Release Cycle | Regular (monthly/quarterly) | Continuous (daily/weekly) | Middle |
| Project Scale | Large | Small to Medium | Medium to Large |
| Version Maintenance | Multiple simultaneous | Single version | Selective |
| Team Size | 10+ | 5 or fewer | 5-15 |
| Deployment Environment | Single | Single | Multiple (staging/prod) |
| Suitable Projects | Mobile apps, libraries | SaaS, internal tools | Web services |

**Cases to choose Git Flow** include software requiring clear version numbers (v1.0, v2.0), libraries needing to support multiple versions simultaneously, mobile apps requiring app store review, and organizations with strict QA processes.

**Cases to choose GitHub Flow** include web applications requiring continuous deployment, startups where fast feedback and iteration are important, organizations with established DevOps culture, and teams with automated testing and deployment pipelines.

**Cases to choose GitLab Flow** include projects where staging environment validation is mandatory, cases where environment-specific deployment management is needed but Git Flow is excessive, and organizations needing both fast deployment and release management.

## Conclusion

Git Flow, GitHub Flow, and GitLab Flow emerged in response to different development needs. The right choice depends on factors such as release cadence, project size, and deployment environment. Git Flow works well for structured release management, GitHub Flow fits continuous deployment, and GitLab Flow sits between them with stronger support for environment-based promotion. Whatever model you choose, the key is to use it consistently across the team and adapt it when the project changes.
