---
title: "Merge 후 브랜치 삭제: 왜 그리고 어떻게"
date: 2024-07-11T22:27:22+09:00
tags: ["git", "version control", "collaboration", "branch management"]
description: "Git 브랜치의 생성부터 삭제까지 전체 라이프사이클을 이해하고, 병합된 브랜치를 안전하게 확인하고 삭제하는 방법과 자동화 스크립트, GitHub/GitLab의 자동 삭제 설정, 그리고 실수로 삭제한 브랜치를 복구하는 방법까지 포괄적으로 다룬다."
draft: false
---

Git에서 브랜치(Branch)는 독립적인 작업 공간을 제공하는 핵심 개념으로, 개발자들이 메인 코드베이스에 영향을 주지 않고 새로운 기능을 개발하거나 버그를 수정할 수 있게 해주며, 이러한 브랜치 기반 워크플로우는 2005년 Linus Torvalds가 Git을 설계할 때부터 핵심 설계 철학 중 하나였고, Git의 브랜치가 다른 버전 관리 시스템(SVN, CVS 등)에 비해 매우 가볍고 빠르게 동작하도록 만들어진 이유이기도 하다. 그러나 브랜치를 생성하는 것만큼이나 중요한 것이 병합 후 브랜치를 적절히 삭제하는 것이며, 이 글에서는 브랜치 삭제의 필요성부터 구체적인 방법, 자동화, 그리고 복구 방법까지 포괄적으로 다룬다.

## 브랜치 기반 개발 워크플로우

Git에서 브랜치를 활용한 개발 워크플로우는 대부분의 현대 소프트웨어 개발 팀에서 표준으로 자리 잡았으며, 이 워크플로우의 일반적인 과정은 다음과 같이 진행되고, 각 단계는 프로젝트의 특성과 팀의 규모에 따라 조정되거나 자동화될 수 있다.

### 일반적인 브랜치 워크플로우

**1. 새 브랜치 생성**: 메인 브랜치(main 또는 develop)에서 새로운 브랜치를 분기하며, 이때 브랜치 이름은 작업 내용을 명확히 나타내도록 명명하고, `git checkout -b feature/user-authentication`과 같은 명령어를 사용하여 브랜치를 생성하면서 동시에 체크아웃할 수 있다.

**2. 커밋 추가**: 새 브랜치에서 코드를 변경하고 의미 있는 단위로 커밋하며, 각 커밋은 하나의 논리적 변경을 담도록 하고, 커밋 메시지는 변경 사항을 명확히 설명해야 한다.

**3. 원격 저장소에 Push**: `git push origin feature/user-authentication` 명령어로 작업한 브랜치를 원격 저장소에 업로드하며, 이를 통해 다른 팀원들이 작업 내용을 확인하고 리뷰할 수 있게 된다.

**4. Pull Request 생성**: GitHub, GitLab, Bitbucket 등의 플랫폼에서 Pull Request(또는 Merge Request)를 생성하여 변경사항 병합을 요청하며, 이 과정에서 작업 내용에 대한 설명과 리뷰어 지정이 이루어진다.

**5. 코드 리뷰**: 팀원들이 코드를 검토하고 피드백을 제공하며, 필요시 수정을 요청하고, 이 과정은 코드 품질을 높이고 지식 공유를 촉진하는 중요한 단계이다.

**6. Merge 실행**: 리뷰가 완료되고 승인을 받으면 Pull Request를 메인 브랜치에 병합하며, 이때 Merge Commit, Squash Merge, Rebase 등 다양한 병합 전략 중 팀의 정책에 맞는 방식을 선택한다.

**7. 브랜치 삭제**: 병합이 완료되면 해당 브랜치는 더 이상 필요하지 않으므로 삭제하여 저장소를 깔끔하게 유지한다.

## 브랜치 라이프사이클과 유형

