---
title: "GitHub CLI로 Pull Request 관리하기"
date: 2024-07-19T00:39:08+09:00
tags: ["Git", "GitHub", "자동화"]
description: "GitHub CLI를 사용한 Pull Request 생성과 관리 방법을 다룬다."
draft: false
---

GitHub CLI(gh)는 GitHub에서 2020년 9월에 정식 출시한 공식 명령줄 인터페이스 도구로, 터미널에서 직접 GitHub의 핵심 기능들을 사용할 수 있게 해주며, 기존에 웹 브라우저를 통해 수행하던 Pull Request 생성, 이슈 관리, 저장소 관리 등의 작업을 명령어 한 줄로 처리할 수 있게 해준다. 특히 개발자들이 코드 작성과 버전 관리를 터미널에서 수행하는 경우가 많기 때문에, GitHub CLI를 활용하면 컨텍스트 스위칭 없이 일관된 워크플로우를 유지할 수 있고, 반복적인 작업을 자동화하여 생산성을 크게 향상시킬 수 있다.

## GitHub CLI 소개

> **GitHub CLI란?**
>
> GitHub의 공식 명령줄 도구로, 터미널에서 Pull Request, Issue, Repository, GitHub Actions 등 GitHub의 핵심 기능을 사용할 수 있게 해주며, REST API와 GraphQL API를 래핑하여 직관적인 명령어 인터페이스를 제공한다.

GitHub CLI는 기존의 `hub` 명령어를 대체하기 위해 개발되었으며, GitHub에서 직접 개발하고 유지보수하기 때문에 새로운 GitHub 기능이 출시될 때 빠르게 지원되고, Go 언어로 작성되어 다양한 플랫폼에서 단일 바이너리로 실행할 수 있으며, 오픈소스로 개발되어 커뮤니티의 기여를 받고 있다.

### 주요 이점

**효율성 향상**: 마우스와 웹 브라우저를 사용하지 않고 키보드만으로 GitHub 작업을 수행할 수 있어 개발 흐름이 끊기지 않고, IDE나 터미널에서 바로 PR을 생성하거나 리뷰할 수 있어 컨텍스트 스위칭 비용을 줄일 수 있다.

**자동화 지원**: 스크립트와 CI/CD 파이프라인에 GitHub 작업을 통합할 수 있어, 특정 조건에서 자동으로 PR을 생성하거나 라벨을 추가하거나 리뷰어를 지정하는 등의 워크플로우 자동화가 가능하며, JSON 출력을 지원하여 다른 도구와의 연동도 용이하다.

**일관된 인터페이스**: macOS, Linux, Windows 등 모든 플랫폼에서 동일한 명령어를 사용할 수 있어, 팀원 간에 일관된 워크플로우를 공유하고 문서화하기 쉬우며, 새로운 환경에서도 동일한 방식으로 작업할 수 있다.

**풍부한 기능**: PR과 Issue 관리뿐만 아니라 저장소 생성 및 복제, GitHub Actions 관리, Gist 생성, 릴리스 관리, Codespaces 접속 등 GitHub의 거의 모든 기능을 지원한다.

## GitHub CLI 설치

GitHub CLI의 설치 방법은 운영 체제에 따라 다르며, 각 플랫폼의 패키지 관리자를 통해 쉽게 설치할 수 있고, 설치 후 버전 확인을 통해 정상적으로 설치되었는지 확인할 수 있다.

### Linux (Ubuntu/Debian)

Ubuntu와 Debian 계열 리눅스에서는 apt 패키지 관리자를 통해 설치할 수 있으며, GitHub의 공식 패키지 저장소를 추가하면 최신 버전을 유지할 수 있다.

```bash
# GitHub CLI 패키지 저장소 추가
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# 설치
sudo apt update
sudo apt install gh
```

또는 간단하게 apt로 직접 설치할 수도 있다.

```bash
sudo apt update
sudo apt install gh
```

### macOS

macOS에서는 Homebrew를 통해 간단하게 설치할 수 있으며, Homebrew가 설치되어 있지 않다면 먼저 Homebrew를 설치해야 한다.

```bash
brew install gh
```

### Windows

Windows에서는 여러 가지 방법으로 설치할 수 있으며, winget, Chocolatey, Scoop 등의 패키지 관리자를 사용하거나 공식 설치 프로그램을 다운로드하여 설치할 수 있다.

```bash
# winget 사용
winget install --id GitHub.cli

# Chocolatey 사용
choco install gh

# Scoop 사용
scoop install gh
```

