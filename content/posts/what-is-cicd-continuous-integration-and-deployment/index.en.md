---
title: "What is CI/CD?"
date: 2024-06-10T17:14:26+09:00
tags: ["CI", "CD", "continuous integration", "continuous deployment", "DevOps", "automation"]
description: "A comprehensive guide covering CI/CD history from Extreme Programming origins, build automation, test automation, the difference between Continuous Delivery and Deployment, tool comparisons including Jenkins and GitHub Actions, and pipeline best practices."
draft: false
---

CI/CD stands for Continuous Integration and Continuous Delivery/Deployment, referring to a set of automated processes that automatically build, test, and deploy code changes during software development. It has become a core element of DevOps culture in modern software development. CI/CD enables developers to integrate and deploy code more frequently and safely, thereby shortening software release cycles and improving product quality by detecting bugs early.

## History and Origins of CI/CD

CI/CD was born amid the innovation in software development methodologies during the 1990s, starting as one of the core practices of Extreme Programming (XP) and has continued to evolve to the present day.

### The Birth of Continuous Integration

The term Continuous Integration was first used by Grady Booch, one of the developers of UML (Unified Modeling Language), in his 1994 publication, where it was presented as a concept of frequently integrating code to minimize conflicts. However, the concrete form of CI that we practice today began to develop in earnest when Kent Beck established it as one of the 12 core practices of Extreme Programming in the mid-1990s. Kent Beck empirically demonstrated the effectiveness of CI by applying XP methodology to the Chrysler C3 (Chrysler Comprehensive Compensation) project in 1996, and this project became an opportunity for all developers to experience and embrace the value of continuous integration.

### The Popularization of CI/CD

CI/CD began to gain widespread adoption in 2000 when Martin Fowler, one of the founding members of the Agile Alliance, became an internal advocate for CI at ThoughtWorks. He published the famous article "Continuous Integration" in 2000, systematically organizing the core principles and best practices of CI, and continues to contribute to the development of CI/CD and software development methodologies as Chief Scientist at ThoughtWorks to this day.

### The Development of Continuous Delivery

In 2010, Jez Humble and David Farley systematically established the concept of Continuous Delivery with their book "Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation." This book expanded on the Continuous Integration ideas presented by Martin Fowler, introduced the concept of the Deployment Pipeline, and presented a methodology for automating the entire process from code commit to production deployment. Subsequently, CI/CD has further evolved alongside the advancement of cloud computing, the emergence of container technology, and the popularization of Kubernetes. Large technology companies such as Netflix, Amazon, and Google actively adopted CI/CD, ushering in an era where hundreds or thousands of deployments per day became possible.

## What is CI (Continuous Integration)?

> **What is CI (Continuous Integration)?**
>
> A software development practice where code written by multiple developers is continuously integrated into the main branch, with automatic builds and tests performed on each integration to detect and resolve integration errors early.

The core idea of CI is "integrate small changes frequently." In traditional software development, developers would work independently for long periods and then integrate their code at the end using a "Big Bang Integration" approach. This approach caused numerous conflicts and bugs at the point of integration, leading to a situation known as "Integration Hell." CI solves this problem by integrating code in small units frequently and running automated verification processes each time, enabling early detection and resolution of problems.

### Core Principles of CI

**Maintain a Single Source Repository**: All source code, test code, build scripts, configuration files, and other assets should be managed in a single version control system (Git, SVN, etc.), and all team members should work from the same repository.

**Commit Frequently**: Developers should integrate code into the main branch at least once a day, and ideally commit small changes every few hours. This minimizes conflicts and enables quick identification of causes when problems occur.

**Automate the Build**: The build should run automatically every time code is committed. The build process includes compilation, dependency resolution, static analysis, and more, and should be executable with a single command.

**Automate Testing**: Automated tests should run after the build to verify the functional correctness of the code. This can include various levels of testing such as unit tests, integration tests, and functional tests.