브랜치는 생성, 사용, 병합, 삭제의 명확한 라이프사이클을 가지며, 각 단계에서 적절한 관리가 필요하고, 이러한 라이프사이클 관리를 통해 저장소의 복잡도를 낮추고 협업 효율성을 높일 수 있으며, 브랜치는 그 수명과 목적에 따라 크게 두 가지 유형으로 분류된다.

### 단명 브랜치 (Short-lived Branches)

> **단명 브랜치란?**
>
> 특정 작업을 위해 생성되어 빠르게 병합되고 삭제되는 브랜치로, 일반적으로 며칠에서 몇 주 이내에 생명 주기가 완료되며, 병합 후 즉시 삭제하는 것이 권장된다.

**Feature 브랜치**는 새로운 기능 개발을 위해 생성되는 가장 일반적인 단명 브랜치 유형으로, develop 또는 main 브랜치에서 분기하여 기능 개발을 진행하고, 개발 완료 후 코드 리뷰를 거쳐 병합되며, 병합 즉시 삭제하여 저장소를 깔끔하게 유지하는 것이 일반적인 관행이다.

**Bugfix 브랜치**는 버그 수정을 위해 생성되며, feature 브랜치와 유사한 라이프사이클을 가지지만 일반적으로 더 짧은 수명을 가지고, 긴급하지 않은 버그 수정에 사용되며, 병합 후 삭제된다.

**Hotfix 브랜치**는 프로덕션 환경에서 발견된 긴급 버그를 수정하기 위해 생성되는 브랜치로, main(또는 production) 브랜치에서 직접 분기하고, 수정 완료 후 main과 develop 양쪽에 병합되며, 병합 후 즉시 삭제하여 긴급 수정의 완료를 명확히 표시한다.

**Release 브랜치**는 배포 준비를 위해 생성되는 브랜치로, develop 브랜치에서 분기하여 버전 번호 업데이트, 최종 버그 수정, 문서화 등의 배포 준비 작업을 진행하고, 배포 완료 후 main과 develop 양쪽에 병합되며 삭제된다.

### 장명 브랜치 (Long-lived Branches)

> **장명 브랜치란?**
>
> 프로젝트 전체 기간 동안 유지되는 브랜치로, 지속적으로 업데이트되고 여러 단명 브랜치들의 병합 대상이 되며, 절대 삭제해서는 안 되는 브랜치이다.

**main (또는 master)** 브랜치는 프로덕션 환경에 배포되는 안정적인 코드를 담는 브랜치로, 직접 커밋은 지양되고 다른 브랜치로부터의 병합만 이루어지며, 모든 커밋이 배포 가능한 상태를 유지해야 한다.

**develop** 브랜치는 다음 릴리스를 위한 개발 작업이 통합되는 브랜치로, feature 브랜치들이 병합되는 대상이며, main 브랜치보다 앞선 상태를 유지하면서 다음 배포를 준비한다.

**production** 또는 **staging** 브랜치는 프로젝트에 따라 추가적으로 운영되는 장명 브랜치로, 각각 프로덕션 환경과 스테이징 환경에 대응하며 지속적으로 유지된다.

## Merge 후 브랜치를 삭제해야 하는 이유

병합이 완료된 브랜치를 삭제하는 것은 단순한 정리 작업이 아니라 건강한 저장소 관리를 위한 필수적인 관행이며, 이를 통해 얻을 수 있는 이점은 다양하고 팀 전체의 생산성 향상에 기여한다.

### 저장소 가독성과 관리 효율성

병합된 브랜치를 삭제하면 저장소가 깔끔하게 유지되어 개발자들이 현재 활성화된 작업만 볼 수 있고, 수십 또는 수백 개의 오래된 브랜치가 쌓여 있으면 `git branch` 명령어의 출력이 지저분해지고 실제로 작업 중인 브랜치를 찾기 어려워지며, 이는 특히 대규모 프로젝트에서 심각한 문제가 될 수 있다. 또한 깔끔한 브랜치 목록은 새로운 팀원이 프로젝트에 합류했을 때 현재 진행 중인 작업을 파악하는 데 도움이 되고, 프로젝트의 전반적인 상태를 한눈에 이해할 수 있게 해준다.

