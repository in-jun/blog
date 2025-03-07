---
title: "GitHub CLI로 풀 리퀘스트(PR) 보내기"
date: 2024-07-19T00:39:08+09:00
tags: ["github", "cli", "pr"]
draft: false
---

GitHub CLI를 사용하여 풀 리퀘스트(PR)를 보내는 방법에 대해 상세히 설명하겠다. GitHub CLI는 터미널에서 직접 GitHub 작업을 수행할 수 있게 해주는 도구로, GUI 인터페이스를 거치지 않고도 효율적으로 작업할 수 있다.

## 1. GitHub CLI 소개

GitHub CLI(`gh`)는 GitHub의 공식 명령줄 도구로, 터미널에서 GitHub의 대부분 기능을 사용할 수 있게 해 준다. 이 도구의 주요 이점은 다음과 같다:

-   **효율성**: 마우스를 사용하지 않고 키보드만으로 GitHub 작업을 수행할 수 있다.
-   **자동화**: 스크립트에 GitHub 작업을 통합할 수 있다.
-   **일관성**: 모든 플랫폼에서 동일한 명령어를 사용할 수 있다.

## 2. GitHub CLI 설치

GitHub CLI의 설치 방법은 운영 체제에 따라 다르다. 주요 플랫폼별 설치 방법은 다음과 같다.

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install gh
```

### macOS

```bash
brew install gh
```

### Windows

Windows 사용자는 [GitHub CLI의 설치 페이지](https://cli.github.com/)에서 설치 프로그램을 다운로드하여 설치할 수 있다.

설치가 완료되면 버전을 확인하여 설치가 제대로 되었는지 확인할 수 있다:

```bash
gh --version
```

## 3. GitHub CLI 인증

GitHub CLI를 사용하기 전에 GitHub 계정으로 인증해야 한다. 다음 명령어로 인증 프로세스를 시작할 수 있다:

```bash
gh auth login
```

브라우저를 통한 인증을 선택하면, 브라우저 창이 열리고 GitHub 로그인을 요청한다. 로그인 후 CLI로 돌아와 인증이 완료된다.

인증이 성공적으로 완료되었는지 확인하려면:

```bash
gh auth status
```

이 명령어는 현재 인증 상태와 연결된 계정 정보를 보여준다.

## 4. 로컬 저장소 준비

PR을 생성하기 전에 로컬 저장소를 준비해야 한다. 다음 단계를 따라야 한다:

1. **작업할 저장소로 이동**:

    ```bash
    cd path/to/your/repository
    ```

2. **최신 변경 사항을 가져오기**:

    ```bash
    git fetch origin
    git pull origin main # 또는 해당하는 기본 브랜치 이름
    ```

3. **새 브랜치 생성 및 전환**:

    ```bash
    git checkout -b feature/new-feature
    ```

4. **변경 사항 만들기**: 필요한 변경 사항을 코드에 적용한다.

5. **변경 사항을 스테이징하고 커밋하기**:

    ```bash
    git add .
    git commit -m "feat: add new feature"
    ```

6. **원격 저장소에 새 브랜치 푸시하기**:

    ```bash
    git push -u origin feature/new-feature
    ```

## 5. PR 생성

이제 PR을 생성할 준비가 되었다. GitHub CLI를 사용하여 PR을 생성하는 방법은 다음과 같다:

```bash
gh pr create
```

이 명령어를 실행하면 대화형 프롬프트가 나타나며 다음 정보를 입력해야 한다:

1. PR의 제목
2. PR의 본문 (설명)
3. PR을 보낼 대상 브랜치 (일반적으로 `main` 또는 `master`)

또는 명령줄 옵션을 사용하여 이 정보를 직접 제공할 수도 있다:

```bash
gh pr create --title "새로운 기능 추가" --body "이 PR은 XXX 기능을 추가합니다." --base main
```

주요 옵션:

-   `--title`, `-t`: PR의 제목
-   `--body`, `-b`: PR의 본문
-   `--base`: PR을 병합할 대상 브랜치
-   `--draft`: 초안 PR으로 생성
-   `--assignee`, `-a`: PR에 할당할 사용자
-   `--label`, `-l`: PR에 추가할 레이블
-   `--milestone`, `-m`: PR과 연결할 마일스톤

예를 들어, 초안 PR을 생성하고 자신을 할당하려면:

```bash
gh pr create --draft --assignee @me
```

## 6. PR 관리

PR을 생성한 후에도 GitHub CLI를 사용하여 다양한 관리 작업을 수행할 수 있다.

### PR 목록 보기

현재 저장소의 열린 PR 목록을 보려면:

```bash
gh pr list
```

다양한 필터 옵션을 사용할 수 있다:

```bash
gh pr list --assignee @me --label bug --state all
```

이는 자신에게 할당된, 'bug' 레이블이 붙은 모든 상태(열림/닫힘)의 PR을 보여준다.

### PR 세부 정보 보기

특정 PR의 세부 정보를 보려면:

```bash
gh pr view <PR-number>
```

현재 브랜치의 PR을 보려면:

```bash
gh pr view
```

### PR 체크아웃

리뷰를 위해 특정 PR을 로컬로 체크아웃하려면:

```bash
gh pr checkout <PR-number>
```

### PR 리뷰어 지정

PR에 리뷰어를 지정하는 것은 코드 리뷰 프로세스의 중요한 부분이다. GitHub CLI를 사용하여 리뷰어를 쉽게 지정할 수 있다:

```bash
gh pr edit <PR-number> --add-reviewer username1,username2
```

여러 리뷰어를 한 번에 지정할 수 있으며, 쉼표로 구분한다. 팀을 리뷰어로 지정하려면 팀 이름 앞에 조직 이름을 붙인다:

```bash
gh pr edit <PR-number> --add-reviewer org-name/team-name
```

현재 작업 중인 브랜치의 PR에 리뷰어를 추가하려면 PR 번호를 생략할 수 있다:

```bash
gh pr edit --add-reviewer username1,username2
```

### PR 리뷰 수행

리뷰어로 지정되면 GitHub CLI를 사용하여 PR을 리뷰할 수 있다. 리뷰 과정은 다음과 같다:

1. **PR 내용 확인**:

    ```bash
    gh pr view <PR-number>
    ```

2. **변경 사항 검토**:

    ```bash
    gh pr diff <PR-number>
    ```

3. **리뷰 제출**:

    ```bash
    gh pr review <PR-number>
    ```

    이 명령을 실행하면 리뷰 내용을 입력할 수 있는 텍스트 편집기가 열린다.

리뷰 시 다양한 옵션을 사용할 수 있다:

-   **승인**:

    ```bash
    gh pr review <PR-number> --approve -b "변경 사항을 검토했으며 승인합니다."
    ```

-   **변경 요청**:

    ```bash
    gh pr review <PR-number> --request-changes -b "다음 부분을 수정해 주세요: ..."
    ```

-   **코멘트만 남기기**:

    ```bash
    gh pr review <PR-number> --comment -b "몇 가지 제안사항이 있습니다: ..."
    ```

### PR 승인 및 병합

리뷰 과정이 완료되고 모든 요구 사항이 충족되면 PR을 승인하고 병합할 수 있다.

PR 승인:

```bash
gh pr review <PR-number> --approve
```

승인 후 PR 병합:

```bash
gh pr merge <PR-number>
```

병합 시 다양한 옵션을 사용할 수 있다:

```bash
gh pr merge <PR-number> --merge # 일반 병합
gh pr merge <PR-number> --squash # 스쿼시 병합
gh pr merge <PR-number> --rebase # 리베이스 병합
```

자동으로 브랜치를 삭제하려면 `--delete-branch` 옵션을 추가한다:

```bash
gh pr merge <PR-number> --squash --delete-branch
```

### PR 상태 모니터링

PR의 현재 상태, 리뷰 진행 상황, CI 체크 등을 확인하려면:

```bash
gh pr status
```

이 명령어는 현재 작업 중인 PR, 리뷰해야 할 PR, 승인을 기다리는 PR 등의 정보를 보여준다.

특정 PR의 CI 체크 상태를 자세히 보려면:

```bash
gh pr checks <PR-number>
```

이렇게 하면 모든 CI 작업의 상태와 결과를 볼 수 있다.

## 7. 고급 사용법

### 템플릿 사용

PR 생성 시 템플릿을 사용하여 일관된 형식을 유지할 수 있다. 저장소에 `.github/PULL_REQUEST_TEMPLATE.md` 파일을 생성하고 PR 템플릿을 정의하면 된다. 템플릿 파일을 작성하면 PR 생성 시 자동으로 템플릿 내용이 PR 설명란에 채워진다.

### CI 상태 확인

PR의 CI 상태를 확인하려면:

```bash
gh pr checks <PR-number>
```

여기서 CI 상태를 자세히 확인하고, 실패한 체크에 대한 정보를 받을 수 있다.

### PR 자동화

GitHub Actions와 GitHub CLI를 결합하여 PR 프로세스를 자동화할 수 있다. 예를 들어, 특정 조건에서 자동으로 PR을 생성하거나 리뷰어를 할당할 수 있다. GitHub Actions를 사용하여 PR 생성, 리뷰어 추가, 상태 업데이트 등을 자동으로 수행할 수 있다.

## 8. 팁과 트릭

1. **별칭 사용**: 자주 사용하는 명령어에 대해 별칭을 만들어 사용하면 편리하다. 예를 들어, 초안 PR을 생성하고 자신을 할당하는 명령어에 별칭을 만들어 사용할 수 있다:

    ```bash
    gh alias set prc 'pr create --draft --assignee @me'
    ```

    이제 `gh prc`만으로 초안 PR을 생성하고 자신을 할당할 수 있다.

2. **설정 파일 활용**: `~/.config/gh/config.yml` 파일을 통해 GitHub CLI의 기본 설정을 구성할 수 있다. 이 파일에서 기본 저장소 설정, 기본 브랜치 설정 등을 할 수 있다.

3. **JSON 출력**: 스크립트에서 사용하기 위해 JSON 형식으로 출력을 할 수 있다.

    ```bash
    gh pr view <PR-number> --json number,title,state
    ```

    이렇게 하면 JSON 형식으로 PR의 세부 정보를 받아서 스크립트나 프로그램에서 처리할 수 있다.

4. **웹 브라우저 열기**: CLI에서 직접 PR을 웹 브라우저로 열 수 있다.

    ```bash
    gh pr view <PR-number> --web
    ```

5. **GitHub CLI 업데이트**: 새로운 기능과 버그 수정을 받으려면 정기적으로 GitHub CLI를 업데이트하면 된다.

    ```bash
    gh release upgrade
    ```

## 9. 결론

이제 GitHub CLI를 사용하여 풀 리퀘스트(PR)를 보내는 방법을 알게 되었다. GitHub CLI를 사용하면 터미널에서 직접 GitHub 작업을 수행할 수 있어 효율적으로 작업할 수 있다. PR을 생성하고 관리하는 방법을 익히고, GitHub CLI의 다양한 기능을 활용하여 개발 프로세스를 더욱 효율적으로 개선하자.
