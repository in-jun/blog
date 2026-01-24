---
title: "Git 커밋 관리와 클린 히스토리"
date: 2024-07-13T09:41:43+09:00
tags: ["Git", "버전관리"]
description: "Interactive rebase와 squash를 사용한 Git 히스토리 관리 기법을 설명한다."
draft: false
---

## 커밋 관리의 역사와 중요성

Git의 커밋 관리 기능은 2005년 Linus Torvalds가 Git을 개발할 때부터 핵심 설계 원칙 중 하나였으며, 특히 rebase 기능은 Git 초기 버전부터 존재했고 2007년 Git 1.5에서 interactive rebase가 도입되면서 커밋 히스토리를 세밀하게 편집할 수 있는 강력한 도구가 되었다.

커밋 히스토리 관리가 중요한 이유는 Git 로그가 프로젝트의 변경 이력을 담은 문서 역할을 하기 때문이며, 잘 정리된 히스토리는 `git log`만으로 프로젝트의 발전 과정을 파악할 수 있게 하고, `git bisect`로 버그를 추적할 때 각 커밋의 의도를 명확히 이해할 수 있게 하며, 새로운 팀원이 프로젝트에 합류했을 때 코드베이스의 변천사를 빠르게 파악할 수 있게 한다.

## 단일 책임 원칙의 커밋 적용

### 원칙의 배경

소프트웨어 설계의 SOLID 원칙 중 하나인 단일 책임 원칙(Single Responsibility Principle)은 2003년 Robert C. Martin이 정립한 개념으로, "클래스는 하나의 변경 이유만 가져야 한다"는 원칙이며, 이를 Git 커밋에 적용하면 "커밋은 하나의 논리적 변경만 담아야 한다"가 된다.

### 왜 중요한가

단일 책임 커밋이 중요한 이유는 여러 가지가 있는데, 첫째로 코드 리뷰 시 리뷰어가 한 번에 하나의 변경에만 집중할 수 있어 리뷰 품질이 향상되고, 둘째로 문제가 발생했을 때 `git revert`로 특정 변경만 되돌릴 수 있어 롤백이 용이하며, 셋째로 `git cherry-pick`으로 특정 기능만 다른 브랜치로 가져갈 수 있어 유연성이 높아지고, 넷째로 `git bisect`로 버그 원인을 찾을 때 범위를 좁히기 쉬워진다.

### 실천 방법

단일 책임 원칙을 커밋에 적용하는 구체적인 방법은 다음과 같다.

**논리적 단위로 분리**: 버그 수정, 기능 추가, 리팩토링은 각각 별도의 커밋으로 분리하며, 예를 들어 로그인 기능을 추가하면서 발견한 기존 버그를 수정했다면 버그 수정 커밋과 기능 추가 커밋을 분리한다.

**"그리고" 테스트**: 커밋 메시지에 "그리고(and)"가 들어간다면 커밋을 나눠야 할 신호이며, "로그인 기능 추가 그리고 회원가입 폼 수정"은 두 개의 커밋으로 분리해야 한다.

**Staging Area 활용**: `git add -p`(patch mode)를 사용하면 파일 내에서도 변경 사항을 선택적으로 스테이징할 수 있어 하나의 파일에서 여러 논리적 변경이 있을 때 유용하다.

```bash
# 파일의 일부 변경만 스테이징
git add -p filename.js

# 대화형 모드에서 선택
# y: 이 hunk 스테이징
# n: 이 hunk 건너뛰기
# s: hunk를 더 작게 분할
# e: 수동으로 편집
```

## 자주 커밋하기

### 장점

자주 커밋하는 습관의 장점은 변경 사항을 세밀하게 추적할 수 있어 특정 시점의 코드 상태로 쉽게 돌아갈 수 있고, 작업 중간에 데이터 손실 위험이 줄어들며, 팀원과 더 자주 동기화할 수 있어 대규모 merge 충돌을 방지할 수 있다는 점이다.

### WIP 커밋 전략

작업 중인(Work In Progress) 상태를 커밋할 때는 나중에 정리할 것을 전제로 `WIP:` 접두사를 사용하며, 이 커밋들은 PR 전에 squash하거나 rebase로 정리한다.

```bash
# WIP 커밋 예시
git commit -m "WIP: Add login form skeleton"
git commit -m "WIP: Connect login to API"
git commit -m "WIP: Add error handling"

# PR 전 정리
git rebase -i HEAD~3
# 세 커밋을 하나의 완성된 커밋으로 squash
```

### 주의점

너무 잦은 커밋이 히스토리를 파편화할 수 있으므로, 로컬에서는 자주 커밋하되 원격에 push하기 전에 논리적 단위로 정리하는 것이 좋으며, 이를 위해 rebase와 squash를 활용한다.

## Interactive Rebase로 히스토리 정리

### rebase의 역사

`git rebase`는 Git 초기 버전부터 존재했으나, interactive rebase(`git rebase -i`)는 2007년 Git 1.5.4에서 도입되었으며, Johannes Schindelin이 개발한 이 기능은 커밋 히스토리를 세밀하게 편집할 수 있는 강력한 도구로 현재까지 Git 워크플로우의 핵심 기능으로 사용되고 있다.

### 기본 사용법