### Git 성능 최적화

Git은 브랜치가 많아질수록 일부 작업에서 성능 저하가 발생할 수 있으며, 특히 `git branch -a`, `git fetch`, `git gc` 같은 명령어는 브랜치 수에 영향을 받고, 대규모 프로젝트에서 수천 개의 브랜치가 존재하면 이러한 명령어의 실행 시간이 눈에 띄게 증가할 수 있으며, 정기적인 브랜치 정리는 Git 작업의 전반적인 성능을 유지하는 데 도움이 된다.

### 실수 방지와 워크플로우 명확화

병합된 오래된 브랜치가 남아 있으면 개발자가 실수로 해당 브랜치에 커밋할 수 있으며, 이는 코드가 잘못된 위치에 반영되거나 병합 충돌을 야기할 수 있고, 특히 비슷한 이름의 브랜치가 여러 개 존재할 때 이런 실수가 발생하기 쉽다. 브랜치 삭제는 또한 작업 완료의 명확한 신호 역할을 하여, 팀원들에게 해당 기능이나 수정이 완료되어 메인 코드베이스에 통합되었음을 알려주는 커뮤니케이션 수단으로도 기능한다.

### 저장 공간 및 보안

브랜치 자체는 큰 저장 공간을 차지하지 않지만(Git 브랜치는 기본적으로 특정 커밋을 가리키는 포인터에 불과함), 원격 저장소에서 브랜치를 유지하면 각 클론 시 해당 참조가 함께 복제되고, 장기적으로 불필요한 데이터가 누적될 수 있다. 보안 측면에서도 오래된 브랜치에 민감한 정보나 취약점이 포함된 코드가 남아 있을 수 있으며, 이를 정리함으로써 잠재적인 보안 위험을 줄일 수 있다.

## 브랜치 삭제 전 확인사항

브랜치를 삭제하기 전에 반드시 병합 상태를 확인해야 하며, 이를 통해 병합되지 않은 작업을 실수로 잃어버리는 것을 방지할 수 있고, Git은 이러한 확인을 위한 다양한 명령어를 제공한다.

### 병합된 브랜치 확인

`git branch --merged` 명령어는 현재 체크아웃된 브랜치에 이미 병합된 브랜치 목록을 표시하며, 이 목록에 나타난 브랜치들은 해당 브랜치의 모든 커밋이 현재 브랜치에 포함되어 있으므로 안전하게 삭제할 수 있다.

```bash
# 현재 브랜치에 병합된 브랜치 목록
git branch --merged

# 특정 브랜치(예: main)에 병합된 브랜치 목록
git branch --merged main

# 원격 브랜치 중 병합된 브랜치 목록
git branch -r --merged main
```

반대로 `git branch --no-merged` 명령어는 아직 병합되지 않은 브랜치를 확인할 때 사용하며, 이 브랜치들은 고유한 커밋을 가지고 있어 삭제 시 작업이 손실될 수 있으므로 주의가 필요하다.

```bash
# 아직 병합되지 않은 브랜치 목록
git branch --no-merged

# 특정 브랜치에 병합되지 않은 브랜치
git branch --no-merged main
```

### 로컬과 원격 브랜치 상태 확인

로컬 브랜치와 원격 브랜치의 동기화 상태를 파악하는 것도 중요하며, `-r` 옵션은 원격 브랜치만, `-a` 옵션은 로컬과 원격 브랜치 모두를 표시하고, `-vv` 옵션은 각 브랜치의 추적 상태와 커밋 차이를 상세히 보여준다.

```bash
# 원격 브랜치 목록
git branch -r

# 로컬과 원격 브랜치 모두 표시
git branch -a

# 추적 상태와 ahead/behind 정보 포함
git branch -vv
```

`git branch -vv` 출력 예시는 다음과 같으며, 각 브랜치가 어떤 원격 브랜치를 추적하고 있는지, 그리고 원격과 몇 커밋 앞서거나 뒤처져 있는지 확인할 수 있다.

