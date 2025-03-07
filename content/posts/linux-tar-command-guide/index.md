---
title: "tar 명령어 사용법 빠르게 알아보기"
date: 2025-02-18T21:17:41+09:00
tags: ["tar", "압축", "리눅스", "명령어"]
description: "리눅스 tar 명령어의 핵심 옵션들을 실제 사용 예시와 함께 설명한다."
draft: false
---

tar는 리눅스에서 가장 많이 사용되는 압축/압축해제 도구다. tar라는 이름은 'Tape Archive'의 약자로, 원래는 테이프 백업용으로 만들어졌다. 하지만 현재는 파일을 묶고 압축하는 가장 일반적인 도구로 사용된다.

## 필수 알아야 할 기본 옵션

tar 명령어는 크게 동작 지정 옵션과 동작 수정 옵션으로 나뉜다. 모든 tar 명령어는 이 두 종류의 옵션을 조합해서 사용한다.

### 동작 지정 옵션

-   c : 새로운 아카이브(파일) 생성
-   x : 아카이브 풀기
-   t : 아카이브 내용 확인
-   r : 아카이브에 파일 추가
-   u : 아카이브의 파일 업데이트

### 동작 수정 옵션

-   f : 파일 이름 지정 (거의 항상 사용)
-   v : 처리 과정 출력
-   z : gzip 압축 사용 (.tar.gz)
-   j : bzip2 압축 사용 (.tar.bz2)
-   J : xz 압축 사용 (.tar.xz)

## 실제로 자주 사용하는 옵션들

### 압축하기

```bash
# 기본 tar 파일 만들기
tar cf archive.tar files/

# gzip으로 압축하기 (가장 많이 사용)
tar czf archive.tar.gz files/

# bzip2로 압축하기 (더 높은 압축률)
tar cjf archive.tar.bz2 files/
```

### 압축 풀기

```bash
# tar 파일 풀기
tar xf archive.tar

# gzip 압축 풀기
tar xzf archive.tar.gz

# bzip2 압축 풀기
tar xjf archive.tar.bz2
```

### 파일 확인

```bash
# tar 파일 내용 보기
tar tf archive.tar

# 자세히 보기
tar tvf archive.tar
```

## 알면 정말 유용한 옵션들

### 경로 관련

-   -C : 다른 디렉토리에서 실행
-   -P : 절대 경로 유지
-   --strip-components=N : 압축 풀 때 상위 N개 디렉토리 제거

### 파일 선택

-   --exclude : 특정 파일/디렉토리 제외
-   --exclude-from : 제외할 파일 목록을 파일에서 읽기
-   --wildcards : 와일드카드 패턴 사용

### 속성 보존

-   -p : 파일 권한 유지
-   --same-owner : 소유자 정보 유지
-   --numeric-owner : UID/GID 보존

## 마치며

tar는 파일 압축 외에도 다양한 용도로 활용된다. 시스템 백업에서는 파일의 권한과 소유자 정보를 그대로 보존해야 하므로 -p 옵션이 중요하다. 소프트웨어 배포 시에는 압축률이 높은 xz 압축을 주로 사용한다.

디렉토리 구조가 복잡한 웹 애플리케이션의 경우, 로그나 캐시 등 불필요한 파일을 제외하고 백업하는 것이 중요하다. --exclude 옵션으로 이런 파일들을 제외할 수 있다.
