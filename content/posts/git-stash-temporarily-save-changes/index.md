---
title: "Git Stash로 변경 사항 임시 저장하기"
date: 2024-07-26T14:39:46+09:00
tags: ["git", "stash", "version-control"]
description: "Git stash는 2007년 Git 1.5.3에서 도입된 스택 기반 임시 저장 기능으로, 커밋하지 않은 변경 사항을 저장하고 나중에 복원할 수 있으며, pop과 apply의 차이점, 충돌 해결, untracked 파일 처리를 다룬다"
draft: false
---

## Git Stash의 개념과 역사

Git stash는 2007년 Git 1.5.3 버전에서 처음 도입된 기능으로, Working Directory의 변경 사항(수정된 tracked 파일과 staged 상태의 변경)을 커밋하지 않고 스택(stack) 구조의 임시 저장소에 저장했다가 나중에 다시 적용할 수 있는 메커니즘이며, 작업 중인 브랜치에서 급하게 다른 브랜치로 전환해야 하거나 원격 저장소의 변경 사항을 가져와야 할 때 현재 진행 중인 작업을 커밋하기에는 애매한 상태일 경우 유용하게 사용된다.

커밋하지 않은 변경 사항이 있는 상태에서 브랜치를 전환하려고 하면 Git은 다음과 같은 에러 메시지를 표시하며 전환을 거부하는데, 이는 현재 Working Directory의 변경 사항이 체크아웃하려는 브랜치의 파일과 충돌할 수 있기 때문이다.

```bash
error: Your local changes to the following files would be overwritten by checkout:
        file.txt
Please commit your changes or stash them before you switch branches.
Aborting
```

## 기본 사용법

### 변경 사항 저장: git stash

`git stash` 명령어는 Working Directory와 Staging Area의 변경 사항을 stash 스택에 저장하고 Working Directory를 마지막 커밋 상태로 깨끗하게 되돌리며, 기본적으로 tracked 파일(이미 Git이 추적 중인 파일)의 변경 사항만 저장하고 untracked 파일이나 .gitignore에 의해 무시되는 파일은 포함하지 않는다.

```bash
git stash
```

메시지와 함께 저장하려면 `save` 서브 명령어(또는 `push -m`)를 사용하며, 이는 여러 stash를 관리할 때 각 stash가 어떤 작업인지 식별하는 데 유용하다.

```bash
git stash save "로그인 기능 작업 중"
git stash push -m "로그인 기능 작업 중"  # Git 2.13+ 권장 방식
```

### stash 목록 확인: git stash list

저장된 stash들의 목록을 확인하는 명령어로, 각 stash는 `stash@{n}` 형식의 인덱스로 참조되며 가장 최근에 저장한 것이 `stash@{0}`이고, 브랜치 이름과 커밋 메시지도 함께 표시되어 어떤 상황에서 stash했는지 파악할 수 있다.

```bash
git stash list
# stash@{0}: WIP on main: abc1234 feat: 로그인 기능 구현
# stash@{1}: On develop: def5678 fix: 버그 수정
```

### stash 적용: git stash apply vs pop

저장된 stash를 다시 Working Directory에 적용하는 명령어는 `apply`와 `pop` 두 가지가 있으며, `apply`는 stash를 적용하되 스택에서 제거하지 않아 동일한 stash를 여러 브랜치에 적용할 수 있고, `pop`은 적용과 동시에 스택에서 제거하여 일반적인 사용 시 권장되는 방식이며, 특정 stash를 적용하려면 인덱스를 지정할 수 있다.

```bash
git stash apply           # 최근 stash 적용, 스택 유지
git stash pop             # 최근 stash 적용 후 스택에서 제거
git stash apply stash@{2} # 특정 stash 적용
```

중요한 차이점은 `pop`을 사용했을 때 충돌이 발생하면 stash가 자동으로 제거되지 않고 스택에 남아있어 충돌 해결 후 수동으로 `drop` 해야 한다는 점이다.