```
* main              abc1234 [origin/main] Latest commit message
  feature/login     def5678 [origin/feature/login: ahead 2] Add login feature
  bugfix/typo       ghi9012 [origin/bugfix/typo: gone] Fix typo
```

위 출력에서 `gone`으로 표시된 브랜치는 원격에서 이미 삭제되었지만 로컬에 추적 브랜치가 남아 있는 상태를 나타낸다.

### 브랜치 간 커밋 차이 확인

브랜치를 삭제하기 전에 해당 브랜치에만 존재하는 커밋이 있는지 확인하는 것이 좋으며, `git log` 명령어의 범위 지정 문법을 사용하여 브랜치 간의 커밋 차이를 확인할 수 있다.

```bash
# feature 브랜치에만 있고 main에 없는 커밋 확인
git log main..feature

# 양방향 차이 확인 (양쪽에만 있는 커밋 모두 표시)
git log main...feature --oneline

# 커밋 개수만 확인
git log main..feature --oneline | wc -l
```

## 브랜치 삭제 방법

### 로컬 브랜치 삭제

Git은 로컬 브랜치를 삭제하기 위해 두 가지 옵션을 제공하며, 각각의 안전성 수준과 용도가 다르므로 상황에 맞게 선택하여 사용해야 한다.

> **안전한 삭제 (-d 옵션)**
>
> `git branch -d <branch-name>` 명령어는 병합이 완료된 브랜치만 삭제하며, 병합되지 않은 커밋이 있으면 삭제를 거부하여 실수로 인한 데이터 손실을 방지한다.

```bash
# 안전한 삭제 (병합된 브랜치만)
git branch -d feature/user-authentication

# 여러 브랜치 동시 삭제
git branch -d feature/login feature/signup bugfix/typo
```

병합되지 않은 브랜치를 `-d` 옵션으로 삭제하려고 하면 Git은 다음과 같은 오류 메시지를 표시하며, 이는 해당 브랜치에 아직 다른 브랜치로 병합되지 않은 고유한 작업이 있음을 경고하는 것이다.

```
error: The branch 'feature-branch' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature-branch'.
```

> **강제 삭제 (-D 옵션)**
>
> `git branch -D <branch-name>` 명령어는 병합 여부와 관계없이 브랜치를 강제로 삭제하며, 병합되지 않은 커밋이 있어도 삭제되므로 삭제 후 복구가 어려울 수 있어 신중하게 사용해야 한다.

```bash
# 강제 삭제 (병합 여부 무관)
git branch -D experimental-feature

# 실험적이거나 더 이상 필요 없는 작업 폐기 시 사용
git branch -D spike/prototype
```

강제 삭제는 실험적 브랜치를 폐기하거나, 다른 방향으로 재구현하기로 결정했을 때, 또는 잘못 생성된 브랜치를 정리할 때 유용하지만, 중요한 작업이 포함되어 있지 않은지 반드시 확인해야 한다.

### 원격 브랜치 삭제

원격 저장소의 브랜치를 삭제하는 것은 로컬 삭제와는 독립적인 작업이며, `git push` 명령어를 사용하여 원격 브랜치를 삭제할 수 있고, 두 가지 문법이 동일한 기능을 수행한다.

```bash
# 표준 문법 (권장)
git push origin --delete feature/user-authentication

# 대체 문법 (콜론 사용)
git push origin :feature/user-authentication

# 여러 브랜치 동시 삭제
git push origin --delete feature/login feature/signup
```

원격 브랜치를 삭제하면 해당 브랜치는 원격 저장소에서 제거되지만, 다른 개발자의 로컬 저장소에는 여전히 해당 원격 브랜치에 대한 추적 참조(`origin/feature/user-authentication`)가 남아 있을 수 있으며, 이를 정리하려면 별도의 명령어가 필요하다.

### 원격 브랜치 참조 정리 (Prune)