**Keep the Build Fast**: Builds and tests should complete as quickly as possible, ideally within 10 minutes. If the build takes too long, developers will start other work without waiting for build results, reducing the effectiveness of CI.

**Provide Immediate Feedback**: When a build or test fails, the development team should be notified immediately, and fixing the failed build should take priority over developing new features.

### How the CI Pipeline Works

**Stage 1: Code Commit**

When a developer completes work locally and pushes changes to the version control system (Git, etc.), the CI pipeline is triggered. This typically starts automatically when a Pull Request is created or when code is pushed to a specific branch.

**Stage 2: Source Code Checkout**

The CI server retrieves the latest code from the repository. Depending on the branching strategy, this may involve checking out code from a specific branch or checking out the Pull Request changes merged with the main branch.

**Stage 3: Install Dependencies**

The libraries and dependencies required for the project are installed. Dependencies are resolved through package managers such as npm, pip, Maven, or Gradle, and caching can be utilized to shorten this stage.

**Stage 4: Build**

The source code is compiled and built into an executable form. Problems such as syntax errors, type errors, and dependency conflicts may be discovered during this process. If the build fails, the pipeline stops and a notification is sent to the developer.

**Stage 5: Run Tests**

If the build succeeds, various levels of automated tests are executed. Unit tests verify the behavior of individual functions or classes, integration tests verify interactions between multiple components, and E2E (End-to-End) tests verify the behavior of the entire system from a user perspective.

**Stage 6: Code Quality Inspection**

Tools such as SonarQube, ESLint, and Checkstyle are used to analyze code quality. This includes checking coding convention compliance, code complexity, duplicate code, potential bug patterns, and security vulnerability scanning may also be performed at this stage.

**Stage 7: Artifact Creation**

If all verifications pass, deployable artifacts (JAR, WAR, Docker images, etc.) are created. These artifacts are tagged with versions and stored in artifact repositories (Nexus, Artifactory, Docker Registry, etc.).

## The Two Meanings of CD

CD is used to mean both Continuous Delivery and Continuous Deployment. The two concepts are closely related but have an important difference in their approach to production deployment.

### Continuous Delivery

> **What is Continuous Delivery?**
>
> A software development approach where all code changes go through automated build, test, and verification processes and are maintained in a state ready to be deployed to production at any time, with actual production deployment performed manually after approval based on business decisions.

The core of Continuous Delivery is "always maintain a releasable state." When code is merged into the main branch, it is deployed to the staging environment through an automated pipeline, and once all tests and verifications are complete, it becomes ready to be deployed to production with the push of a button. However, the actual production deployment is triggered manually after approval from product managers, business stakeholders, and others.

**Environments Where Continuous Delivery is Suitable**:
- Heavily regulated industries (finance, healthcare, government, etc.) where approval processes are required before deployment
- When release timing needs to be coordinated with marketing campaigns, business events, etc.
- When the impact on users is significant and careful release decisions are needed
- Systems where rollback is complex or costly

### Continuous Deployment

> **What is Continuous Deployment?**
>
> A software development approach that goes one step further than Continuous Delivery, where all code changes that pass automated tests and verifications are automatically deployed to the production environment without human intervention.

Continuous Deployment pursues complete automation. When a developer commits code, it automatically goes through all stages of the CI pipeline (build, test, quality inspection, staging deployment, staging tests, etc.), and if there are no problems, it is also automatically deployed to production. This requires high test coverage, robust monitoring systems, and fast rollback mechanisms to be in place.

**Environments Where Continuous Deployment is Suitable**:
- Startups or web services where rapid user feedback and iteration are important
- SaaS (Software as a Service) platforms
- Environments that frequently perform A/B testing, experimental feature releases, etc.
- Environments that have adopted microservices architecture enabling independent deployments
- Large technology companies like Netflix, Amazon, and Etsy that deploy multiple times a day

