---
title: "Git 기본부터 고급 기능까지"
date: 2024-07-08T20:52:04+09:00
tags: ["Git", "버전관리"]
description: "Git의 기본 개념과 고급 기능을 다룬다."
draft: false
---

## Git의 역사와 탄생 배경

Git은 2005년 리눅스 커널의 창시자인 Linus Torvalds가 개발한 분산 버전 관리 시스템(Distributed Version Control System, DVCS)이다. 당시 리눅스 커널 개발에 사용하던 상용 DVCS인 BitKeeper의 무료 사용권이 철회되면서 대안이 필요해졌고, Torvalds는 기존 버전 관리 시스템의 단점인 느린 속도와 비효율적인 브랜칭을 개선한 새 시스템을 단 2주 만에 만들었다. 이렇게 탄생한 Git의 첫 버전은 2005년 4월 7일 공개되었으며, 대규모 프로젝트에서도 빠르게 동작하고 완전한 분산 환경을 지원하도록 설계되었다.

Git이라는 이름은 영국 속어로 "불쾌한 사람"을 뜻한다. Torvalds는 Linux처럼 Git도 자신의 성격을 빗대어 붙인 이름이라고 농담처럼 설명했으며, 공식 매뉴얼에서는 "Global Information Tracker(전역 정보 추적기)"의 약자라고도 소개한다.

## Git의 4영역 구조

Git은 Working Directory(작업 디렉터리), Staging Area(스테이징 영역), Local Repository(로컬 저장소), Remote Repository(원격 저장소)의 네 가지 영역으로 구성된다. Working Directory는 실제 파일을 작성하고 수정하는 공간이고, Staging Area(또는 Index)는 다음 커밋에 포함될 변경 사항이 잠시 머무는 중간 영역이다. Local Repository는 `.git` 디렉터리에 저장되는 커밋 데이터베이스이며, Remote Repository는 GitHub, GitLab, Bitbucket 같은 서버에 위치한 공유 저장소다. 이 네 영역 사이의 흐름을 이해하면 Git 명령어가 어떻게 동작하는지 더 쉽게 파악할 수 있다.

## 저장소 초기화: git init

`git init`은 현재 디렉터리를 새로운 Git 저장소로 초기화할 때 사용한다. 실행하면 `.git`이라는 숨김 디렉터리가 생성되고, Git은 여기에 객체 데이터베이스, 참조 정보, 설정 파일 같은 버전 관리 메타데이터를 저장한다. 기존 프로젝트를 Git으로 관리하기 시작할 때나 완전히 새로운 프로젝트를 만들 때 가장 먼저 실행하는 명령어다.

```bash
git init
```

## 상태 확인: git status

`git status`는 Working Directory와 Staging Area의 현재 상태를 확인할 때 가장 자주 쓰는 명령어다. 어떤 파일이 수정되었는지, 어떤 파일이 스테이징되어 커밋을 기다리는지, 어떤 파일이 아직 추적되지 않는 새 파일인지 한눈에 보여준다. `-s` 또는 `--short` 옵션을 사용하면 간략한 형식으로 출력하고, `-b` 또는 `--branch` 옵션을 추가하면 현재 브랜치 정보도 함께 표시한다.

```bash
git status
git status -sb  # 간략한 형식 + 브랜치 정보
```

## 파일 스테이징: git add

`git add`는 Working Directory의 변경 사항을 Staging Area에 올려 다음 커밋을 준비하는 명령어다. 특정 파일만 스테이징하려면 `git add <파일명>`을, 현재 디렉터리의 모든 변경 사항을 스테이징하려면 `git add .`을 사용한다. `-p` 옵션을 사용하면 각 변경 사항을 hunk 단위로 대화형 검토하면서 선택적으로 스테이징할 수 있어, 하나의 파일에 섞인 여러 논리적 변경 사항을 별도 커밋으로 나눌 때 유용하다. `-u` 옵션은 이미 추적 중인 파일의 변경 사항만 스테이징한다.

```bash
git add <파일명>
git add .
git add -p  # 대화형 스테이징
```

## 스테이징 취소: git restore

Git 2.23.0(2019년 8월)에서 도입된 `git restore`는 파일 상태를 복원할 때 사용한다. `--staged` 옵션과 함께 쓰면 Staging Area에 올린 변경 사항을 취소하고 Working Directory의 수정 상태로 되돌린다. 옵션 없이 사용하면 Working Directory의 수정 사항을 마지막 커밋 상태로 복원한다. 이전 버전의 Git에서는 같은 작업을 `git reset HEAD <파일명>`으로 수행했다.

```bash
git restore --staged <파일명>  # 스테이징 취소
git restore <파일명>  # 워킹 디렉터리 변경 취소
```

## 변경 사항 커밋: git commit

`git commit`은 Staging Area에 있는 변경 사항을 Local Repository에 새로운 커밋(스냅샷)으로 기록한다. `-m` 옵션을 사용하면 커밋 메시지를 인라인으로 작성할 수 있고, 옵션 없이 실행하면 설정된 텍스트 편집기가 열려 더 자세한 메시지를 작성할 수 있다. `-a` 옵션은 이미 추적 중인 모든 파일의 변경 사항을 자동으로 스테이징한 뒤 커밋하므로 `git add`와 `git commit`을 한 번에 수행할 수 있다. `--amend` 옵션은 마지막 커밋 메시지를 수정하거나 누락된 변경 사항을 추가할 때 사용한다.

```bash
git commit -m "feat: 로그인 기능 구현"
git commit -am "fix: 버그 수정"  # add + commit
git commit --amend  # 마지막 커밋 수정
```

## 커밋 취소: git reset과 git revert