원격에서 삭제된 브랜치의 로컬 추적 참조를 정리하는 것은 저장소를 깔끔하게 유지하는 데 중요하며, `git fetch` 명령어의 `--prune` 옵션을 사용하여 원격에 더 이상 존재하지 않는 브랜치에 대한 로컬 참조를 자동으로 제거할 수 있다.

```bash
# 원격 저장소의 최신 상태를 가져오면서 삭제된 브랜치 참조 제거
git fetch origin --prune

# 모든 원격 저장소에 대해 실행
git fetch --all --prune

# 축약형
git fetch -p
```

매번 fetch 시 자동으로 prune을 실행하도록 Git 설정을 변경할 수도 있으며, 이렇게 하면 별도로 `--prune` 옵션을 지정하지 않아도 항상 정리가 이루어진다.

```bash
# 전역 설정으로 자동 prune 활성화
git config --global fetch.prune true

# 특정 저장소에만 설정
git config fetch.prune true
```

## 대량 브랜치 삭제 자동화

프로젝트가 진행되면서 병합된 브랜치가 누적되면 일일이 수동으로 삭제하는 것이 번거로워지며, 이런 경우 스크립트를 활용하여 브랜치를 일괄적으로 정리할 수 있고, 이는 정기적인 유지보수 작업에 매우 유용하다.

### 병합된 로컬 브랜치 일괄 삭제

다음 스크립트는 현재 브랜치에 병합된 모든 로컬 브랜치를 삭제하되, main, master, develop 같은 중요 브랜치는 보호하면서 안전하게 정리할 수 있다.

```bash
# main을 제외한 병합된 브랜치 삭제
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d
```

이 명령어의 작동 원리는 다음과 같다.

1. `git branch --merged`: 현재 브랜치에 병합된 브랜치 목록 출력
2. `grep -v "\*"`: 현재 체크아웃된 브랜치(앞에 `*` 표시) 제외
3. `grep -v "main"` 등: 보호할 브랜치 이름 제외
4. `xargs -n 1 git branch -d`: 각 브랜치를 하나씩 안전하게 삭제

더 안전하게 삭제 전 확인을 요청하는 방식도 있으며, `-p` 옵션을 추가하면 각 브랜치 삭제 전에 y/n으로 확인할 수 있다.

```bash
# 삭제할 브랜치 목록 미리 확인 (dry run)
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop"

# 각 브랜치마다 확인 후 삭제
git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 -p git branch -d
```

### 원격에서 삭제된 브랜치의 로컬 추적 브랜치 정리

원격 저장소에서 삭제된 브랜치에 대한 로컬 추적 브랜치를 찾아 삭제하는 스크립트는 prune 후에도 남아 있는 로컬 브랜치를 정리하는 데 유용하며, `gone`으로 표시된 브랜치들을 찾아 삭제한다.

```bash
# 원격 추적이 끊긴 로컬 브랜치 찾기 및 삭제
git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
```

이 명령어는 먼저 `git fetch -p`로 원격 브랜치 참조를 정리하고, `git branch -vv`로 추적 상태를 확인하며, `gone`으로 표시된 브랜치(원격에서 삭제됨)들을 찾아 강제 삭제한다.

### 재사용 가능한 정리 스크립트

정기적인 브랜치 정리를 위해 재사용 가능한 스크립트를 만들어 두면 편리하며, 다음은 정리 작업을 수행하고 결과를 보고하는 예시 스크립트이다.

