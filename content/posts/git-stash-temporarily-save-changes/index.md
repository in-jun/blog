---
title: "Git stash 사용하기: 임시로 변경 사항을 저장하기 위한"
date: 2024-07-26T14:39:46+09:00
tags: ["git", "stash"]
draft: false
---

## 서론

Git은 분산 버전 관리 시스템(DVCS)으로, 프로젝트의 변경 이력을 관리하고 협업을 위한 다양한 기능을 제공한다. Git을 사용하다 보면, 작업 중에 다른 브랜치로 전환해야 하는 경우가 생길 수 있다. 이때 변경 사항을 커밋하지 않고 브랜치를 전환하면 아래와 같은 에러 메시지가 표시된다.

```bash
error: Your local changes to the following files would be overwritten by checkout:
        file.txt
Please commit your changes or stash them before you switch branches.
Aborting
```

해석을 해보면, `file.txt` 파일에 변경 사항이 있어서 브랜치를 전환할 수 없다는 것이다. 이런 경우 커밋을 하거나 변경 사항을 임시로 저장하는 방법이 있다. 이번 포스트에서는 Git stash를 사용하여 변경 사항을 임시로 저장하고, 다른 브랜치로 전환하는 방법에 대해 알아보겠다.

## Git stash란?

Git stash는 작업 디렉터리의 변경 사항을 임시로 저장하는 기능이다. 이를 통해 현재 작업 중인 내용을 커밋하지 않고도 다른 브랜치로 전환할 수 있다. stash는 변경 사항을 스택에 저장하며, 나중에 필요할 때 다시 적용할 수 있다.

## Git stash 사용법

### 1. 변경 사항 임시 저장하기

현재 작업 디렉터리의 변경 사항을 stash에 저장하려면 다음 명령어를 사용한다:

```bash
git stash
```

이 명령어를 실행하면 tracked 파일의 변경 사항이 stash에 저장되고 작업 디렉터리는 깨끗한 상태가 된다.

### 2. 저장된 stash 목록 확인하기

저장된 stash 목록을 확인하려면 다음 명령어를 사용한다:

```bash
git stash list
```

이 명령어는 저장된 stash들의 목록을 보여준다.

### 3. stash 적용하기

저장된 stash를 다시 적용하려면 다음 명령어를 사용한다:

```bash
git stash apply
```

이 명령어는 가장 최근에 저장한 stash를 적용한다. 특정 stash를 적용하고 싶다면 stash 이름을 지정할 수 있다:

```bash
git stash apply stash@{2}
```

### 4. stash 제거하기

적용한 stash를 제거하려면 다음 명령어를 사용한다:

```bash
git stash drop
```

특정 stash를 제거하려면 stash 이름을 지정할 수 있다:

```bash
git stash drop stash@{1}
```

모든 stash를 제거하려면 `clear` 명령어를 사용한다:

```bash
git stash clear
```

stash를 적용하고 동시에 제거하려면 `pop` 명령어를 사용할 수 있다:

```bash
git stash pop
```

## Git stash 활용 예시

1. 작업 중인 브랜치에서 긴급한 버그 수정이 필요한 경우:

    ```bash
    git stash
    git checkout bugfix-branch
    # 버그 수정 작업
    git checkout original-branch
    git stash pop
    ```

2. 깃 원격 저장소에서 변경 사항을 가져오는 경우:

    ```bash
    git stash
    git pull origin master
    git stash pop // 충돌이 발생할 경우 해결 후 다시 적용
    ```

3. 여러 개의 stash 관리하기:

    ```bash
    git stash save "작업 1 설명"
    git stash save "작업 2 설명"
    git stash list
    git stash apply stash@{1}
    ```

## 주의사항

1. untracked 파일은 기본적으로 stash에 포함되지 않는다. 이를 포함하려면 `-u` 옵션을 사용해야 한다:

    ```bash
    git stash -u
    ```

2. ignored 파일은 stash에 포함되지 않는다. 이를 포함하려면 `-a` 옵션을 사용해야 한다:

    ```bash
    git stash -a
    ```

3. stash는 브랜치에 종속되지 않는다. 따라서 어떤 브랜치에서도 적용할 수 있다.

4. 충돌이 발생할 수 있으므로, stash를 적용할 때는 주의가 필요하다.

## 결론

Git stash는 작업 중인 변경 사항을 임시로 저장하고 나중에 다시 적용할 수 있는 유용한 기능이다. 이를 통해 작업 흐름을 더욱 유연하게 관리할 수 있으며, 긴급한 작업이나 브랜치 전환 시 유용하게 사용할 수 있다. Git을 사용하는 개발자라면 stash 기능을 잘 활용하여 효율적인 작업 환경을 구축할 수 있을 것이다.