`git reset`은 커밋을 취소하고 HEAD 포인터를 이전 커밋으로 이동시키는 명령어다. `--soft` 옵션은 커밋만 취소하고 변경 사항을 Staging Area에 유지하며, `--mixed` 옵션(기본값)은 커밋을 취소하고 변경 사항을 Working Directory로 되돌린다. `--hard` 옵션은 커밋과 함께 변경 사항까지 완전히 삭제하므로 주의해서 사용해야 한다. `HEAD^`는 바로 이전 커밋을, `HEAD~3`은 세 개 이전 커밋을 가리킨다.

```bash
git reset --soft HEAD^   # 커밋 취소, 스테이징 유지
git reset HEAD^          # 커밋 취소, 워킹 디렉터리로
git reset --hard HEAD^   # 커밋 취소, 변경 삭제
```

`git revert`는 특정 커밋의 변경 사항을 되돌리는 새 커밋을 만든다. 이미 원격 저장소에 푸시된 커밋을 안전하게 취소할 때 주로 사용하며, `reset`과 달리 히스토리를 유지한 채 변경 사항을 되돌리기 때문에 협업 환경에서 권장된다.

```bash
git revert <커밋 해시>
```

## 커밋 히스토리 확인: git log

`git log`는 프로젝트의 커밋 히스토리를 최신순으로 보여준다. 각 커밋의 해시, 작성자, 날짜, 커밋 메시지를 확인할 수 있으며, `--oneline` 옵션은 각 커밋을 한 줄로 간략하게 표시한다. `--graph` 옵션은 브랜치와 머지 히스토리를 ASCII 그래프로 시각화하고, `--stat` 옵션은 각 커밋에서 변경된 파일의 통계를 보여준다. `--all` 옵션을 추가하면 모든 브랜치의 히스토리를 함께 볼 수 있다.

```bash
git log
git log --oneline --graph --all  # 전체 브랜치 그래프
git log --stat  # 변경 파일 통계
```

## 원격 저장소 관리: git remote

`git remote`는 로컬 저장소와 연결된 원격 저장소를 관리할 때 사용한다. `add` 서브 명령어로 새 원격 저장소를 추가하고, `remove`로 연결을 제거하며, `set-url`로 기존 원격 저장소의 URL을 변경할 수 있다. `-v` 옵션은 등록된 원격 저장소의 이름과 URL을 자세히 보여주며, 관례적으로 주 원격 저장소 이름은 `origin`을 사용한다.

```bash
git remote add origin <URL>
git remote -v  # 원격 저장소 목록
git remote set-url origin <새 URL>
```

## 원격 저장소 동기화: git push와 git pull

`git push`는 Local Repository의 커밋을 Remote Repository로 업로드할 때 사용한다. 반대로 `git pull`은 Remote Repository의 변경 사항을 가져와 현재 브랜치에 병합한다. push 시 `--force` 옵션은 원격 브랜치를 강제로 덮어쓰므로 협업 환경에서는 특히 주의해야 한다. pull 시 `--rebase` 옵션을 사용하면 병합 대신 리베이스를 수행해 더 깔끔한 히스토리를 유지할 수 있다.

```bash
git push origin main
git pull origin main
git pull --rebase origin main  # 리베이스 방식
```

## 브랜치 관리: git branch와 브랜치 전환 명령어

`git branch`는 브랜치를 생성, 조회, 삭제할 때 사용한다. 인자 없이 실행하면 로컬 브랜치 목록을 보여주고, `<브랜치명>`을 인자로 주면 새 브랜치를 만든다. `-d` 옵션은 병합된 브랜치를 삭제하고 `-D` 옵션은 병합 여부와 관계없이 강제로 삭제한다.

`git checkout`은 브랜치를 전환하거나 특정 커밋으로 이동할 때 사용한다. `-b` 옵션과 함께 쓰면 새 브랜치를 만들고 즉시 전환할 수 있다. Git 2.23.0부터는 브랜치 전환 전용으로 `git switch`도 사용할 수 있다.

```bash
git branch  # 브랜치 목록
git branch <브랜치명>  # 브랜치 생성
git checkout <브랜치명>  # 브랜치 전환
git checkout -b <브랜치명>  # 생성 + 전환
git switch <브랜치명>  # 브랜치 전환 (Git 2.23+)
```

## 브랜치 병합: git merge

`git merge`는 지정한 브랜치의 변경 사항을 현재 브랜치에 통합한다. Git은 두 브랜치의 공통 조상 커밋을 찾아 3-way merge를 수행하며, 충돌(conflict)이 발생하면 수동으로 해결한 뒤 커밋해야 한다. `--no-ff` 옵션은 fast-forward가 가능한 경우에도 항상 새로운 병합 커밋을 만들어 브랜치 히스토리를 더 명확하게 남긴다. `--squash` 옵션은 병합 대상 브랜치의 모든 커밋을 하나의 커밋으로 압축해 병합한다.

```bash
git merge <브랜치명>
git merge --no-ff <브랜치명>  # 병합 커밋 생성
git merge --squash <브랜치명>  # 커밋 압축 병합
```

## 결론

Git은 2005년 Linus Torvalds에 의해 탄생한 뒤, 소프트웨어 개발의 사실상 표준 버전 관리 시스템으로 자리 잡았다. Working Directory → Staging Area → Local Repository → Remote Repository로 이어지는 4영역 구조를 이해하고 `init`, `add`, `commit`, `push`, `pull`, `branch`, `merge` 같은 핵심 명령어를 익히면 개인 프로젝트와 팀 협업 모두에서 효율적으로 코드를 관리할 수 있다. 여기에 `reset`, `revert`, `rebase` 같은 고급 기능까지 익히면 더 복잡한 개발 워크플로우에도 유연하게 대응할 수 있다.