```bash
#!/bin/bash
# branch-cleanup.sh - Git 브랜치 정리 스크립트

echo "=== Git Branch Cleanup Report ==="
echo "Date: $(date)"
echo "Repository: $(basename $(git rev-parse --show-toplevel))"
echo ""

# 보호할 브랜치 목록
PROTECTED_BRANCHES="main|master|develop|production|staging"

echo "Protected branches: $PROTECTED_BRANCHES"
echo ""

# 병합된 브랜치 확인
echo "Merged branches that can be deleted:"
git branch --merged main | grep -v "\*" | grep -Ev "($PROTECTED_BRANCHES)" | sed 's/^/  /'

echo ""
echo "Remote tracking branches with 'gone' status:"
git branch -vv | grep ': gone]' | awk '{print "  " $1}'

echo ""
read -p "Do you want to proceed with deletion? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting merged branches..."
    git branch --merged main | grep -v "\*" | grep -Ev "($PROTECTED_BRANCHES)" | xargs -n 1 git branch -d 2>/dev/null

    echo "Pruning remote references..."
    git fetch --all -p

    echo "Deleting gone tracking branches..."
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D 2>/dev/null

    echo ""
    echo "Cleanup completed!"
else
    echo "Cleanup cancelled."
fi
```

## 브랜치 삭제 시 주의사항

브랜치 삭제는 되돌리기 어려운 작업이므로 신중하게 진행해야 하며, 몇 가지 중요한 주의사항을 염두에 두면 실수를 방지하고 팀의 워크플로우를 안전하게 유지할 수 있다.

### 메인 브랜치 보호

main, master, develop, production 같은 장명 브랜치는 프로젝트의 핵심 브랜치로 절대 삭제해서는 안 되며, 실수로 삭제하는 것을 방지하기 위해 GitHub, GitLab 등의 플랫폼에서 브랜치 보호 규칙(Branch Protection Rules)을 설정하는 것이 권장되고, 스크립트에서도 이러한 브랜치를 명시적으로 제외해야 한다.

**GitHub 브랜치 보호 설정**:
1. Repository → Settings → Branches로 이동
2. "Branch protection rules"에서 "Add rule" 클릭
3. 보호할 브랜치 패턴(예: `main`) 입력
4. "Prevent deletions" 옵션 활성화

### 팀원과의 커뮤니케이션

원격 브랜치를 삭제하기 전에 해당 브랜치에서 작업 중인 팀원이 없는지 확인해야 하며, 특히 공유 브랜치나 여러 사람이 사용할 가능성이 있는 브랜치는 팀과 논의 후 삭제하는 것이 좋고, 갑작스러운 삭제는 협업에 혼란을 줄 수 있다. Pull Request가 아직 열려 있거나 리뷰 중인 브랜치는 함부로 삭제하지 않아야 하며, CI/CD 파이프라인에서 참조하고 있는 브랜치도 삭제 전 확인이 필요하다.

### 백업을 위한 태그 활용

삭제하려는 브랜치의 작업을 나중에 참조해야 할 가능성이 있다면 브랜치를 삭제하기 전에 태그를 생성하여 백업할 수 있으며, 태그는 특정 커밋을 가리키는 불변의 참조로 브랜치가 삭제되어도 유지되고 나중에 언제든 접근할 수 있다.

```bash
# 브랜치 삭제 전 태그로 백업
git tag archive/feature-user-auth feature/user-authentication
git push origin archive/feature-user-auth

# 이후 브랜치 삭제
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication

# 나중에 필요시 태그에서 브랜치 복구
git checkout -b feature/user-authentication-restored archive/feature-user-auth
```

archive 접두사를 사용하면 일반 릴리스 태그와 구분할 수 있어 태그 목록을 관리하기 쉬워지며, 팀의 정책에 따라 적절한 네이밍 규칙을 정할 수 있다.

## GitHub/GitLab 자동 삭제 설정

GitHub과 GitLab은 Pull Request 또는 Merge Request가 병합된 후 자동으로 소스 브랜치를 삭제하는 기능을 제공하며, 이를 활용하면 수동으로 브랜치를 정리하는 수고를 덜 수 있고 저장소를 자동으로 깔끔하게 유지할 수 있다.

### GitHub 자동 삭제 설정

GitHub에서는 저장소 설정에서 Pull Request 병합 후 자동으로 head 브랜치를 삭제하는 옵션을 활성화할 수 있으며, 이는 저장소 단위로 설정되고 개별 PR에서도 병합 시 선택할 수 있다.

