---
title: "Pull Request Review Best Practices"
date: 2024-07-31T22:06:49+09:00
tags: ["Git", "Code Review", "Collaboration"]
description: "Writing effective pull requests and conducting code reviews."
draft: false
---

PR (Pull Request) review is a core collaborative activity that improves team code quality, shares knowledge among developers, and catches potential bugs early. Since GitHub introduced the Pull Request feature in 2008, it has become the standard way to integrate code in both open source projects and enterprise development environments. PR reviews go beyond simply finding errors in code. They are an essential quality management practice in software development that helps team members understand each other's code, maintain a consistent codebase, and make better design decisions through collective intelligence.

## History of Code Review and Evolution of PR Reviews

> **What is Code Review?**
>
> A software quality assurance activity where other developers review written code to discover bugs, design issues, coding standard violations, and improve code quality.

The history of code review dates back to the 1970s, when IBM's Michael Fagan published a systematic methodology called "Fagan Inspection" in 1976, formally introducing the practice to the software industry. Code reviews at that time followed a Formal Inspection approach in which multiple developers gathered in a meeting room and reviewed printed code line by line. This method was effective, but it required significant time and manpower.

In the 2000s, code review methods evolved along with the development of Distributed Version Control Systems (DVCS). The emergence of Git in 2005 and GitHub's introduction of the Pull Request feature in 2008 were revolutionary changes that enabled effective code reviews even in asynchronous and distributed environments. Since then, similar features like GitLab's Merge Request and Bitbucket's Pull Request have been introduced on other platforms, and PR-based code review has become established as the standard workflow in modern software development.

## Purpose and Value of PR Reviews

PR reviews serve several purposes and deliver value in multiple ways. They go beyond simple error detection and help improve the capabilities of the entire team.

### Improving Code Quality

By reviewing code written by one developer from a different perspective, bugs, edge cases, and performance issues that were not discovered can be identified in advance. According to research, 60-70% of defects can be found before release through code review.

### Knowledge Sharing and Learning

Reviewers can learn new technologies or patterns by reading other developers' code, and authors can learn better coding methods through feedback. In this process, the entire team's understanding of the codebase increases and the Bus Factor (the risk that the project stops if certain people are absent) decreases.

### Maintaining Code Consistency

Team coding conventions, architecture patterns, and naming rules can be consistently maintained. Design-level consistency that automated linters or formatters cannot catch can also be managed through reviews.

### Leveraging Collective Intelligence

For complex problems, better solutions can be found by drawing on the diverse perspectives and experiences of multiple developers. One team member may spot an issue another missed or suggest a more efficient approach.

### Sharing Code Ownership

Through PR reviews, knowledge about specific code is distributed across the entire team rather than concentrated with just the author. This enables code maintenance even during team member transitions or vacations, improving overall team resilience.

## PR Review Checklist

Effective PR reviews require systematic review criteria. Checking the following items enables consistent and comprehensive reviews.

### Functional Correctness

- Does it fulfill the PR's purpose (issue, requirements)?
- Are all edge cases properly handled?
- Is error handling appropriate?
- Does it not affect existing functionality (side effects)?

### Code Quality

- Does it comply with coding conventions and style guides?
- Do functions and classes follow the single responsibility principle?
- Is there no unnecessary code duplication?
- Is naming clear and meaningful?
- Is the code easy to read and understand?

### Performance and Scalability

- Are there no obvious performance issues like N+1 queries or unnecessary loops?
- Is memory usage appropriate?
- Is scalability considered when processing large volumes of data?
- Is caching appropriately applied where needed?

### Security

- Is user input properly validated and escaped?
- Are authentication and authorization checks correctly implemented?
- Is sensitive information (passwords, API keys, etc.) not exposed?
- Are there no common security vulnerabilities like SQL injection or XSS?

### Testing

- Are tests written for new functionality?
- Do tests cover meaningful cases?
- Do all existing tests pass?
- Is test code also readable and maintainable?

### Documentation

- Are there appropriate comments for complex logic?
- Is documentation updated for API changes?
- Is README or CHANGELOG update needed?

## Review Comment Levels

Using prefixes is recommended to clearly convey the importance and intent of feedback in PR reviews. This allows authors to quickly understand which feedback must be addressed and which is optional.

### Blocking

> `[blocking]` or `[required]`

Indicates critical issues that must be fixed and the PR cannot be approved without fixing them. Security vulnerabilities, serious bugs, potential data loss, and architecture principle violations fall into this category.

```
[blocking] This API endpoint is missing authentication middleware, allowing unauthenticated users to access it.
Please add the `requireAuth()` middleware to the router.

[blocking] This code has a SQL injection vulnerability.
Please use parameterized queries instead of string concatenation:
```python
# Current (vulnerable)
query = f"SELECT * FROM users WHERE id = {user_id}"

# Fixed (safe)
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```
```

### Suggestion

> `[suggestion]` or `[recommended]`

Improvements that are recommended but not mandatory, including performance optimization, readability improvements, and better design pattern application. Authors can decide whether to accept based on their judgment.

```
[suggestion] This function has three responsibilities (validation, transformation, storage).
Consider separating into the following for single responsibility principle:
- `validateUserInput()`: Input validation
- `transformUserData()`: Data transformation
- `saveUser()`: Data storage

[suggestion] The array length is being calculated on every iteration in this loop.
Caching the length in a variable may provide slight performance improvement:
```javascript
// Current
for (let i = 0; i < items.length; i++) { ... }

