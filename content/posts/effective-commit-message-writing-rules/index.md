---
title: "효과적인 커밋 메시지 작성 규칙"
date: 2024-07-12T08:48:08+09:00
tags: ["git", "commit", "conventional-commits", "version-control"]
description: "커밋 메시지 작성 규칙은 2009년 Tim Pope의 가이드라인에서 시작되어 2017년 Conventional Commits 표준으로 발전했으며, 제목 50자 제한, 명령형 사용, 타입 지정, 본문에서 무엇과 왜 설명하기가 핵심이다"
draft: false
---

## 커밋 메시지의 역사와 중요성

커밋 메시지 작성에 대한 체계적인 가이드라인은 2008년 Tim Pope가 "A Note About Git Commit Messages"라는 블로그 포스트에서 50/72 규칙(제목 50자, 본문 72자 줄바꿈)을 제안하면서 널리 알려지기 시작했으며, 이후 2014년 Angular 팀이 AngularJS 프로젝트를 위해 개발한 커밋 메시지 컨벤션이 업계에서 주목받았고, 2017년에는 이를 기반으로 Conventional Commits 1.0.0이 발표되어 현재 오픈소스 프로젝트에서 가장 널리 사용되는 표준으로 자리 잡았다.

커밋 메시지가 중요한 이유는 Git 히스토리가 프로젝트의 변경 이력을 담은 문서 역할을 하기 때문이며, 잘 작성된 커밋 메시지는 `git log`만으로 프로젝트의 발전 과정을 파악할 수 있게 하고, `git bisect`로 버그가 도입된 커밋을 찾을 때 어떤 변경이 문제인지 즉시 이해할 수 있게 하며, 코드 리뷰어가 변경의 의도를 파악하는 데 소요되는 시간을 크게 줄여준다.

## 커밋 메시지 구조

커밋 메시지는 제목(subject), 본문(body), 꼬리말(footer) 세 부분으로 구성되며, 각 부분은 빈 줄로 구분된다.

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 제목 작성 규칙

제목은 커밋의 핵심 내용을 한 줄로 요약하며, 다음 규칙을 따른다.

**50자 이내로 작성**: 50자를 초과하면 `git log --oneline`이나 GitHub의 커밋 목록에서 잘려서 표시되므로, 핵심만 간결하게 전달해야 한다.

**명령형(imperative) 사용**: Git 자체가 자동 생성하는 메시지(Merge branch, Revert commit)가 명령형을 사용하므로, 일관성을 위해 "Add feature"처럼 명령형으로 작성하며, "Added feature"나 "Adding feature"는 피한다.

**마침표 생략**: 제목은 문장이 아닌 제목이므로 마침표를 붙이지 않으며, 이는 공간 절약과 함께 시각적 일관성을 제공한다.

**첫 글자 대문자**: 영문 작성 시 첫 글자는 대문자로 시작하며, 이는 가독성을 높이고 전문적인 인상을 준다.

```bash
# 좋은 예
feat: Add user authentication
fix: Resolve null pointer exception in UserService
refactor: Extract payment logic into separate module

# 나쁜 예
feat: added user authentication.  # 과거형, 마침표
Fix null pointer  # 타입 소문자, 설명 불충분
```

### 본문 작성 규칙

본문은 제목만으로 전달할 수 없는 상세 내용을 설명하며, 모든 커밋에 필수는 아니지만 복잡한 변경이나 비자명한 결정을 설명할 때 작성한다.

**무엇(What)과 왜(Why)에 초점**: 코드를 보면 "어떻게(How)" 변경했는지는 알 수 있으므로, 본문에서는 "무엇을 변경했는지"와 "왜 이 변경이 필요했는지"를 설명해야 하며, 특히 "왜"가 가장 중요한데 이는 미래의 개발자(자신 포함)가 변경의 맥락을 이해하는 데 핵심적인 정보이기 때문이다.

**72자 줄바꿈**: 터미널에서 `git log`를 볼 때 가독성을 위해 72자마다 줄바꿈하며, 이는 들여쓰기와 여백을 고려했을 때 80자 터미널에서 최적의 가독성을 제공하는 너비이다.

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

