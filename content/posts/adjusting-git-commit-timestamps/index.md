---
title: "Git 커밋 시간 조정하기"
date: 2024-05-25T23:31:13+09:00
tags: ["git", "commit", "timestamp", "version-control"]
description: "Git 커밋은 AuthorDate와 CommitDate 두 가지 타임스탬프를 가지며, --date 옵션으로 새 커밋 시간 지정, --amend로 마지막 커밋 수정, interactive rebase로 과거 커밋 조정이 가능하다"
draft: false
---

## Git 타임스탬프의 구조

Git의 타임스탬프 시스템은 2005년 Linus Torvalds가 Git을 설계할 때부터 두 가지 시간을 별도로 기록하도록 설계되었으며, 이는 Linux 커널 개발의 특성상 패치를 작성한 시간과 실제로 커밋된 시간이 다를 수 있기 때문이었다.

### AuthorDate와 CommitDate

Git 커밋은 두 가지 타임스탬프를 가진다.

**AuthorDate**는 코드를 처음 작성한 시간, 즉 원저자가 변경을 만든 시간을 나타내며, `git commit --date` 옵션이나 `GIT_AUTHOR_DATE` 환경변수로 설정된다.

**CommitDate**는 커밋이 실제로 저장소에 기록된 시간을 나타내며, rebase, cherry-pick, amend 등으로 커밋이 재생성될 때마다 갱신되고, `GIT_COMMITTER_DATE` 환경변수로 설정할 수 있다.

```bash
# 두 타임스탬프 모두 확인
git log --format=fuller

# 출력 예시
# commit abc1234
# Author:     홍길동 <hong@example.com>
# AuthorDate: Sat May 25 14:30:00 2024 +0900
# Commit:     홍길동 <hong@example.com>
# CommitDate: Sun May 26 10:15:42 2024 +0900
```

위 예시에서 AuthorDate와 CommitDate가 다른 이유는 원저자가 토요일에 코드를 작성했지만, rebase나 amend로 커밋이 재생성되어 일요일에 새로 기록되었기 때문이다.

### 타임스탬프가 다른 경우

AuthorDate와 CommitDate가 다른 상황은 여러 가지가 있다.

- **git cherry-pick**: 다른 브랜치의 커밋을 가져오면 AuthorDate는 원본 유지, CommitDate는 현재 시간
- **git rebase**: 커밋을 재적용하면 CommitDate만 갱신
- **git commit --amend**: 커밋을 수정하면 CommitDate가 현재 시간으로 갱신
- **패치 적용(git am)**: 이메일로 받은 패치를 적용할 때 AuthorDate는 원저자 시간 유지

## 커밋 시간 조정 방법

### 새 커밋 생성 시 시간 지정

새로운 커밋을 만들 때 `--date` 옵션으로 AuthorDate를 지정할 수 있으며, 다양한 날짜 형식을 지원한다.

```bash
# ISO 8601 형식 (가장 명확하고 권장)
git commit --date="2024-05-25T14:30:00+09:00" -m "feat: Add login feature"

# RFC 2822 형식
git commit --date="Sat, 25 May 2024 14:30:00 +0900" -m "feat: Add login feature"

# 상대적 시간 (Git이 해석)
git commit --date="2 days ago" -m "docs: Update README"
git commit --date="yesterday 14:30" -m "fix: Resolve bug"

# Unix 타임스탬프
git commit --date="@1716613800" -m "feat: Add feature"
```

### 마지막 커밋 시간 수정

가장 최근 커밋의 시간을 수정할 때는 `--amend`와 `--date`를 함께 사용한다.

```bash
# AuthorDate만 변경 (CommitDate는 현재 시간으로 갱신됨)
git commit --amend --date="2024-05-25T14:30:00+09:00" --no-edit

# AuthorDate와 CommitDate 모두 같은 값으로 설정
GIT_COMMITTER_DATE="2024-05-25T14:30:00+09:00" \
git commit --amend --date="2024-05-25T14:30:00+09:00" --no-edit

# 메시지도 함께 수정
git commit --amend --date="2024-05-25T14:30:00+09:00" -m "feat: Add login feature"
```

### 과거 커밋 시간 수정

특정 과거 커밋의 시간을 수정하려면 interactive rebase를 사용한다.

```bash
# 최근 3개 커밋 수정
git rebase -i HEAD~3
```

에디터에서 수정할 커밋을 `edit`으로 변경한다.

```
edit abc1234 First commit message
pick def5678 Second commit message
pick ghi9012 Third commit message
```

