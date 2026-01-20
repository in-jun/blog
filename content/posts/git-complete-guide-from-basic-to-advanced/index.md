---
title: "Git 사용법: 기초부터 고급 기능까지"
date: 2024-07-08T20:52:04+09:00
tags: ["git", "version-control", "devops"]
description: "Git은 2005년 Linus Torvalds가 리눅스 커널 개발을 위해 만든 분산 버전 관리 시스템으로, Working Directory, Staging Area, Local/Remote Repository의 4영역 구조와 핵심 명령어를 다룬다"
draft: false
---

## Git의 역사와 탄생 배경

Git은 2005년 리눅스 커널의 창시자인 Linus Torvalds가 개발한 분산 버전 관리 시스템(Distributed Version Control System, DVCS)으로, 당시 리눅스 커널 개발에 사용하던 상용 DVCS인 BitKeeper의 무료 사용권이 철회되면서 대안이 필요해졌고, Torvalds는 기존 버전 관리 시스템들의 단점(느린 속도, 비효율적인 브랜칭)을 극복하고 대규모 프로젝트에서도 빠르게 동작하며 완전한 분산 환경을 지원하는 새로운 시스템을 단 2주 만에 개발하여 2005년 4월 7일 첫 버전을 공개했다.

Git이라는 이름은 영국 속어로 "불쾌한 사람"을 의미하는데, Torvalds는 자신의 이름을 딴 Linux와 마찬가지로 Git도 자신을 따서 지었다고 농담처럼 설명했으며, 공식 매뉴얼에서는 "Global Information Tracker(전역 정보 추적기)"의 약자라고도 설명하고 있다.

## Git의 4영역 구조

Git은 Working Directory(작업 디렉터리), Staging Area(스테이징 영역), Local Repository(로컬 저장소), Remote Repository(원격 저장소)의 네 가지 영역으로 구성되어 있으며, Working Directory는 실제 파일들이 존재하고 코드를 작성하고 수정하는 공간이고, Staging Area(또는 Index)는 다음 커밋에 포함될 변경 사항들이 대기하는 중간 영역이며, Local Repository는 `.git` 디렉터리에 저장되는 커밋된 버전들의 데이터베이스이고, Remote Repository는 GitHub, GitLab, Bitbucket 같은 서버에 위치한 팀원들과 공유하는 저장소로, 이 네 영역 간의 데이터 흐름을 이해하면 Git 명령어들의 동작 방식을 더 명확하게 파악할 수 있다.

## 저장소 초기화: git init

`git init` 명령어는 현재 디렉터리를 새로운 Git 저장소로 초기화하는 명령어로, 실행하면 `.git`이라는 숨겨진 디렉터리가 생성되어 Git이 버전 관리에 필요한 모든 메타데이터(객체 데이터베이스, 참조 정보, 설정 파일 등)를 저장하며, 기존 프로젝트를 Git으로 관리하기 시작할 때나 완전히 새로운 프로젝트를 시작할 때 가장 먼저 실행하는 명령어이다.

```bash
git init
```

## 상태 확인: git status

`git status` 명령어는 Working Directory와 Staging Area의 현재 상태를 보여주는 명령어로, 어떤 파일이 수정되었는지, 어떤 파일이 스테이징되어 커밋 대기 중인지, 어떤 파일이 아직 Git이 추적하지 않는 새 파일인지 등의 정보를 제공하며, `-s` 또는 `--short` 옵션을 사용하면 간략한 형식으로 출력하고, `-b` 또는 `--branch` 옵션을 추가하면 현재 브랜치 정보도 함께 표시한다.

```bash
git status
git status -sb  # 간략한 형식 + 브랜치 정보
```

## 파일 스테이징: git add