// Suggested
const len = items.length;
for (let i = 0; i < len; i++) { ... }
```
```

### Nit

> `[nit]` or `[minor]`

Very minor points such as variable names, spacing, and comment typos that do not affect code behavior but are mentioned for consistency or readability. They are worth fixing, but leaving them as-is does not affect PR approval.

```
[nit] The variable name `cachedUserProfile` would convey intent more clearly than `temp`.

[nit] There's a typo in this comment: "recieve" → "receive"

[nit] Changing the parameter order of this function from `(userId, options)` → `(options, userId)`
would maintain consistency with other functions in the project.
```

### Question

> `[question]`

Questions used to better understand the code, the reasoning behind specific design decisions, unexpected approaches, or missing context. They help the reviewer understand the change and can also give the author a chance to reconsider their decisions.

```
[question] Is there a reason for using memory cache instead of Redis in this logic?
I'm asking because cache consistency issues might occur across multiple instances.

[question] This exception is being swallowed (caught and ignored) here - is this intended behavior?
Adding logging at least would make debugging easier.
```

### Praise

> `[praise]`

Positive feedback for well-written code, creative solutions, or meaningful improvements. It shows that review is not just about pointing out problems, but also about acknowledging and encouraging good code.

```
[praise] This error handling logic is really clean!
All edge cases are well considered.

[praise] It's impressive how you organized this complex business logic with such good readability.
The Strategy pattern application is also appropriate.
```

## Effective PR Review Methods

### Understand Context First

Before starting a review, check the PR's purpose, related issues, ticket numbers, and design documents first. Reviewing code without context can lead to unnecessary feedback or misunderstanding the author's intent.

### Review Details After Understanding Overall Structure

First, scan through the list of changed files to understand the overall scope and structure of changes, then review the core logic first and check detailed style issues later for efficiency.

### Specific and Actionable Feedback

When pointing out problems, specifically state what the problem is, why it's a problem, and how it can be improved. Vague feedback confuses the author and creates unnecessary communication costs.

**Bad Examples**:
```
"This code needs improvement."
"Performance seems bad."
"This is a bit strange."
```

**Good Examples**:
```
"[suggestion] This function makes three database calls.
Using JOIN to consolidate into a single query would reduce network round trips.
Example: SELECT u.*, p.* FROM users u JOIN profiles p ON u.id = p.user_id WHERE u.id = ?"
```

### Respect the Code Author

Feedback is about the code, not the author personally. Using phrases like "this code" and avoiding "you" is recommended.

**Bad Examples**:
```
"Why did you do this?"
"This is wrong."
"You always make these mistakes."
```

**Good Examples**:
```
"I'm curious about why this approach was chosen. Were other methods considered?"
"Unexpected behavior might occur in this part. Please consider this case."
"This pattern might have these issues. How about this approach as an alternative?"
```

### Recommend Appropriate PR Size

Research shows that review effectiveness decreases sharply for PRs with more than 400 lines of changes. It is helpful to recommend submitting large PRs in smaller units. However, when reviewing a large PR that has already been submitted, it is better to work within that constraint while suggesting smaller PRs for the future.

### Timely Reviews

When PRs sit too long, context switching costs increase and merge conflict likelihood rises. Providing the first review within 24 hours when possible is recommended. If a review delay is expected, informing the author in advance is desirable.

## Roles of Reviewers and Authors

### Reviewer's Role

- Provide constructive and specific feedback
- Clearly distinguish feedback importance (blocking, suggestion, nit)
- Understand author's intent through questions
- Provide positive feedback for good code
- Complete reviews in a timely manner
- Evaluate based on objective criteria, not personal preferences

### Author's Role

- Write detailed PR descriptions (purpose, background, changes, testing methods)
- Submit appropriately sized PRs that are easy to review
- Respond to feedback with an open mind
- Must fix blocking feedback
- Clearly respond to corrections
- Discuss with evidence when there are differences of opinion

## Building a Healthy Review Culture

### Creating Psychological Safety

An environment must be created where team members can give and receive feedback without fear of mistakes. All team members must recognize that review is a collaborative activity for improving code quality, not criticism.

### Documenting Review Guidelines

Documenting and sharing team review criteria, comment level definitions, and expected response times helps maintain a consistent review culture and makes it easier to onboard new team members.

### Separating Automation and Human Roles

Automating checks that can be automated with linters, formatters, static analysis tools, and CI tests is efficient. Humans can then focus on areas difficult for machines to judge, such as design, logic, and meeting business requirements.

### Distributing Review Load

Rotate or use CODEOWNERS files to appropriately distribute reviews so they don't concentrate on specific team members. Provide opportunities for all team members to develop their review capabilities.

## Conclusion

PR review is the modern evolution of code review, which began with Fagan Inspection in the 1970s and became a standard quality management practice in software development after GitHub introduced Pull Requests in 2008. For effective PR reviews, it is important to clearly distinguish feedback levels such as blocking, suggestion, nit, question, and praise, provide specific and actionable feedback, and critique the code while respecting the author. A healthy review culture goes beyond simply finding bugs. It helps teams use collective intelligence, share knowledge, and improve overall code quality and team capability. Building a culture of giving and receiving constructive feedback with psychological safety is an essential part of successful software development.