rebase가 해당 커밋에서 멈추면 시간을 수정하고 계속 진행한다.

```bash
# 시간 수정
GIT_COMMITTER_DATE="2024-05-25T14:30:00+09:00" \
git commit --amend --date="2024-05-25T14:30:00+09:00" --no-edit

# 다음 커밋으로 진행
git rebase --continue
```

### 여러 커밋 일괄 수정

여러 커밋의 시간을 한 번에 수정해야 할 때는 `filter-branch`나 `filter-repo`를 사용할 수 있으나, 이는 전체 히스토리를 재작성하므로 매우 주의해야 한다.

```bash
# filter-branch 예시 (deprecated, filter-repo 권장)
git filter-branch --env-filter '
if [ "$GIT_COMMIT" = "abc1234..." ]
then
    export GIT_AUTHOR_DATE="2024-05-25T14:00:00+09:00"
    export GIT_COMMITTER_DATE="2024-05-25T14:00:00+09:00"
fi' -- --all

# git-filter-repo 사용 (더 빠르고 안전)
# pip install git-filter-repo 로 설치 후
git filter-repo --commit-callback '
if commit.original_id == b"abc1234...":
    commit.author_date = b"1716613800 +0900"
    commit.committer_date = b"1716613800 +0900"
'
```

## 실전 활용 시나리오

### 오프라인 작업 동기화

비행기나 지하철 등 오프라인 환경에서 작업한 내용을 실제 작업 시간에 맞춰 커밋하고 싶을 때 사용한다.

```bash
# 어제 오후 2시에 작업한 내용 커밋
git add .
git commit --date="yesterday 14:30" -m "feat: Add offline feature"

# AuthorDate와 CommitDate 모두 맞추기
GIT_COMMITTER_DATE="yesterday 14:30" \
git commit --date="yesterday 14:30" -m "feat: Add offline feature"
```

### 시간대 변환

해외 출장 중 작업했거나 협업 중인 팀의 시간대에 맞춰야 할 때 사용한다.

```bash
# UTC 시간으로 커밋
git commit --date="2024-05-25T14:30:00Z" -m "feat: Add feature"

# 미국 동부 시간(EST)으로 커밋
git commit --date="2024-05-25T14:30:00-05:00" -m "feat: Add feature"
```

### GitHub 잔디 심기

GitHub의 Contribution 그래프에 특정 날짜에 커밋을 표시하고 싶을 때 AuthorDate를 조정하며, GitHub은 AuthorDate를 기준으로 Contribution을 계산한다.

```bash
# 특정 날짜에 기여 기록 남기기
git commit --date="2024-01-01T12:00:00+09:00" -m "chore: Happy new year commit"
```

## 주의사항

### 협업 시 주의점

이미 원격 저장소에 push한 커밋의 시간을 수정하면 커밋 해시가 변경되므로 `--force` push가 필요하며, 이는 다른 팀원의 로컬 히스토리와 충돌을 일으킬 수 있으므로 공유된 브랜치에서는 사용을 피해야 한다.

```bash
# 강제 push (위험 - 협업 시 주의)
git push --force origin feature/my-branch

# 더 안전한 방법 (다른 사람의 push가 있으면 실패)
git push --force-with-lease origin feature/my-branch
```

### 백업 권장

시간 수정 전에 현재 상태를 백업해두면 문제 발생 시 복구할 수 있다.

```bash
# 작업 전 백업 브랜치 생성
git branch backup/before-time-adjustment

# 문제 발생 시 복구
git reset --hard backup/before-time-adjustment
```

### 윤리적 고려

커밋 시간 조정은 기술적으로 가능하지만, 업무 시간 기록을 조작하거나 작업 이력을 허위로 꾸미는 용도로 사용하는 것은 윤리적으로 문제가 될 수 있으며, 오프라인 작업 동기화나 시간대 조정 같은 정당한 목적으로만 사용해야 한다.

## 결론

Git의 타임스탬프 시스템은 AuthorDate(원저자 작성 시간)와 CommitDate(저장소 기록 시간)로 구분되며, 이는 분산 버전 관리 시스템의 특성을 반영한 설계이다. `--date` 옵션으로 새 커밋의 AuthorDate를 지정하고, `--amend`로 마지막 커밋을 수정하며, interactive rebase로 과거 커밋을 조정할 수 있고, CommitDate까지 변경하려면 `GIT_COMMITTER_DATE` 환경변수를 사용해야 한다. 다만 이미 push한 커밋의 시간 수정은 히스토리 재작성이 필요하므로 협업 환경에서는 신중하게 사용해야 한다.
