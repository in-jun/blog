---
title: "Git 브랜치 네이밍 규칙"
date: 2024-07-23T20:54:17+09:00
tags: ["Git", "버전관리"]
description: "Git 브랜치 이름 작성 규칙과 접두사 사용 방법을 다룬다."
draft: false
---

## 브랜치 네이밍의 역사와 중요성

Git 브랜치 네이밍 규칙은 2010년 Vincent Driessen이 "A successful Git branching model"에서 Git Flow를 소개하면서 체계화되기 시작했다. 이후 GitHub Flow(2011년), GitLab Flow(2014년) 같은 다양한 브랜칭 전략이 등장하면서 `feature/`, `bugfix/`, `hotfix/`, `release/` 같은 접두사 기반 규칙이 업계 표준으로 자리 잡았다. 일관된 브랜치 네이밍은 프로젝트 가독성을 높이고, CI/CD 파이프라인 자동화를 쉽게 하며, 코드 리뷰와 작업 추적의 효율을 높인다.

## 기본 네이밍 규칙

브랜치 이름은 소문자로만 작성하고, 단어 사이는 하이픈(`-`)으로 구분하는 것이 좋다. 국제적인 협업 환경을 고려해 영문으로 작성하고, 5-7단어 이내에서 목적이 드러나도록 간결하게 짓는 편이 관리하기 쉽다. 밑줄(`_`), 마침표(`.`), 특수문자(`!`, `@`, `#`)는 Git의 예약 의미나 운영체제별 호환성 문제를 일으킬 수 있으므로 피하는 것이 안전하다.

```bash
# 좋은 예
feature/user-authentication
bugfix/login-error

# 나쁜 예
Feature_User_Authentication  # 대문자, 밑줄
fix#123  # 특수문자
johns-branch  # 목적 불명확
```

## 브랜치 접두사

브랜치의 목적을 빠르게 파악하려면 접두사를 일관되게 사용하는 것이 좋다. 아래는 많이 쓰이는 접두사와 용도다.

| 접두사 | 용도 | 예시 |
|--------|------|------|
| feature/ | 새로운 기능 개발 | feature/oauth-login |
| bugfix/ | 일반 버그 수정 | bugfix/null-pointer-error |
| hotfix/ | 긴급 프로덕션 수정 | hotfix/security-patch |
| release/ | 릴리스 준비 | release/v2.1.0 |
| refactor/ | 코드 리팩토링 | refactor/extract-service |
| docs/ | 문서 업데이트 | docs/api-reference |
| test/ | 테스트 추가/수정 | test/unit-coverage |
| chore/ | 빌드/설정 변경 | chore/update-deps |
| perf/ | 성능 개선 | perf/query-optimization |
| style/ | 코드 스타일 | style/lint-fixes |

## 이슈 트래커 연동

JIRA, GitHub Issues, Linear 같은 이슈 트래커를 사용한다면 브랜치 이름에 이슈 ID를 포함하는 것이 좋다. 이렇게 하면 이슈와 브랜치 사이의 추적성(traceability)이 높아지고, 코드 리뷰에서도 관련 이슈를 바로 참조할 수 있다. GitHub이나 GitLab에서 이슈와 브랜치를 자동으로 연결하는 경우도 많으며, 일반적으로는 접두사 뒤에 이슈 ID를 두고 짧은 설명을 덧붙인다.

```bash
feature/AUTH-123-oauth-login
bugfix/BUG-456-fix-null-check
hotfix/SEC-789-xss-patch
```

## 장기 브랜치(Long-lived Branches)

프로젝트에서 지속적으로 유지되는 장기 브랜치로는 보통 프로덕션 코드가 배포되는 `main`(또는 `master`), 다음 릴리스를 준비하는 개발 통합 브랜치 `develop`, 그리고 필요에 따라 운영하는 `staging`이 있다. 2020년 GitHub이 기본 브랜치 이름을 `master`에서 `main`으로 바꾼 이후에는 대부분의 새 프로젝트가 `main`을 사용한다.

## 임시 작업 브랜치

개인적인 실험이나 아직 끝나지 않은 작업에는 `wip/`(Work In Progress) 접두사를 사용할 수 있다. 이 접두사는 해당 브랜치가 아직 리뷰나 병합 준비가 되지 않았음을 분명히 보여준다. 작업이 끝나면 적절한 접두사로 바꾸거나 브랜치를 삭제하는 것이 좋다.

```bash
wip/experiment-new-algorithm
wip/spike-redis-caching
```

## 팀 규모별 네이밍 전략

### 소규모 팀 (2-5명)

소규모 팀에서는 직접 소통이 쉬운 만큼 규칙을 지나치게 복잡하게 만들 필요가 없다. `feat/`, `fix/`, `docs/` 같은 간단한 접두사만 두고, 상황에 따라 이슈 번호를 생략해도 충분하다. `feat/login`, `fix/typo`처럼 짧고 명확한 이름이 효율적이다.

### 대규모 팀 (10명 이상)

대규모 팀에서는 브랜치 이름만 보고도 작업 영역을 파악할 수 있어야 한다. 그래서 모듈이나 팀 단위의 네임스페이스를 두고, 이슈 번호도 필수로 포함하는 경우가 많다. `frontend/feat/AUTH-123-oauth`, `backend/fix/API-456-timeout` 같은 형식이 대표적이다.

### 오픈소스 프로젝트

외부 기여자가 많은 오픈소스 프로젝트에서는 기여자를 식별하기 위해 GitHub 사용자명을 브랜치 이름에 포함하기도 한다. `feat/username/add-feature` 형식을 쓰면 누가 어떤 작업을 진행하는지 더 쉽게 추적할 수 있다.

## CI/CD 자동화와의 연계

현대적인 CI/CD 파이프라인은 브랜치 이름 패턴에 따라 서로 다른 작업을 실행하도록 설정할 수 있다. 예를 들어 `feature/*` 브랜치에서는 단위 테스트와 린트만 실행하고, `release/*` 브랜치에서는 스테이징 환경으로 자동 배포하며, `hotfix/*` 브랜치에서는 긴급 프로덕션 배포 파이프라인을 실행할 수 있다. 이렇게 하면 브랜치 이름만으로도 배포 전략을 자동화할 수 있다.

```yaml
# GitHub Actions 예시
on:
  push:
    branches:
      - 'feature/**'
      - 'release/**'
      - 'hotfix/**'
```

## 브랜치 네이밍 안티패턴

피해야 할 이름도 분명하다. `fix`, `update`, `new-feature`처럼 무엇을 바꾸는지 알 수 없는 모호한 이름, `johns-branch`, `my-work`처럼 작업 목적보다 작성자만 드러나는 이름은 좋은 선택이 아니다. `2024-01-15`, `jan-update`처럼 날짜만 담긴 이름, `feature_login!`, `fix#123`처럼 특수문자가 들어간 이름, `feature-add-new-user-authentication-system-with-oauth-jwt-mfa-support`처럼 지나치게 긴 이름도 피하는 편이 좋다.

## 결론

Git 브랜치 네이밍 규칙은 Git Flow 이후 꾸준히 정리되며, 지금은 접두사 기반 이름이 사실상 표준으로 자리 잡았다. 소문자와 하이픈을 기본으로 하고, 필요하면 이슈 ID를 포함해 짧고 명확하게 작성하면 된다. 팀 규모와 프로젝트 특성에 맞게 규칙을 조정하더라도, 핵심은 일관성을 유지하는 데 있다.