### 꼬리말 규칙

꼬리말은 이슈 연동, Breaking Change 명시, 공동 작성자 표시 등 메타데이터를 기록하며, `키: 값` 형식을 따른다.

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

## Conventional Commits 타입

Conventional Commits 표준에서 정의하는 타입은 커밋의 성격을 즉시 파악할 수 있게 하며, 각 타입은 명확한 용도를 가진다.

| 타입 | 용도 | 예시 |
|------|------|------|
| feat | 새로운 기능 추가 | feat: Add OAuth2 social login |
| fix | 버그 수정 | fix: Resolve memory leak in cache |
| docs | 문서 변경 | docs: Update API documentation |
| style | 코드 포맷팅 (동작 변화 없음) | style: Apply prettier formatting |
| refactor | 리팩토링 (기능/버그 수정 아님) | refactor: Extract validation logic |
| perf | 성능 개선 | perf: Optimize database queries |
| test | 테스트 추가/수정 | test: Add unit tests for UserService |
| build | 빌드 시스템/외부 의존성 변경 | build: Upgrade webpack to v5 |
| ci | CI 설정 변경 | ci: Add GitHub Actions workflow |
| chore | 기타 변경 (src/test 외) | chore: Update .gitignore |
| revert | 이전 커밋 되돌리기 | revert: Revert "feat: Add login" |

### scope 사용

scope는 변경이 영향을 미치는 모듈이나 컴포넌트를 명시하며, 괄호 안에 작성하고 프로젝트마다 일관된 scope 목록을 정의하여 사용하는 것이 좋다.

```bash
feat(auth): Add two-factor authentication
fix(api): Handle timeout errors gracefully
docs(readme): Add installation instructions
refactor(core): Simplify event handling logic
```

### Breaking Change 표시

API 호환성을 깨는 변경은 두 가지 방법으로 표시할 수 있으며, 타입 뒤에 `!`를 붙이거나 꼬리말에 `BREAKING CHANGE:`를 명시한다.

```bash
# 방법 1: 타입 뒤 ! 사용
feat(api)!: Change authentication endpoint response format

# 방법 2: 꼬리말 사용
feat(api): Change authentication endpoint response format

BREAKING CHANGE: The /auth/login endpoint now returns a JSON object
instead of a plain token string. Clients must update to extract the
token from the `accessToken` field.
```

## 자동화 도구

커밋 메시지 규칙을 강제하고 활용하기 위한 도구들이 발전해왔다.

**Commitlint**는 2016년에 등장한 도구로 커밋 메시지가 정해진 규칙을 따르는지 자동으로 검증하며, Husky와 함께 사용하여 Git hook으로 커밋 전에 검사를 수행할 수 있다.

**Commitizen**은 대화형 CLI를 제공하여 규칙에 맞는 커밋 메시지를 쉽게 작성할 수 있게 하며, `git cz` 명령으로 타입, scope, 설명을 단계별로 입력받는다.

**standard-version**과 **semantic-release**는 Conventional Commits 메시지를 분석하여 시맨틱 버전을 자동으로 결정하고 CHANGELOG를 생성하는 도구로, feat 커밋은 minor 버전을, fix 커밋은 patch 버전을, BREAKING CHANGE는 major 버전을 올린다.

```json
// package.json 예시
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

## 실전 예시

### 기능 추가

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

### 버그 수정

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

### 리팩토링

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

## 결론

커밋 메시지 작성 규칙은 2008년 Tim Pope의 50/72 규칙에서 시작되어 2014년 Angular 컨벤션을 거쳐 2017년 Conventional Commits 표준으로 발전해왔으며, 핵심은 제목 50자 이내의 명령형 요약, 본문에서 무엇과 왜 설명, feat/fix/docs 등 타입 지정, 그리고 Breaking Change 명시이다. Commitlint, Commitizen, standard-version 같은 도구를 활용하면 규칙 준수를 자동화하고 시맨틱 버전 관리와 CHANGELOG 생성까지 연계할 수 있어, 일관된 커밋 메시지는 단순한 문서화를 넘어 자동화된 릴리스 파이프라인의 기반이 된다.
