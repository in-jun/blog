---
title: "chown으로 파일 소유권 관리하기"
date: 2025-02-18T04:31:21+09:00
tags: ["chown", "소유권", "리눅스", "권한"]
description: "리눅스의 파일 소유권 관리 도구인 chown의 개념과 활용법을 설명한다."
draft: false
---

## 사용자와 그룹의 이해

사용자는 시스템을 사용하는 독립된 주체다. 모든 사용자에게는 고유한 UID(User ID)가 할당되는데, 특히 UID 0은 root 사용자를 의미하며 일반 사용자는 1000번 이상의 UID를 받는다. 각 사용자는 개인 파일과 설정을 저장할 수 있는 홈 디렉토리를 가지며, 기본 셸과 환경 변수, 접근 권한 등을 개별적으로 설정할 수 있다.

반면 그룹은 여러 사용자를 하나로 묶어 관리하는 단위로, 파일이나 디렉토리의 권한을 그룹 단위로 부여할 수 있다. 사용자는 여러 그룹에 동시에 속할 수 있는데, 계정 생성 시 지정되는 기본 그룹(primary group)과 필요에 따라 추가되는 보조 그룹(supplementary groups)으로 나뉜다. 그룹 역시 사용자처럼 고유한 GID(Group ID)를 가진다.

## 파일 소유권의 의미

리눅스에서 모든 파일과 디렉토리는 반드시 소유자와 소유 그룹을 가진다. 이는 해당 파일에 대한 접근 권한을 결정하는 기준이 된다. 예를 들어 웹 서버를 운영할 때는 www-data라는 전용 계정이 웹 서버 프로세스를 실행하고, webdev 그룹에 속한 개발자들이 웹 서버의 파일을 수정할 수 있게 된다.

파일의 소유권은 ls -l 명령어로 확인할 수 있다:

```
-rw-r--r-- 1 john developers 123 Feb 17 15:50 project.txt
```

여기서 john은 파일의 소유자를, developers는 소유 그룹을 나타낸다.

## chown 명령어의 역할

파일의 소유권을 변경하는 명령어가 바로 chown이다. change owner의 약자인 이 명령어는 파일이나 디렉토리의 소유자나 소유 그룹을 변경할 수 있다. 단, 소유권 변경은 root 사용자만이 할 수 있다는 점에 주의해야 한다.

기본적인 사용법은 다음과 같다:

```bash
# 소유자만 변경
chown user file

# 소유자와 그룹 동시 변경
chown user:group file

# 그룹만 변경
chown :group file
```

## 실제 활용 사례

가장 흔한 사용 사례는 웹 서버의 파일 관리다. nginx나 Apache 웹 서버는 www-data 사용자로 실행되므로, 웹 서버가 접근하는 파일들의 소유권을 적절히 설정해야 한다:

```bash
# 웹 루트 디렉토리 설정
chown -R www-data:www-data /var/www/html/

# 개발자 그룹에게 쓰기 권한 부여
chown :developers /var/www/html/dev/
chmod g+w /var/www/html/dev/
```

데이터베이스 서버도 비슷한 방식으로 관리한다:

```bash
# DB 데이터 디렉토리 설정
chown -R mysql:mysql /var/lib/mysql/

# 백업 디렉토리 권한 설정
chown :dbadmin /backup/mysql/
chmod 775 /backup/mysql/
```

## 주의해야 할 점

시스템 파일의 소유권은 특히 신중하게 다뤄야 한다. 잘못된 소유권 설정은 시스템 전체에 영향을 미칠 수 있기 때문이다:

```bash
# 시스템 파일의 올바른 소유권
chown root:root /etc/passwd
chown root:shadow /etc/shadow
```

사용자의 홈 디렉토리도 적절한 소유권 설정이 중요하다:

```bash
# 홈 디렉토리 설정
chown -R user:user /home/user/

# SSH 설정 파일은 특히 중요
chown -R user:user ~/.ssh/
chmod 700 ~/.ssh/
```

## 효율적인 관리 방법

소유권 관리의 핵심은 필요한 경우에만 최소한의 변경을 하는 것이다. 특히 다음 원칙을 지키는 것이 좋다:

1. 시스템 파일의 소유권은 건드리지 않는다
2. 공유 디렉토리는 그룹 권한을 활용한다
3. 정기적으로 중요 파일의 소유권을 점검한다
4. 변경 사항은 반드시 기록으로 남긴다
