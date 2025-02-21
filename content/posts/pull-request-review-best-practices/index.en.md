---
title: "PR (Pull Request) Review Guide"
date: 2024-07-31T22:06:49+09:00
tags: ["git", "pull-request", "code-review", "best-practices"]
draft: false
---

## Introduction

PR reviews are an essential activity for collaboration. By reviewing PRs, we can improve the quality of code and facilitate smoother communication among team members. In this post, we'll explore the things to keep in mind and the best practices to follow when performing a PR review.

## Purpose of PR Reviews

The main purposes of performing a PR review are:

1. **Improve code quality:** By reviewing code from the perspective of another developer, we can write better code.
2. **Early detection of bugs and potential issues:** By having multiple eyes on the code, we can spot issues that the author may have missed.
3. **Share knowledge:** The code review process allows team members to share their knowledge and experiences with each other.
4. **Maintain consistency:** We can ensure that the team's coding style and conventions are being followed consistently.

## PR Review Checklist

To ensure an effective PR review, the following aspects should be checked:

1. Adherence to code style and conventions
2. Fulfillment of functional requirements
3. Consideration of performance and scalability
4. Review for security vulnerabilities
5. Presence of test code
6. Adequacy of documentation (comments, README, etc.)

## How to Perform an Effective PR Review

1. **Provide constructive and clear feedback**
    
    - Don't just point out problems; suggest ways to improve as well.
    - Explain the rationale behind your feedback clearly.

2. **Understand the context of the code**

    - Start the review with a good understanding of the purpose and background of the PR.
    - Refer to related issues or documents.

3. **Review in small PR units**

    - Breaking large changes into smaller PRs makes the review more efficient.

4. **Respect the author's intent**

    - Try to understand the author's approach.
    - Review based on objective criteria, not personal preferences.

5. **Provide positive feedback as well**
    
    - Don't hesitate to praise well-written code or creative solutions.

## Precautions When Reviewing PRs

1. **Timely review**

    - Review the PR as soon as possible after it's raised.
    - If the review is going to be delayed, inform the author and share an estimated time.

2. **Respectful and courteous communication**

    - Criticize the code, not the author.
    - Use objective and professional language.

3. **Discussion and consensus**

    - When there are differences in opinion, discuss openly.
    - If needed, seek input from the team lead or other team members.

4. **Scope the review**
    
    - Avoid requesting broad refactoring unrelated to the purpose of the PR.
    - Distinguish between important issues and minor suggestions when providing feedback.

## Conclusion

PR reviews are not just about finding bugs, but also about improving the team's capabilities and building better software. By following effective PR review practices, we can improve the quality of our code, foster knowledge sharing among team members, and enhance collaboration. Let's use this guide to improve our PR review culture and contribute to a better development process.