### Continuous Delivery vs Continuous Deployment Comparison

| Category | Continuous Delivery | Continuous Deployment |
|----------|---------------------|----------------------|
| Production Deployment | Deploy after manual approval | Automatic deployment |
| Deployment Frequency | Based on business decisions | Immediately upon code change |
| Requirements | Automated testing, staging environment | High test coverage, monitoring, rollback mechanism |
| Suitable Environment | Regulated industries, careful releases needed | Fast iteration, web services, SaaS |
| Risk Management | Human makes final judgment | Relies on automated verification |

## Comparison of Major CI/CD Tools

Various tools are available for implementing CI/CD, each with unique features and advantages and disadvantages. It is important to select a tool that fits the project requirements and environment.

### Jenkins

Jenkins is a Java-based open-source CI/CD tool that was born in 2011 when it split from the Hudson project. It is called the "father of CI" because it is the oldest and most widely used tool, and it can integrate with almost any development tool through more than 1,800 plugins.

**Advantages**:
- Vast plugin ecosystem supporting all SCMs including GitHub, GitLab, and Bitbucket, as well as most technology stacks including Docker, Kubernetes, AWS, and Azure
- Pipeline as Code through Jenkinsfile allows managing pipelines as code
- Complete customization enables implementation of complex workflows
- Proven stability in large enterprise environments
- Active community and abundant documentation

**Disadvantages**:
- Requires building and operating your own server, creating infrastructure management overhead
- Initial setup and maintenance require significant effort
- Compatibility issues between plugins may occur
- UI/UX feels dated compared to modern tools

### GitHub Actions

GitHub Actions is a CI/CD platform released by GitHub in 2019 that natively integrates with GitHub repositories for immediate use without separate configuration. Workflows are defined in YAML files, and community-created actions can be reused from the GitHub Marketplace.

**Advantages**:
- Perfect integration with GitHub repositories, with natural linkage to Pull Requests, Issues, etc.
- Over 15,000 pre-built actions available in the GitHub Marketplace
- Matrix builds make it easy to test multiple OS and language version combinations
- Unlimited free use for public repositories
- Intuitive workflow definition using YAML

**Disadvantages**:
- Usage-based costs for private repositories
- Locked into the GitHub platform, making integration with other Git hosting services difficult
- Self-hosted runner setup is not as flexible as Jenkins
- YAML files can become verbose for complex workflows

### GitLab CI/CD

GitLab CI/CD is a CI/CD solution built into GitLab, part of an integrated DevOps platform that provides source code management, issue tracking, CI/CD, security scanning, and package registry all in one platform.

**Advantages**:
- Manage the entire DevOps lifecycle from version control to deployment on a single platform
- Security features including SAST, DAST, and container scanning are built-in by default
- Auto DevOps feature enables automatic pipeline configuration with minimal setup
- Close integration with Kubernetes
- Supports both cloud hosting and self-hosting

**Disadvantages**:
- Paid plan required to use full features
- Locked into the GitLab platform
- Less flexible than Jenkins for non-standard workflows

### CircleCI

CircleCI is a cloud-based CI/CD service known for fast build speeds and excellent Docker support. It is used by large technology companies including Meta, Adobe, and Spotify.

**Advantages**:
- Industry-leading build speed and performance
- Native Docker support optimized for container-based workflows
- Powerful caching mechanisms to reduce build time
- Simplified configuration through Orbs (reusable configuration packages)
- SSH debugging makes troubleshooting build failures easy

**Disadvantages**:
- Free tier has limitations
- Learning curve for complex workflow configuration
- Occasional service outages

### Tool Selection Guide

| Situation | Recommended Tool |
|-----------|-----------------|
| Using GitHub, small team | GitHub Actions |
| Need full DevOps platform integration | GitLab CI/CD |
| Large enterprise, complex requirements | Jenkins |
| Fast build speed, Docker-centric | CircleCI |
| Self-hosting required | Jenkins or GitLab (Self-Managed) |
| Minimize costs (open source projects) | GitHub Actions |