또는 [GitHub CLI 공식 사이트](https://cli.github.com/)에서 Windows용 설치 프로그램을 다운로드하여 설치할 수 있다.

### 설치 확인

설치가 완료되면 버전을 확인하여 정상적으로 설치되었는지 확인한다.

```bash
gh --version
# 출력 예시: gh version 2.40.0 (2024-01-15)
```

## GitHub CLI 인증

GitHub CLI를 사용하기 전에 GitHub 계정으로 인증해야 하며, 인증 과정은 브라우저 기반 OAuth 인증과 Personal Access Token 인증 두 가지 방식을 지원하고, 대부분의 경우 브라우저 기반 인증이 더 간편하고 안전하다.

### 인증 프로세스 시작

```bash
gh auth login
```

이 명령어를 실행하면 대화형 프롬프트가 나타나며, 다음 선택지를 제공한다.

1. **GitHub.com vs GitHub Enterprise Server**: 인증할 GitHub 인스턴스 선택
2. **HTTPS vs SSH**: 선호하는 프로토콜 선택
3. **브라우저 인증 vs 토큰 인증**: 인증 방식 선택

브라우저 인증을 선택하면 일회용 코드가 표시되고, 브라우저가 자동으로 열리며, GitHub 로그인 후 해당 코드를 입력하면 인증이 완료되고, 터미널로 돌아오면 인증 성공 메시지가 표시된다.

### 인증 상태 확인

현재 인증 상태와 연결된 계정 정보를 확인하려면 다음 명령어를 사용한다.

```bash
gh auth status
```

출력 예시는 다음과 같으며, 현재 로그인된 계정, 사용 중인 프로토콜, 토큰의 범위(scope) 등을 확인할 수 있다.

```
github.com
  ✓ Logged in to github.com as username (oauth_token)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ✓ Token scopes: gist, read:org, repo, workflow
```

### 추가 인증 옵션

여러 GitHub 계정을 사용하거나 GitHub Enterprise Server에도 인증해야 하는 경우, 추가 인증을 수행할 수 있다.

```bash
# GitHub Enterprise Server 인증
gh auth login --hostname github.mycompany.com

# 특정 범위(scope)로 인증
gh auth login --scopes "repo,read:org,workflow"

# Personal Access Token으로 인증
gh auth login --with-token < token.txt
```

## Pull Request 생성 워크플로우

PR을 생성하기 전에 로컬 저장소를 적절히 준비해야 하며, 브랜치 생성부터 푸시, PR 생성까지의 전체 워크플로우를 순서대로 살펴본다.

### 로컬 저장소 준비

**1. 작업할 저장소로 이동하고 최신 상태 동기화**

```bash
cd path/to/your/repository
git fetch origin
git pull origin main  # 또는 해당 기본 브랜치 이름
```

**2. 새 브랜치 생성 및 전환**

브랜치 이름은 작업 내용을 명확히 나타내도록 명명하며, 팀의 브랜치 네이밍 규칙을 따른다.

```bash
git checkout -b feature/user-authentication
# 또는 git switch -c feature/user-authentication
```

**3. 코드 변경 및 커밋**

필요한 변경 사항을 코드에 적용하고, 의미 있는 단위로 커밋한다.

```bash
git add .
git commit -m "feat: implement user authentication logic"
```

**4. 원격 저장소에 브랜치 푸시**

```bash
git push -u origin feature/user-authentication
```

`-u` 옵션은 upstream 브랜치를 설정하여 이후 `git push`와 `git pull` 명령어에서 브랜치 이름을 생략할 수 있게 해준다.

### PR 생성

로컬 저장소 준비가 완료되면 GitHub CLI로 PR을 생성할 수 있으며, 대화형 모드와 비대화형 모드 두 가지 방식을 지원한다.

**대화형 모드**

```bash
gh pr create
```

이 명령어를 실행하면 대화형 프롬프트가 나타나며 PR 제목, 본문, 대상 브랜치 등을 순차적으로 입력할 수 있고, 텍스트 편집기가 열려 상세한 PR 설명을 작성할 수 있다.

**비대화형 모드 (명령줄 옵션 사용)**

스크립트나 자동화에 적합한 방식으로, 모든 정보를 명령줄 옵션으로 제공한다.

```bash
gh pr create \
  --title "feat: implement user authentication" \
  --body "## Summary
- Add login/logout functionality
- Implement JWT token handling
- Add password validation

## Test Plan
- [ ] Unit tests for auth service
- [ ] Integration tests for login flow" \
  --base main \
  --assignee @me \
  --reviewer teammate1,teammate2 \
  --label "enhancement,auth"
```

### PR 생성 주요 옵션

| 옵션 | 축약형 | 설명 |
|------|--------|------|
| `--title` | `-t` | PR 제목 |
| `--body` | `-b` | PR 본문 (설명) |
| `--base` | `-B` | PR을 병합할 대상 브랜치 |
| `--head` | `-H` | PR의 소스 브랜치 |
| `--draft` | `-d` | 초안 PR로 생성 |
| `--assignee` | `-a` | PR에 할당할 사용자 (`@me`로 자신 지정 가능) |
| `--reviewer` | `-r` | 리뷰어 지정 (쉼표로 구분) |
| `--label` | `-l` | PR에 추가할 레이블 (쉼표로 구분) |
| `--milestone` | `-m` | PR과 연결할 마일스톤 |
| `--project` | `-p` | PR을 추가할 프로젝트 |
| `--web` | `-w` | PR 생성 후 웹 브라우저에서 열기 |

### 실용적인 PR 생성 예시

```bash
# 초안 PR 생성 (아직 리뷰 준비가 안 된 경우)
gh pr create --draft --title "WIP: refactor payment module"

# 자신을 할당하고 특정 팀을 리뷰어로 지정
gh pr create --assignee @me --reviewer myorg/backend-team

# 웹에서 PR 페이지 열기
gh pr create --web

# 본문을 파일에서 읽어오기
gh pr create --title "Release v2.0.0" --body-file CHANGELOG.md
```

## PR 관리

PR을 생성한 후에도 GitHub CLI를 사용하여 다양한 관리 작업을 수행할 수 있으며, 목록 조회, 상세 정보 확인, 체크아웃, 상태 모니터링 등의 기능을 제공한다.

### PR 목록 조회

현재 저장소의 PR 목록을 조회하며, 다양한 필터 옵션을 사용하여 원하는 PR만 필터링할 수 있다.

```bash
# 열린 PR 목록 (기본)
gh pr list

# 모든 상태의 PR 목록
gh pr list --state all

# 자신에게 할당된 PR
gh pr list --assignee @me

# 특정 레이블의 PR
gh pr list --label bug

# 복합 필터
gh pr list --assignee @me --label "bug,urgent" --state open

# 특정 브랜치를 대상으로 하는 PR
gh pr list --base main

# 최근 10개만 표시
gh pr list --limit 10
```

출력 형식을 JSON으로 변경하여 스크립트에서 활용할 수도 있다.

```bash
gh pr list --json number,title,author,state
```

### PR 상세 정보 조회

특정 PR의 상세 정보를 터미널에서 확인할 수 있으며, PR 번호를 지정하거나 현재 브랜치의 PR을 조회할 수 있다.

```bash
# 특정 PR 조회
gh pr view 123

# 현재 브랜치의 PR 조회
gh pr view

# 웹 브라우저에서 열기
gh pr view 123 --web

# JSON 형식으로 특정 필드만 조회
gh pr view 123 --json title,body,state,reviews
```

### PR 체크아웃

다른 사람의 PR을 로컬에서 테스트하거나 리뷰하기 위해 체크아웃할 수 있으며, 이 기능은 코드 리뷰 시 로컬에서 실행해보고 싶을 때 매우 유용하다.

```bash
# PR 번호로 체크아웃
gh pr checkout 123

# 체크아웃 후 원래 브랜치로 돌아가기
git checkout -
```

### PR 상태 모니터링

자신과 관련된 PR들의 현재 상태를 한눈에 확인할 수 있으며, 생성한 PR, 리뷰 요청받은 PR, 언급된 PR 등을 구분하여 보여준다.

```bash
gh pr status
```

출력 예시는 다음과 같다.

```
Relevant pull requests in owner/repo

Created by you
  #123  feat: add user auth [feature/auth]
    - Checks passing - Review required

Requesting a code review from you
  #456  fix: resolve memory leak [bugfix/memory]
    - Checks passing - Changes requested

Involving you
  #789  docs: update API documentation [docs/api]
    - Checks failing
```

### CI 체크 상태 확인

PR의 CI/CD 파이프라인 실행 상태를 확인할 수 있으며, 각 체크의 성공/실패 여부와 상세 정보를 볼 수 있다.

```bash
# CI 체크 상태 확인
gh pr checks 123

# 체크가 완료될 때까지 대기
gh pr checks 123 --watch

# 실패한 체크만 표시
gh pr checks 123 --fail-only
```

## PR 리뷰

GitHub CLI를 사용하면 터미널에서 PR 리뷰 전 과정을 수행할 수 있으며, 변경 사항 확인, 코멘트 작성, 승인 또는 변경 요청까지 모든 작업이 가능하다.

### 리뷰어 지정

PR에 리뷰어를 추가하거나 제거할 수 있으며, 개인 사용자와 팀 모두 지정할 수 있다.

```bash
# 리뷰어 추가
gh pr edit 123 --add-reviewer username1,username2

# 팀을 리뷰어로 지정
gh pr edit 123 --add-reviewer myorg/frontend-team

# 리뷰어 제거
gh pr edit 123 --remove-reviewer username1

# 현재 브랜치의 PR에 리뷰어 추가
gh pr edit --add-reviewer username1
```

### 변경 사항 확인

PR의 diff를 터미널에서 직접 확인할 수 있으며, 색상 하이라이팅이 적용되어 변경 내용을 쉽게 파악할 수 있다.

```bash
# PR의 diff 확인
gh pr diff 123

# 특정 파일의 diff만 확인 (파이프와 grep 활용)
gh pr diff 123 | grep -A 20 "filename.js"
```

### 리뷰 제출

리뷰를 제출할 때는 승인(approve), 변경 요청(request-changes), 코멘트(comment) 세 가지 유형 중 선택할 수 있다.

```bash
# 승인
gh pr review 123 --approve --body "코드 검토 완료, 잘 작성되었습니다."

# 변경 요청
gh pr review 123 --request-changes --body "다음 부분을 수정해주세요:
- 에러 핸들링 추가 필요
- 테스트 커버리지 부족"

# 코멘트만 남기기 (승인/거절 없이)
gh pr review 123 --comment --body "몇 가지 제안사항이 있습니다..."

# 대화형 모드로 리뷰 (편집기가 열림)
gh pr review 123
```

### 코멘트 작성

PR 전체에 대한 코멘트를 작성할 수 있으며, 리뷰와 별개로 일반 코멘트를 남길 때 사용한다.

```bash
# PR에 코멘트 추가
gh pr comment 123 --body "빌드 테스트 완료했습니다. 문제없이 동작합니다."

# 편집기를 열어 코멘트 작성
gh pr comment 123 --editor
```

## PR 병합

리뷰가 완료되고 모든 요구 사항이 충족되면 PR을 병합할 수 있으며, GitHub CLI는 세 가지 병합 전략을 지원하고 병합 후 브랜치 삭제 옵션도 제공한다.

### 병합 명령어

```bash
# 대화형 모드 (병합 전략 선택)
gh pr merge 123

# 일반 병합 (merge commit 생성)
gh pr merge 123 --merge

# 스쿼시 병합 (모든 커밋을 하나로 합침)
gh pr merge 123 --squash

# 리베이스 병합 (커밋을 대상 브랜치 위에 재적용)
gh pr merge 123 --rebase
```

### 병합 옵션

```bash
# 병합 후 소스 브랜치 삭제
gh pr merge 123 --squash --delete-branch

# 모든 체크가 통과할 때까지 대기 후 자동 병합
gh pr merge 123 --auto --squash

# 병합 커밋 메시지 지정
gh pr merge 123 --merge --subject "feat: user authentication (#123)"

# 병합 커밋 본문 지정
gh pr merge 123 --merge --body "Closes #100, #101"
```

### 자동 병합 활성화

`--auto` 옵션을 사용하면 필수 리뷰와 CI 체크가 모두 통과할 때 자동으로 병합되며, 이 기능은 저장소 설정에서 자동 병합이 활성화되어 있어야 사용할 수 있다.

```bash
# 자동 병합 활성화
gh pr merge 123 --auto --squash --delete-branch

# 자동 병합 비활성화
gh pr merge 123 --disable-auto
```

## PR 수정 및 업데이트

생성된 PR의 제목, 본문, 레이블, 마일스톤 등을 수정할 수 있으며, `gh pr edit` 명령어를 사용한다.

```bash
# 제목 수정
gh pr edit 123 --title "feat: implement user authentication v2"

# 본문 수정
gh pr edit 123 --body "Updated description..."

# 레이블 추가/제거
gh pr edit 123 --add-label "priority:high" --remove-label "priority:low"

# 마일스톤 설정
gh pr edit 123 --milestone "v2.0"

# 프로젝트에 추가
gh pr edit 123 --add-project "Sprint 5"

# 초안 상태 변경
gh pr ready 123  # 초안에서 리뷰 준비 완료로 변경
```

## 고급 기능 및 자동화

### 별칭(Alias) 설정

자주 사용하는 명령어 조합에 별칭을 설정하여 생산성을 높일 수 있으며, 팀 전체에서 동일한 별칭을 공유하면 일관된 워크플로우를 유지할 수 있다.

```bash
# 별칭 생성
gh alias set prc 'pr create --draft --assignee @me'
gh alias set prv 'pr view --web'
gh alias set prs 'pr status'
gh alias set prm 'pr merge --squash --delete-branch'

# 별칭 사용
gh prc  # 초안 PR 생성하고 자신 할당
gh prv  # 웹에서 PR 보기
gh prs  # PR 상태 확인
gh prm 123  # 스쿼시 병합 후 브랜치 삭제

# 별칭 목록 확인
gh alias list

# 별칭 삭제
gh alias delete prc
```

### JSON 출력 활용

스크립트나 다른 도구와 연동할 때 JSON 출력을 활용할 수 있으며, `jq`와 같은 JSON 처리 도구와 결합하면 강력한 자동화가 가능하다.

```bash
# 특정 필드만 JSON으로 출력
gh pr view 123 --json number,title,state,author,reviews

# jq로 특정 값 추출
gh pr view 123 --json title --jq '.title'

# 열린 PR들의 번호만 추출
gh pr list --json number --jq '.[].number'

# 리뷰 승인된 PR만 필터링
gh pr list --json number,reviews --jq '.[] | select(.reviews | any(.state == "APPROVED")) | .number'
```

### PR 템플릿 활용

저장소에 `.github/PULL_REQUEST_TEMPLATE.md` 파일을 생성하면 PR 생성 시 자동으로 템플릿 내용이 PR 본문에 채워지며, 여러 템플릿을 사용하려면 `.github/PULL_REQUEST_TEMPLATE/` 디렉토리에 여러 마크다운 파일을 생성하고 `--template` 옵션으로 선택할 수 있다.

```bash
# 특정 템플릿 사용
gh pr create --template bug_fix.md
```

### GitHub Actions와 연동

CI/CD 파이프라인에서 GitHub CLI를 활용하여 자동화된 PR 워크플로우를 구축할 수 있으며, GitHub Actions 환경에서는 `GITHUB_TOKEN`이 자동으로 설정되어 별도의 인증 없이 사용할 수 있다.

```yaml
# .github/workflows/auto-pr.yml 예시
name: Auto PR
on:
  push:
    branches:
      - 'feature/**'

jobs:
  create-pr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create PR
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr create --title "Auto PR: ${GITHUB_REF_NAME}" \
                       --body "Automated PR for feature branch" \
                       --base main
```

### 설정 파일

`~/.config/gh/config.yml` 파일을 통해 GitHub CLI의 기본 설정을 구성할 수 있으며, 기본 편집기, 프로토콜, 별칭 등을 설정할 수 있다.

```yaml
# ~/.config/gh/config.yml 예시
git_protocol: ssh
editor: vim
prompt: enabled
pager: less
aliases:
  prc: pr create --draft --assignee @me
  prv: pr view --web
```

## 유용한 팁

**웹 브라우저로 빠르게 열기**: PR을 웹 브라우저에서 확인하고 싶을 때 `--web` 옵션을 사용하면 해당 PR 페이지가 바로 열린다.

```bash
gh pr view 123 --web
gh pr create --web
```

**현재 브랜치 기반 작업**: PR 번호를 지정하지 않으면 현재 체크아웃된 브랜치의 PR에 대해 작업한다.

```bash
gh pr view      # 현재 브랜치의 PR 보기
gh pr edit      # 현재 브랜치의 PR 수정
gh pr merge     # 현재 브랜치의 PR 병합
```

**GitHub CLI 업데이트**: 새로운 기능과 버그 수정을 받으려면 정기적으로 업데이트한다.

```bash
# macOS
brew upgrade gh

# Linux
sudo apt update && sudo apt upgrade gh
```

## 결론

GitHub CLI는 터미널에서 GitHub 작업을 효율적으로 수행할 수 있게 해주는 강력한 도구로, PR 생성부터 리뷰, 병합까지 전체 워크플로우를 명령어 한 줄로 처리할 수 있으며, 자동화와 스크립팅을 통해 반복 작업을 줄이고 생산성을 높일 수 있다. 특히 키보드 중심의 워크플로우를 선호하는 개발자에게 매우 유용하며, 팀 전체에서 일관된 PR 프로세스를 유지하는 데도 도움이 된다.