`git add` 명령어는 Working Directory의 변경 사항을 Staging Area에 추가하여 다음 커밋에 포함시킬 준비를 하는 명령어로, 특정 파일만 스테이징하려면 `git add <파일명>`을, 현재 디렉터리의 모든 변경 사항을 스테이징하려면 `git add .`을 사용하며, `-p` 옵션을 사용하면 각 변경 사항을 hunks 단위로 대화형으로 검토하며 선택적으로 스테이징할 수 있어 하나의 파일에서 여러 논리적 변경 사항을 별도의 커밋으로 분리할 때 유용하고, `-u` 옵션은 이미 추적 중인 파일들의 변경 사항만 스테이징한다.

```bash
git add <파일명>
git add .
git add -p  # 대화형 스테이징
```

## 스테이징 취소: git restore

Git 2.23.0(2019년 8월)에서 도입된 `git restore` 명령어는 파일의 상태를 복원하는 명령어로, `--staged` 옵션과 함께 사용하면 Staging Area에 추가한 변경 사항을 취소하여 Working Directory의 수정된 상태로 되돌리고, 옵션 없이 사용하면 Working Directory의 수정 사항을 마지막 커밋 상태로 되돌리며, 이전 버전의 Git에서는 `git reset HEAD <파일명>` 명령어로 동일한 작업을 수행했다.

```bash
git restore --staged <파일명>  # 스테이징 취소
git restore <파일명>  # 워킹 디렉터리 변경 취소
```

## 변경 사항 커밋: git commit

`git commit` 명령어는 Staging Area에 있는 변경 사항들을 Local Repository에 새로운 커밋(스냅샷)으로 기록하는 명령어로, `-m` 옵션으로 커밋 메시지를 인라인으로 작성하거나 옵션 없이 실행하면 설정된 텍스트 편집기가 열려 상세한 커밋 메시지를 작성할 수 있으며, `-a` 옵션은 이미 추적 중인 모든 파일의 변경 사항을 자동으로 스테이징하고 커밋하여 `git add`와 `git commit`을 한 번에 수행하고, `--amend` 옵션은 마지막 커밋의 메시지를 수정하거나 누락된 변경 사항을 추가할 때 사용한다.

```bash
git commit -m "feat: 로그인 기능 구현"
git commit -am "fix: 버그 수정"  # add + commit
git commit --amend  # 마지막 커밋 수정
```

## 커밋 취소: git reset과 git revert

`git reset` 명령어는 커밋을 취소하고 HEAD 포인터를 이전 커밋으로 이동시키는 명령어로, `--soft` 옵션은 커밋만 취소하고 변경 사항을 Staging Area에 유지하며, `--mixed` 옵션(기본값)은 커밋을 취소하고 변경 사항을 Working Directory로 되돌리고, `--hard` 옵션은 커밋과 함께 변경 사항을 완전히 삭제하므로 주의해서 사용해야 하며, `HEAD^`는 바로 이전 커밋을, `HEAD~3`은 3개 이전 커밋을 가리킨다.

```bash
git reset --soft HEAD^   # 커밋 취소, 스테이징 유지
git reset HEAD^          # 커밋 취소, 워킹 디렉터리로
git reset --hard HEAD^   # 커밋 취소, 변경 삭제
```

`git revert` 명령어는 특정 커밋의 변경 사항을 되돌리는 새로운 커밋을 생성하는 명령어로, 이미 원격 저장소에 푸시된 커밋을 안전하게 취소할 때 사용하며, `reset`과 달리 히스토리를 유지하면서 변경 사항을 되돌리므로 협업 환경에서 권장되는 방식이다.

```bash
git revert <커밋 해시>
```

## 커밋 히스토리 확인: git log

`git log` 명령어는 프로젝트의 커밋 히스토리를 시간순(최신순)으로 보여주는 명령어로, 각 커밋의 해시, 작성자, 날짜, 커밋 메시지를 확인할 수 있으며, `--oneline` 옵션은 각 커밋을 한 줄로 간략하게 표시하고, `--graph` 옵션은 브랜치와 머지 히스토리를 ASCII 그래프로 시각화하며, `--stat` 옵션은 각 커밋에서 변경된 파일들의 통계를 보여주고, `--all` 옵션은 모든 브랜치의 히스토리를 표시한다.

