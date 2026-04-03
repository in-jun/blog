---
title: "Understanding CI/CD: Continuous Integration and Delivery/Deployment"
date: 2024-06-10T17:14:26+09:00
tags: ["CI/CD", "DevOps", "Automation"]
description: "An overview of continuous integration and continuous delivery/deployment, including key concepts, tools, and implementation practices."
draft: false
---

CI/CD stands for Continuous Integration and Continuous Delivery or Continuous Deployment. It refers to a set of practices that automate how code changes are built, tested, and deployed during software development. In modern software teams, CI/CD is a core part of DevOps because it helps developers integrate and release code more frequently and with less risk. As a result, teams can shorten release cycles and catch bugs earlier.

## History and Origins of CI/CD

CI/CD emerged during the wave of software development methodology innovation in the 1990s. It began as one of the core practices of Extreme Programming (XP) and has continued to evolve ever since.

### The Birth of Continuous Integration

The term Continuous Integration was first used by Grady Booch, one of the creators of UML (Unified Modeling Language), in a 1994 publication. He described it as a way to integrate code frequently so conflicts could be minimized. The form of CI widely practiced today took shape in the mid-1990s, when Kent Beck defined it as one of the 12 core practices of Extreme Programming. Beck demonstrated its effectiveness on the Chrysler C3 (Chrysler Comprehensive Compensation) project in 1996, helping establish continuous integration as a practical and valuable development practice.

### The Popularization of CI/CD

CI began to gain wider adoption around 2000, when Martin Fowler, one of the founding members of the Agile Alliance, became a strong internal advocate for it at ThoughtWorks. In 2000, he published the well-known article "Continuous Integration," which organized the core principles and best practices of CI in a systematic way. He has continued to influence CI/CD and software development practices through his work as Chief Scientist at ThoughtWorks.

### The Development of Continuous Delivery

In 2010, Jez Humble and David Farley more formally established the concept of Continuous Delivery through their book "Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation." Building on Martin Fowler's earlier Continuous Integration ideas, the book introduced the concept of the Deployment Pipeline and presented a way to automate the full path from code commit to production deployment. Since then, CI/CD has continued to evolve alongside cloud computing, container technology, and the rise of Kubernetes. Large technology companies such as Netflix, Amazon, and Google helped popularize CI/CD practices, making hundreds or even thousands of deployments per day possible.

## What is CI (Continuous Integration)?

> **What is CI (Continuous Integration)?**
>
> A software development practice where code written by multiple developers is continuously integrated into the main branch, with automatic builds and tests performed on each integration to detect and resolve integration errors early.

The core idea of CI is simple: integrate small changes frequently. In traditional software development, developers often worked independently for long periods and then merged everything at the end in a "Big Bang Integration" approach. That process created many conflicts and bugs at integration time, often leading to what became known as "Integration Hell." CI addresses this by integrating small changes often and running automated verification each time, so problems can be found and fixed early.

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

Tools such as SonarQube, ESLint, and Checkstyle are used to analyze code quality. This includes checking coding convention compliance, code complexity, duplicate code, and potential bug patterns. Security vulnerability scanning may also be performed at this stage.

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

Various tools are available for implementing CI/CD, each with its own features, strengths, and trade-offs. It is important to choose a tool that fits the project's requirements and environment.

### Jenkins

Jenkins is a Java-based open-source CI/CD tool that emerged in 2011 after splitting from the Hudson project. It is one of the oldest and most widely used CI/CD tools, and it can integrate with almost any development tool through more than 1,800 plugins.

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

A CI/CD pipeline is not something you build once and forget. It requires ongoing management and improvement. The following best practices can help when building and evolving effective pipelines.

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

CI/CD grew out of software development practices introduced in the 1990s and was shaped by figures such as Kent Beck, Martin Fowler, and Jez Humble. At its core, it improves software delivery by automating build, test, and deployment workflows so teams can release changes more frequently and with greater confidence. Continuous Delivery keeps software ready for release with manual approval before production, while Continuous Deployment automates production releases as well.

The right approach depends on an organization's context, including its risk tolerance, regulatory environment, and release needs. The same is true for tooling: Jenkins, GitHub Actions, GitLab CI/CD, and CircleCI each offer different strengths depending on project scale, platform choices, and operational requirements. Successful adoption also depends on more than tools alone. Teams need to introduce CI/CD gradually, adapt their culture, and keep improving the pipeline over time.