## CI/CD Pipeline Best Practices

A CI/CD pipeline is not something you build once and forget. It requires continuous management and improvement. The following best practices should be referenced to build and evolve effective pipelines.

### Gradual Approach

Rather than trying to build a perfect pipeline all at once, a gradual approach is more effective when adopting CI/CD. A strategy of starting with the most important projects or teams, creating success stories, and then spreading them across the organization is recommended.

1. **Stage 1**: Start with basic build automation
2. **Stage 2**: Add unit test automation
3. **Stage 3**: Add integration tests and code quality checks
4. **Stage 4**: Automatic deployment to staging environment
5. **Stage 5**: Production deployment automation (Continuous Delivery/Deployment)

### Cultural Change

CI/CD is not simply about adopting tools but about changing the work methods and culture of the entire team. Successful CI/CD adoption requires the following cultural changes.

- **Shared Responsibility**: Build and test success is the responsibility of the entire team, not individuals
- **Embrace Quick Feedback**: View build failures as opportunities for improvement, not blame
- **Automation-First Thinking**: Minimize manual work and automate everything possible
- **Continuous Learning**: Learn from pipeline failures and continuously improve processes
- **Transparency**: Share build status, deployment status, etc. with the entire team

### Performance Optimization

If CI/CD pipeline execution time becomes too long, developer productivity decreases and the benefits of CI/CD diminish. Pipeline performance should be continuously optimized.

**Parallelization**: Run independent tests and tasks simultaneously to reduce overall pipeline time. Test suites can be appropriately divided and run in parallel across multiple nodes.

**Caching Strategy**: Cache dependency libraries, build results, Docker layers, etc. to save time on repetitive downloads and builds. Most CI/CD tools provide caching functionality.

**Selective Execution**: Apply strategies to run only tests related to changed code, or run only part of the pipeline depending on the scope of changes to reduce unnecessary work.

**Resource Optimization**: Allocate appropriate resources (CPU, memory) for builds, and consider separating heavy tests into separate pipelines that run less frequently.

### Monitoring and Continuous Improvement

Pipeline performance and stability should be continuously monitored and improved. Tracking the following metrics is recommended.

- **Build Time**: Monitor average build time and trends to detect performance degradation early
- **Build Success Rate**: If failure rates are high, examine test stability or code quality issues
- **Deployment Frequency**: Track how often deployments are made to production
- **Change Lead Time**: Time from code commit to production deployment
- **Mean Time to Recovery (MTTR)**: Time to recover from failures

### Security Considerations

CI/CD pipelines access sensitive information such as source code, credentials, and deployment permissions, so special attention to security is required.

- **Secret Management**: Do not hardcode API keys, passwords, etc. in code. Use the CI/CD tool's secret management features or dedicated tools like HashiCorp Vault
- **Principle of Least Privilege**: Grant only the minimum permissions necessary for the pipeline
- **Security Scanning**: Integrate SAST, DAST, and dependency vulnerability scanning into the pipeline
- **Audit Logs**: Record and retain pipeline execution and deployment history

## Conclusion

CI/CD is a software development methodology that started in the 1990s with Extreme Programming and was developed by Kent Beck, Martin Fowler, Jez Humble, and others. It maintains code quality through build and test automation and shortens software release cycles by automating the deployment process. Continuous Delivery ensures stable releases through manual approval, while Continuous Deployment enables fast feedback loops through complete automation. Organizations should choose the approach that fits their situation and requirements. Various tools including Jenkins, GitHub Actions, GitLab CI/CD, and CircleCI are available, each with its own advantages and disadvantages, so selection should consider project scale, platforms in use, and requirements. Successful CI/CD implementation requires a gradual approach, cultural change, and continuous improvement. Beyond simply adopting tools, the entire team must create a culture that shares the values of automation and continuous improvement.