```bash
git log
git log --oneline --graph --all  # 전체 브랜치 그래프
git log --stat  # 변경 파일 통계
```

## 원격 저장소 관리: git remote

`git remote` 명령어는 로컬 저장소와 연결된 원격 저장소들을 관리하는 명령어로, `add` 서브 명령어로 새 원격 저장소를 추가하고, `remove`로 연결을 제거하며, `set-url`로 기존 원격 저장소의 URL을 변경할 수 있고, `-v` 옵션은 등록된 원격 저장소들의 이름과 URL을 상세히 보여주며, 관례적으로 주 원격 저장소의 이름은 `origin`을 사용한다.

```bash
git remote add origin <URL>
git remote -v  # 원격 저장소 목록
git remote set-url origin <새 URL>
```

## 원격 저장소 동기화: git push와 git pull

`git push` 명령어는 Local Repository의 커밋을 Remote Repository에 업로드하는 명령어이고, `git pull` 명령어는 Remote Repository의 변경 사항을 Local Repository로 가져와 현재 브랜치에 병합하는 명령어로, push 시 `--force` 옵션은 원격 브랜치를 강제로 덮어쓰므로 협업 환경에서는 주의해야 하며, pull 시 `--rebase` 옵션은 병합 대신 리베이스를 수행하여 더 깔끔한 히스토리를 유지할 수 있다.

```bash
git push origin main
git pull origin main
git pull --rebase origin main  # 리베이스 방식
```

## 브랜치 관리: git branch와 git checkout

`git branch` 명령어는 브랜치를 생성, 조회, 삭제하는 명령어로, 인자 없이 실행하면 로컬 브랜치 목록을 보여주고, `<브랜치명>`을 인자로 주면 새 브랜치를 생성하며, `-d` 옵션은 병합된 브랜치를 삭제하고 `-D` 옵션은 병합 여부와 관계없이 강제 삭제한다.

`git checkout` 명령어는 브랜치를 전환하거나 특정 커밋으로 이동하는 명령어로, `-b` 옵션과 함께 사용하면 새 브랜치를 생성하고 즉시 전환하며, Git 2.23.0부터는 브랜치 전환 용도로 `git switch` 명령어도 사용할 수 있다.

```bash
git branch  # 브랜치 목록
git branch <브랜치명>  # 브랜치 생성
git checkout <브랜치명>  # 브랜치 전환
git checkout -b <브랜치명>  # 생성 + 전환
git switch <브랜치명>  # 브랜치 전환 (Git 2.23+)
```

## 브랜치 병합: git merge

`git merge` 명령어는 지정한 브랜치의 변경 사항을 현재 브랜치에 통합하는 명령어로, 두 브랜치의 공통 조상 커밋을 찾아 3-way merge를 수행하며, 충돌(conflict)이 발생하면 수동으로 해결한 후 커밋해야 하고, `--no-ff` 옵션은 fast-forward가 가능한 경우에도 항상 새로운 병합 커밋을 생성하여 브랜치 히스토리를 명확히 유지하며, `--squash` 옵션은 병합 대상 브랜치의 모든 커밋을 하나의 커밋으로 압축하여 병합한다.

```bash
git merge <브랜치명>
git merge --no-ff <브랜치명>  # 병합 커밋 생성
git merge --squash <브랜치명>  # 커밋 압축 병합
```

## 결론

Git은 2005년 Linus Torvalds에 의해 탄생한 이래로 소프트웨어 개발에서 사실상 표준 버전 관리 시스템으로 자리 잡았으며, Working Directory → Staging Area → Local Repository → Remote Repository의 4영역 구조를 이해하고 `init`, `add`, `commit`, `push`, `pull`, `branch`, `merge` 같은 핵심 명령어들을 숙달하면 개인 프로젝트와 팀 협업 모두에서 효율적인 코드 관리가 가능하고, `reset`, `revert`, `rebase` 같은 고급 기능까지 익히면 복잡한 개발 워크플로우에서도 유연하게 대처할 수 있다.
