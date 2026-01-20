---
title: "The Complete Guide to PR (Pull Request) Reviews"
date: 2024-07-31T22:06:49+09:00
tags: ["git", "pull-request", "code-review", "best-practices", "collaboration"]
description: "A comprehensive guide covering the history of code reviews, the purpose and value of PR reviews, effective review checklists, comment level distinctions like blocking/suggestion/nit, how to write good feedback, and building a healthy review culture."
draft: false
---

PR (Pull Request) review is a core collaborative activity that improves team code quality, shares knowledge among developers, and prevents potential bugs in advance. Since GitHub introduced the Pull Request feature in 2008, it has become the standard code integration method in both open source projects and enterprise development environments. PR reviews go beyond simply finding errors in code to become an essential quality management activity in software development that helps team members understand each other's code, maintain a consistent codebase, and make better design decisions through collective intelligence.

## History of Code Review and Evolution of PR Reviews

> **What is Code Review?**
>
> A software quality assurance activity where other developers review written code to discover bugs, design issues, coding standard violations, and improve code quality.

The history of code review dates back to the 1970s, when IBM's Michael Fagan published a systematic code review methodology called "Fagan Inspection" in 1976, which began to be formally introduced to the software industry. Code reviews at that time followed a Formal Inspection approach where multiple developers would gather in a meeting room and review printed code line by line. This method was effective but had the disadvantage of requiring significant time and manpower.

In the 2000s, code review methods evolved along with the development of Distributed Version Control Systems (DVCS). The emergence of Git in 2005 and GitHub's introduction of the Pull Request feature in 2008 were revolutionary changes that enabled effective code reviews even in asynchronous and distributed environments. Since then, similar features like GitLab's Merge Request and Bitbucket's Pull Request have been introduced on other platforms, and PR-based code review has become established as the standard workflow in modern software development.

## Purpose and Value of PR Reviews

PR reviews provide various purposes and values, serving as a multidimensional activity that goes beyond simple error detection to improve the capabilities of the entire team.

### Improving Code Quality

By reviewing code written by one developer from a different perspective, bugs, edge cases, and performance issues that were not discovered can be identified in advance. According to research, 60-70% of defects can be found before release through code review.

### Knowledge Sharing and Learning

Reviewers can learn new technologies or patterns by reading other developers' code, and authors can learn better coding methods through feedback. In this process, the entire team's understanding of the codebase increases and the Bus Factor (the risk that the project stops if certain people are absent) decreases.

### Maintaining Code Consistency

Team coding conventions, architecture patterns, and naming rules can be consistently maintained. Design-level consistency that automated linters or formatters cannot catch can also be managed through reviews.

### Leveraging Collective Intelligence

For complex problems, better solutions can be found by leveraging the diverse perspectives and experiences of multiple developers. Synergy effects occur where one team member discovers problems that another missed or suggests more efficient approaches.

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

## Comment Level Distinctions

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

Very minor points such as variable names, spacing, and comment typos that do not affect code behavior but are mentioned for consistency or readability. Good to fix, but not fixing does not affect PR approval.

```
[nit] The variable name `cachedUserProfile` would convey intent more clearly than `temp`.

[nit] There's a typo in this comment: "recieve" → "receive"

[nit] Changing the parameter order of this function from `(userId, options)` → `(options, userId)`
would maintain consistency with other functions in the project.
```

### Question

> `[question]`

Questions for understanding the code, used to understand the reason for specific design decisions, unexpected approaches, or to grasp context. Helps the reviewer's understanding and sometimes serves as an opportunity for the author to reconsider their decisions.

```
[question] Is there a reason for using memory cache instead of Redis in this logic?
I'm asking because cache consistency issues might occur across multiple instances.

[question] This exception is being swallowed (caught and ignored) here - is this intended behavior?
Adding logging at least would make debugging easier.
```

### Praise

> `[praise]`

Positive feedback for well-written code, creative solutions, or improved areas. Shows that review is not just an activity that points out problems but also acknowledges and encourages good code.

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

Research shows that review effectiveness decreases sharply for PRs with more than 400 lines of changes. Recommending that large PRs be submitted in smaller units is advisable. However, for already submitted large PRs, respond realistically while suggesting future improvement directions.

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

Documenting and sharing team review criteria, comment level definitions, and expected response times enables maintaining a consistent review culture and helps with onboarding new team members.

### Separating Automation and Human Roles

Automating checks that can be automated with linters, formatters, static analysis tools, and CI tests is efficient. Humans can then focus on areas difficult for machines to judge, such as design, logic, and meeting business requirements.

### Distributing Review Load

Rotate or use CODEOWNERS files to appropriately distribute reviews so they don't concentrate on specific team members. Provide opportunities for all team members to develop their review capabilities.

## Conclusion

PR review is the modern evolution of code review that started with Fagan Inspection in the 1970s and has become a standard quality management activity in software development since GitHub introduced Pull Requests in 2008. For effective PR reviews, it is important to clearly distinguish feedback levels such as blocking, suggestion, nit, question, and praise, provide specific and actionable feedback, and separate criticism of code from respect for the author. A healthy review culture is a core activity that goes beyond simply finding bugs to leverage team collective intelligence, share knowledge, and improve overall code quality and team capabilities. Building a culture of giving and receiving constructive feedback based on psychological safety is an essential element of successful software development.