1. Repository → Settings → General로 이동
2. "Pull Requests" 섹션에서 "Automatically delete head branches" 체크박스 활성화
3. 이후 PR이 병합될 때마다 소스 브랜치가 자동으로 삭제됨

개별 PR 병합 화면에서도 "Delete branch" 버튼이 표시되며, 자동 삭제가 설정되어 있으면 병합과 동시에 삭제가 이루어지고, 설정되어 있지 않아도 버튼을 클릭하여 수동으로 삭제할 수 있다.

### GitLab 자동 삭제 설정

GitLab에서도 유사한 기능을 제공하며, Merge Request 생성 시 또는 프로젝트 설정에서 병합 후 소스 브랜치 삭제 옵션을 활성화할 수 있고, 프로젝트 전체에 적용되거나 개별 MR에서 선택할 수 있다.

1. Project → Settings → Merge requests로 이동
2. "Squash commits when merging" 섹션에서 "Enable 'Delete source branch' option by default" 활성화
3. 이후 MR 생성 시 기본적으로 삭제 옵션이 선택됨

### 자동화의 장단점

자동 브랜치 삭제는 관리 부담을 줄이고 저장소를 깔끔하게 유지하는 장점이 있지만, 모든 상황에 적합한 것은 아니며 프로젝트의 워크플로우와 팀의 작업 방식을 고려하여 결정해야 한다.

**장점**으로는 수동 삭제 작업이 불필요해지고, 저장소가 자동으로 정리되며, 브랜치 라이프사이클의 종료가 명확해지고, 실수로 오래된 브랜치에 커밋하는 것을 방지할 수 있다는 점이 있다.

**단점**으로는 브랜치를 보관하고 싶은 경우 별도 조치가 필요하고, 자동 삭제 전 백업하지 못한 경우 복구 작업이 필요하며, 팀원들이 아직 로컬에서 작업 중일 수 있고, 일부 워크플로우에서는 병합 후에도 브랜치를 유지해야 할 수 있다는 점이 있다.

## 삭제된 브랜치 복구 방법

실수로 브랜치를 삭제했거나 삭제 후 필요한 작업이 있음을 발견한 경우 Git의 reflog 기능을 사용하여 삭제된 브랜치를 복구할 수 있으며, reflog는 HEAD와 브랜치 참조의 모든 이동 기록을 저장하므로 최근 작업을 되돌리는 데 매우 유용하다.

### reflog 이해하기

> **reflog란?**
>
> Reference log의 약자로, 로컬 저장소에서 HEAD와 브랜치 참조가 변경된 모든 기록을 저장하는 메커니즘이며, 기본적으로 90일간 기록이 유지되고, 브랜치 삭제, 커밋 수정, 리베이스 등의 작업을 되돌리는 데 활용할 수 있다.

```bash
# reflog 확인
git reflog

# 특정 브랜치의 reflog 확인
git reflog show feature/user-authentication

# 출력 예시
a1b2c3d HEAD@{0}: checkout: moving from feature-branch to main
e4f5g6h HEAD@{1}: commit: Add user authentication feature
i7j8k9l HEAD@{2}: commit: Create login form
m3n4o5p HEAD@{3}: checkout: moving from main to feature-branch
```

reflog 출력에서 각 항목은 HEAD가 해당 커밋을 가리켰던 시점을 나타내며, `HEAD@{n}` 형식의 참조를 사용하여 특정 시점의 커밋에 접근할 수 있다.

### 로컬 브랜치 복구

삭제된 브랜치의 마지막 커밋 해시를 reflog에서 찾았다면 해당 커밋에서 새 브랜치를 생성하여 복구할 수 있으며, 브랜치 이름은 원래 이름과 동일하게 하거나 다른 이름으로 지정할 수 있다.

```bash
# reflog에서 삭제된 브랜치의 마지막 커밋 확인
git reflog | grep "feature-branch"

# 해당 커밋에서 브랜치 복구
git checkout -b feature-branch e4f5g6h

# 또는 브랜치만 생성 (체크아웃 없이)
git branch feature-branch e4f5g6h

# HEAD 참조를 사용한 복구
git checkout -b feature-branch HEAD@{2}
```

