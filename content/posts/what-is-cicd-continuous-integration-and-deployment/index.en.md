---
title: "What is CI/CD?"
date: 2024-06-10T17:14:26+09:00
tags: ["CI", "CD", "Continuous Integration", "Continuous Delivery"]
description: "A comprehensive guide covering CI/CD's origins from Extreme Programming, build and test automation, differences between Continuous Delivery and Deployment, tool comparisons including Jenkins and GitHub Actions, and pipeline best practices"
draft: false
---

## History and Origins of CI/CD

CI/CD originated from the Extreme Programming (XP) methodology.

### Birth of Continuous Integration

The term Continuous Integration was first coined by Grady Booch, who developed UML, in 1994. However, CI as we know it today was created by Kent Beck in the mid-1990s as one of the practices of Extreme Programming.

In 1996, all developers on the famous Chrysler C3 project experienced and enjoyed continuous integration.

### Popularization of CI/CD

In 2000, Martin Fowler, one of the founding members of the Agile Alliance, became an internal advocate for CI at ThoughtWorks. He is now famous as the Chief Scientist at ThoughtWorks and greatly contributed to popularizing CI/CD.

### Evolution of Continuous Delivery

Later in the 2000s, J.Humble and D.Farley expanded the Continuous Integration ideas presented by Martin Fowler to develop the concept of Continuous Delivery as a deployment pipeline.

## What is CI

CI (Continuous Integration) means continuous integration. It is the process of automatically integrating, building, and testing code written by multiple developers.

### Purpose of CI

It automatically performs builds and tests whenever code changes occur. It helps discover build failures and bugs early.

### CI Operation Process

#### 1. Code Commit

Developers modify code and commit it to a repository like GitHub.

#### 2. Automatic Build

CI tools automatically fetch the code and perform a build.

Problems that can occur during the build process include:

- Syntax errors
- Missing required files
- Library version conflicts

If the build fails, the development team immediately receives notifications via email or messenger.

#### 3. Automatic Testing

If the build succeeds, various tests are executed sequentially:

- Unit tests
- Integration tests
- Functional tests

Code quality and stability are verified.

#### 4. Code Quality Inspection

Code quality inspection tools check the following:

- Compliance with coding rules
- Potential bugs

## Two Meanings of CD

CD has two meanings: Continuous Delivery and Continuous Deployment. While the two concepts seem similar, there are important differences.

### Continuous Delivery

All code changes go through automated builds and tests and are always ready for production deployment.

#### Characteristics

- Actual releases occur only after manual approval
- Have an automated release process that can deploy your application anytime by clicking a button

#### Suitable Environments

- Environments where stability and coordination with business processes are crucial
- Financial institutions
- Healthcare providers

### Continuous Deployment

A concept that goes one step further than Continuous Delivery.

#### Characteristics

- Every change that passes all stages of the production pipeline is automatically released to users without manual approval
- Every code change that passes automated tests is immediately delivered to users

#### Suitable Environments

- Organizations that want fast innovation and minimal release friction
- Startups
- SaaS providers
- Web-based platforms
- Environments that benefit from rapid iteration on feedback

## Comparison of Major CI/CD Tools

### Jenkins

A Java-based open-source tool called the father of CI.

#### Advantages

- Being the oldest, it has a wide variety of plugins and abundant documentation
- Supports all SCMs including GitHub, GitLab, and Bitbucket
- Optimal when deep customization and control are needed in large enterprise environments

#### Disadvantages

- You must purchase and operate the build server yourself
- Server management, updates, and security monitoring are required
- Older interface compared to modern tools

### GitHub Actions

Integrates natively and seamlessly with GitHub repositories.

#### Advantages

- Provides access to pre-built actions and workflows from the GitHub Marketplace
- Ideal for small teams focusing on GitHub native projects and agility

#### Disadvantages

- Primarily designed for GitHub and is less intuitive for other platforms
- Has usage limits in the free tier
- Self-hosted runner setup is less flexible than Jenkins

### GitLab CI

Integrates tightly with GitLab to provide a comprehensive DevOps experience.

#### Advantages

- Supports version control, issue tracking, and DevSecOps
- Includes vulnerability scanning and compliance tools
- Supports both cloud-hosted and self-hosted options
- Security leader with built-in security scanning in all tiers
- Provides the most comprehensive integrated DevOps experience

#### Disadvantages

- For non-standard workflows, flexibility is limited compared to Jenkins

### CircleCI

Rated as a performance leader.

#### Advantages

- Trusted by companies like Meta, Adobe, and Nextdoor
- Used by over 2 million developers
- Known for fast builds, excellent Docker support, and comprehensive caching
- Provides efficient containerized build and test workflows with native Docker support

#### Disadvantages

- Can experience occasional outages

## CI/CD Pipeline Best Practices

### Continuous Management and Improvement

CI/CD pipelines are not built once and finished but require continuous management and improvement. There is no single correct answer for pipeline configuration, so you must apply models suitable for project situations and continuously evolve them.

### Gradual Approach

A gradual approach is important for successful adoption:

- Start with the most important projects or teams
- Create success stories and spread them to other teams

### Cultural Change

CI/CD is not just a tool but a new way of working:

- Cultural change across the entire team is necessary
- Form consensus on the value and necessity of automation
- Create a culture that encourages continuous learning and improvement

### Performance Optimization

#### Parallelization

- Execute independent tests simultaneously
- Build a structure that can process multiple builds concurrently
- Optimize execution time by appropriately dividing test suites

#### Caching Strategy

- Save download time by caching frequently used dependency libraries
- Shorten build time by reusing previous build results

### Monitoring and Improvement

You should continuously monitor pipeline performance and stability metrics:

- Identify and improve bottlenecks
- Track failure rates and build times

### Tool Selection Guide

- For small teams, GitHub Actions is often the most affordable
- If you have a small-scale project or use external cloud services, it's worth considering other services besides Jenkins

## Conclusion

CI/CD is a development methodology that originated from Extreme Programming in the 1990s and was developed by Kent Beck and Martin Fowler. It maintains code quality through build automation and test automation and automates the deployment process.

Continuous Delivery ensures stability through manual approval. Continuous Deployment realizes fast releases through complete automation.

Various tools exist including Jenkins, GitHub Actions, GitLab CI, and CircleCI, each with pros and cons. You should choose based on project scale and requirements.

For successful CI/CD construction, the following are essential:

- Gradual approach
- Cultural change
- Continuous improvement