interactive rebase를 시작하면 에디터가 열리고 각 커밋에 대해 수행할 작업을 지정할 수 있다.

```bash
git rebase -i HEAD~5  # 최근 5개 커밋 편집
```

에디터에서 사용 가능한 명령은 다음과 같다.

| 명령 | 축약 | 설명 |
|------|------|------|
| pick | p | 커밋을 그대로 유지 |
| reword | r | 커밋 메시지만 수정 |
| edit | e | 커밋을 수정하기 위해 멈춤 |
| squash | s | 이전 커밋과 합치고 메시지도 합침 |
| fixup | f | 이전 커밋과 합치지만 메시지는 버림 |
| drop | d | 커밋을 삭제 |

### 실전 예시: 커밋 정리

로컬에서 작업하다 보면 다음과 같은 커밋 히스토리가 생길 수 있다.

```
abc1234 Add login feature
def5678 Fix typo in login
ghi9012 Add missing import
jkl3456 Fix login button style
mno7890 Add logout feature
```

이를 정리하려면:

```bash
git rebase -i HEAD~5
```

에디터에서:

```
pick abc1234 Add login feature
fixup def5678 Fix typo in login
fixup ghi9012 Add missing import
fixup jkl3456 Fix login button style
pick mno7890 Add logout feature
```

결과적으로 두 개의 깔끔한 커밋만 남는다:

```
abc1234 Add login feature
mno7890 Add logout feature
```

### autosquash 활용

Git 1.7.4에서 도입된 `--autosquash` 옵션은 커밋 메시지에 `fixup!`이나 `squash!` 접두사가 있으면 자동으로 정렬해주며, 이를 활용하면 나중에 정리할 커밋을 미리 표시해둘 수 있다.

```bash
# 원본 커밋
git commit -m "Add user authentication"

# 나중에 수정 사항 발생
git commit --fixup=abc1234  # "fixup! Add user authentication" 메시지로 커밋

# rebase 시 자동 정렬
git rebase -i --autosquash HEAD~3
```

## amend로 마지막 커밋 수정

### 사용 시나리오

`git commit --amend`는 방금 만든 커밋을 수정할 때 사용하며, 새로운 커밋을 만들지 않고 기존 커밋을 수정하므로 히스토리가 깔끔하게 유지된다.

```bash
# 파일 추가를 깜빡했을 때
git add forgotten-file.js
git commit --amend --no-edit

# 커밋 메시지를 수정하고 싶을 때
git commit --amend -m "feat: Add user authentication with JWT"

# 파일과 메시지 둘 다 수정
git add extra-file.js
git commit --amend -m "feat: Add user authentication with JWT and refresh token"
```

### 주의사항

`--amend`와 `rebase`는 커밋의 SHA-1 해시를 변경하므로, 이미 원격에 push한 커밋에 사용하면 히스토리가 diverge되어 `--force` push가 필요하며, 이는 협업 시 다른 팀원의 로컬 히스토리와 충돌을 일으킬 수 있으므로 공유된 브랜치에서는 사용을 피해야 한다.

```bash
# 아직 push 전: 안전하게 사용 가능
git commit --amend

# 이미 push 후: force push 필요 (협업 시 주의)
git push --force-with-lease origin feature/my-branch
```

`--force-with-lease`는 `--force`보다 안전한 옵션으로, 다른 사람이 push한 변경이 있으면 실패하여 의도치 않은 덮어쓰기를 방지한다.

## reset으로 커밋 되돌리기

### soft, mixed, hard의 차이

`git reset`은 HEAD의 위치를 변경하며, 옵션에 따라 Staging Area와 Working Directory에 미치는 영향이 다르다.

| 옵션 | HEAD | Staging Area | Working Directory |
|------|------|--------------|-------------------|
| --soft | 이동 | 유지 | 유지 |
| --mixed (기본) | 이동 | 초기화 | 유지 |
| --hard | 이동 | 초기화 | 초기화 |

```bash
# soft: 커밋만 취소, 변경 사항은 staged 상태로 유지
git reset --soft HEAD~1

# mixed: 커밋 취소, 변경 사항은 unstaged 상태로 유지
git reset HEAD~1

# hard: 커밋과 변경 사항 모두 삭제 (주의!)
git reset --hard HEAD~1
```

### 실전 활용: squash 대안

여러 커밋을 하나로 합치는 간단한 방법으로 soft reset을 사용할 수 있다.

```bash
# 최근 3개 커밋을 하나로 합치기
git reset --soft HEAD~3
git commit -m "feat: Add complete user authentication system"
```

## 결론

Git 커밋 관리 기법은 2005년 Git 탄생 이후 interactive rebase(2007), autosquash(2010) 등의 기능이 추가되면서 계속 발전해왔으며, 핵심 원칙은 단일 책임 원칙을 커밋에 적용하여 하나의 논리적 변경만 담는 것, 로컬에서는 자주 커밋하되 push 전에 정리하는 것, interactive rebase와 fixup/squash로 히스토리를 깔끔하게 유지하는 것이다. 클린 코드만큼이나 클린 히스토리도 중요하며, 잘 정리된 커밋 히스토리는 코드 리뷰, 버그 추적, 새 팀원 온보딩 모든 면에서 프로젝트의 품질을 높인다.