### 원격 브랜치 복구

원격 브랜치가 삭제된 경우 로컬에 해당 브랜치가 남아 있다면 다시 push하여 복구할 수 있으며, 로컬에도 없다면 다른 팀원의 로컬 저장소에서 가져오거나 reflog를 통해 복구한 후 push해야 한다.

```bash
# 로컬에 브랜치가 남아 있는 경우
git push origin feature-branch

# 로컬에도 없는 경우: reflog로 복구 후 push
git checkout -b feature-branch e4f5g6h
git push -u origin feature-branch
```

reflog는 로컬 저장소에만 존재하고 기본적으로 90일간 기록을 유지하므로, 최근에 삭제된 브랜치는 복구 가능하지만 시간이 오래 지나면 기록이 정리되어 복구가 어려울 수 있으며, 중요한 작업은 삭제 전 반드시 확인하고 필요시 태그로 백업해 두는 것이 좋다.

## 팀 워크플로우에 브랜치 삭제 정책 통합

브랜치 삭제 정책은 팀의 Git 워크플로우와 통합되어야 효과적이며, 브랜치 네이밍 규칙, 삭제 시기, 책임자 지정 등을 명확히 정의하면 혼란을 방지하고 효율적인 협업이 가능하다.

### 브랜치 유형별 삭제 정책

일관된 브랜치 네이밍 규칙은 브랜치의 목적과 수명을 명확히 하며, 이를 통해 어떤 브랜치를 언제 삭제해야 하는지 쉽게 판단할 수 있고 자동화 스크립트 작성에도 도움이 된다.

```bash
# 브랜치 네이밍과 삭제 정책 예시
feature/*      # 기능 개발 - PR 병합 즉시 삭제
bugfix/*       # 버그 수정 - PR 병합 즉시 삭제
hotfix/*       # 긴급 수정 - 병합 후 즉시 삭제
release/*      # 릴리스 준비 - 배포 완료 후 삭제 (또는 태그로 보존)
experiment/*   # 실험적 작업 - 팀 논의 후 결정
spike/*        # 기술 검증 - 검증 완료 후 삭제
```

### 정기적인 브랜치 정리 일정

정기적으로 브랜치를 검토하고 정리하는 일정을 팀 프로세스에 포함시키면 저장소가 지저분해지는 것을 방지할 수 있으며, 스프린트 종료 시, 릴리스 후, 또는 매월 정해진 날짜에 브랜치 정리 작업을 수행하는 것이 좋다.

정리 작업의 일반적인 절차는 다음과 같다.

1. 병합된 브랜치 목록 확인
2. 필요한 경우 태그 생성하여 백업
3. 자동화 스크립트 실행하여 일괄 삭제
4. 팀원들에게 정리 내역 공유

### CI/CD 파이프라인 통합

브랜치 정리 작업을 CI/CD 파이프라인에 통합하여 자동화할 수도 있으며, 예를 들어 정기적으로 스케줄링된 작업(Cron Job)으로 오래된 병합 브랜치를 정리하거나, 릴리스 파이프라인의 마지막 단계에서 release 브랜치를 자동 삭제하도록 설정할 수 있다.

## 결론

정기적인 브랜치 관리는 효율적인 Git 워크플로우의 핵심이며, 브랜치의 라이프사이클을 이해하고 병합 상태를 확인하며 적절한 삭제 명령어를 사용하고 자동화를 활용하면 저장소를 깔끔하게 유지하고 팀 협업을 원활하게 할 수 있다. 삭제 시 주의사항을 염두에 두고 필요한 경우 복구 방법을 알고 있으면 실수를 두려워하지 않고 자신 있게 브랜치를 관리할 수 있으며, 팀의 워크플로우에 브랜치 삭제 정책을 통합하면 더욱 체계적이고 효율적인 버전 관리가 가능해진다.