### stash 삭제: git stash drop과 clear

특정 stash를 스택에서 제거하려면 `drop`을, 모든 stash를 한 번에 제거하려면 `clear`를 사용하며, `drop`은 인덱스를 지정하지 않으면 가장 최근 stash(`stash@{0}`)를 제거한다.

```bash
git stash drop            # 최근 stash 제거
git stash drop stash@{1}  # 특정 stash 제거
git stash clear           # 모든 stash 제거
```

## 고급 옵션

### untracked 파일 포함: -u 옵션

기본적으로 stash는 tracked 파일의 변경 사항만 저장하므로, 새로 생성했지만 아직 `git add`하지 않은 untracked 파일을 함께 저장하려면 `-u` 또는 `--include-untracked` 옵션을 사용해야 한다.

```bash
git stash -u
```

### ignored 파일 포함: -a 옵션

.gitignore에 의해 무시되는 파일까지 모두 포함하여 stash하려면 `-a` 또는 `--all` 옵션을 사용하며, 이는 빌드 결과물이나 캐시 파일까지 임시 저장해야 하는 특수한 경우에 사용한다.

```bash
git stash -a
```

### stash 내용 확인: git stash show

stash에 저장된 변경 사항을 커밋처럼 확인할 수 있으며, `-p` 옵션을 추가하면 diff 형식으로 상세한 변경 내용을 볼 수 있어 stash를 적용하기 전에 어떤 내용이 들어있는지 미리 확인할 때 유용하다.

```bash
git stash show            # 변경된 파일 목록
git stash show -p         # diff 형식으로 상세 확인
git stash show stash@{1}  # 특정 stash 확인
```

## 충돌 해결

stash를 적용할 때 현재 Working Directory의 내용과 충돌이 발생할 수 있으며, 충돌이 발생하면 merge conflict와 동일한 방식으로 충돌 마커(`<<<<<<<`, `=======`, `>>>>>>>`)가 파일에 표시되고, 수동으로 충돌을 해결한 후 `git add`로 스테이징하고, `pop`을 사용했다면 stash가 스택에 남아있으므로 `git stash drop`으로 제거해야 한다.

```bash
# 충돌 발생 시
Auto-merging file.txt
CONFLICT (content): Merge conflict in file.txt

# 해결 순서
# 1. 파일을 열어 충돌 마커 확인 및 수동 해결
# 2. git add file.txt
# 3. git stash drop (pop 사용 시)
```

## 실전 활용 시나리오

### 긴급 버그 수정

기능 개발 중 긴급한 버그 수정 요청이 들어왔을 때, 현재 작업을 stash로 저장하고 버그 수정 브랜치로 전환한 후 수정을 완료하고 원래 브랜치로 돌아와 stash를 복원하는 패턴이다.

```bash
git stash push -m "feature/login 작업 중"
git checkout hotfix/critical-bug
# 버그 수정 작업 및 커밋
git checkout feature/login
git stash pop
```

### 원격 변경 사항 가져오기

로컬에 커밋하지 않은 변경 사항이 있는 상태에서 원격 저장소의 최신 변경 사항을 가져와야 할 때, stash로 로컬 변경을 저장하고 pull을 수행한 후 다시 적용하며, 충돌이 발생하면 해결 후 진행한다.

```bash
git stash
git pull origin main
git stash pop  # 충돌 시 해결 후 git stash drop
```

## 결론

Git stash는 2007년 Git 1.5.3에서 도입된 이래로 커밋하지 않은 변경 사항을 임시로 저장하고 나중에 복원할 수 있는 필수적인 기능으로 자리 잡았으며, `apply`와 `pop`의 차이점(스택 제거 여부)을 이해하고, `-u` 옵션으로 untracked 파일을 포함하고, 충돌 발생 시 수동 해결 후 `drop`이 필요하다는 점을 숙지하면 브랜치 전환, 긴급 작업, 원격 동기화 등 다양한 상황에서 작업 흐름을 유연하게 관리할 수 있다.
