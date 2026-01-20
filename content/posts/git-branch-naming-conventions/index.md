---
title: "Git 브랜치 네이밍 규칙"
date: 2024-07-23T20:54:17+09:00
tags: ["git", "branching", "version-control"]
description: "Git 브랜치 네이밍 규칙은 Vincent Driessen의 Git Flow(2010년)에서 체계화되었으며, feature, bugfix, hotfix 등의 접두사와 이슈 트래커 연동을 통해 팀 협업 효율성을 높인다"
draft: false
---

## 브랜치 네이밍의 역사와 중요성

Git 브랜치 네이밍 규칙은 2010년 Vincent Driessen이 "A successful Git branching model"이라는 블로그 포스트에서 Git Flow를 소개하면서 체계화되기 시작했으며, 이후 GitHub Flow(2011년), GitLab Flow(2014년) 등 다양한 브랜칭 전략이 등장하면서 feature/, bugfix/, hotfix/, release/ 같은 접두사 기반의 네이밍 규칙이 업계 표준으로 자리 잡았고, 일관된 브랜치 네이밍은 프로젝트의 가독성을 높이고 CI/CD 파이프라인 자동화를 용이하게 하며 코드 리뷰와 작업 추적의 효율성을 크게 향상시킨다.

## 기본 네이밍 규칙

브랜치 이름을 작성할 때는 소문자만 사용하고 단어 사이는 하이픈(-)으로 구분하며, 영문으로 작성하여 국제적인 협업 환경에서 호환성을 확보하고, 5-7단어 이내로 간결하게 작성하되 브랜치의 목적이 명확히 드러나도록 해야 하며, 밑줄(_), 마침표(.), 특수문자(!, @, #)는 Git에서 예약된 의미가 있거나 운영체제별 호환성 문제를 일으킬 수 있으므로 피해야 한다.

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

브랜치의 목적을 즉시 파악할 수 있도록 접두사를 사용하며, 가장 널리 사용되는 접두사로는 새로운 기능 개발을 위한 `feature/`, 일반적인 버그 수정을 위한 `bugfix/`, 프로덕션 환경의 긴급 수정을 위한 `hotfix/`, 새 버전 출시 준비를 위한 `release/`, 코드 구조 개선을 위한 `refactor/`, 문서 업데이트를 위한 `docs/`, 테스트 추가 및 수정을 위한 `test/`, 빌드 및 설정 변경을 위한 `chore/`, 성능 개선을 위한 `perf/`, 코드 스타일 변경을 위한 `style/`이 있다.

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

JIRA, GitHub Issues, Linear 같은 이슈 트래커를 사용하는 경우 브랜치 이름에 이슈 ID를 포함하면 이슈와 브랜치 간의 추적성(traceability)이 확보되어 코드 리뷰 시 관련 이슈를 즉시 참조할 수 있고, GitHub이나 GitLab에서 자동으로 이슈와 브랜치를 연결해주며, 이슈 ID는 접두사 바로 뒤에 위치시키고 간략한 설명을 덧붙이는 형식이 일반적이다.

```bash
feature/AUTH-123-oauth-login
bugfix/BUG-456-fix-null-check
hotfix/SEC-789-xss-patch
```

## 장기 브랜치(Long-lived Branches)

프로젝트에서 지속적으로 유지되는 장기 브랜치는 일반적으로 프로덕션 코드가 배포되는 `main`(또는 `master`), 다음 릴리스를 위한 개발 통합 브랜치인 `develop`, 그리고 필요에 따라 스테이징 환경을 위한 `staging`이 있으며, 2020년 GitHub이 기본 브랜치 이름을 master에서 main으로 변경한 이후 대부분의 새 프로젝트에서 main을 사용하고 있다.

## 임시 작업 브랜치

개인적인 실험이나 완료되지 않은 작업을 위해서는 `wip/`(Work In Progress) 접두사를 사용하여 해당 브랜치가 아직 리뷰나 병합 준비가 되지 않았음을 명시하며, 이러한 브랜치는 작업 완료 후 적절한 접두사로 변경하거나 삭제해야 한다.

```bash
wip/experiment-new-algorithm
wip/spike-redis-caching
```

## 팀 규모별 네이밍 전략

### 소규모 팀 (2-5명)

소규모 팀에서는 직접적인 소통이 원활하므로 간단한 접두사(`feat/`, `fix/`, `docs/`)만 사용하고 이슈 번호를 생략할 수 있으며, `feat/login`, `fix/typo` 같이 짧고 간결한 형태가 효율적이다.

### 대규모 팀 (10명 이상)

대규모 팀에서는 모듈이나 팀 단위로 브랜치를 구분하기 위해 추가적인 네임스페이스를 사용하고 이슈 번호를 필수로 포함하며, `frontend/feat/AUTH-123-oauth`, `backend/fix/API-456-timeout` 같은 형식으로 작업 영역을 명확히 구분한다.

### 오픈소스 프로젝트

외부 기여자가 많은 오픈소스 프로젝트에서는 기여자를 식별하기 위해 GitHub 사용자명을 포함하는 옵션을 제공하기도 하며, `feat/username/add-feature` 형식으로 누가 어떤 작업을 하는지 추적할 수 있다.

## CI/CD 자동화와의 연계

현대적인 CI/CD 파이프라인은 브랜치 이름 패턴에 따라 다른 작업을 트리거하도록 설정할 수 있으며, `feature/*` 브랜치는 단위 테스트와 린트 검사만 실행하고, `release/*` 브랜치는 스테이징 환경에 자동 배포하며, `hotfix/*` 브랜치는 긴급 프로덕션 배포 파이프라인을 실행하도록 구성하여 브랜치 이름만으로 배포 전략을 자동화할 수 있다.

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

피해야 할 브랜치 이름 패턴으로는 `fix`, `update`, `new-feature` 같이 무엇을 수정하는지 불명확한 모호한 이름, `johns-branch`, `my-work` 같이 작업 목적이 아닌 작업자 중심의 이름, `2024-01-15`, `jan-update` 같이 내용을 알 수 없는 날짜 기반 이름, `feature_login!`, `fix#123` 같이 Git에서 문제를 일으킬 수 있는 특수문자가 포함된 이름, 그리고 `feature-add-new-user-authentication-system-with-oauth-jwt-mfa-support` 같이 지나치게 긴 이름이 있다.

## 결론

Git 브랜치 네이밍 규칙은 2010년 Git Flow의 등장 이후 꾸준히 발전하여 현재는 feature/, bugfix/, hotfix/, release/ 같은 접두사 기반 네이밍이 업계 표준으로 자리 잡았으며, 소문자와 하이픈을 사용하고 이슈 트래커 ID를 포함하며 5-7단어 이내로 간결하게 작성하는 것이 핵심이고, 팀 규모와 프로젝트 특성에 맞게 규칙을 조정하되 일관성을 유지하면 코드 리뷰 효율성, 작업 추적성, CI/CD 자동화 모두에서 이점을 얻을 수 있다.
