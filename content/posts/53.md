---
title: "Ubuntu에서 ssh서버 실행하고 접속하기"
date: 2024-08-14T15:16:40+09:00
tags: ["ubuntu", "ssh", "networking"]
draft: false
---

## 서론

SSH(Secure Shell)는 네트워크상의 다른 컴퓨터에 로그인하거나 원격 시스템에서 명령을 실행하고 파일을 전송할 수 있게 해주는 네트워크 프로토콜이다. 이 글에서는 Ubuntu 시스템에서 SSH 서버를 설치하고 자동으로 실행되도록 설정하는 방법, 그리고 SSH 서버에 접속하는 방법을 단계별로 설명하겠다.

## SSH 서버 설치하기

1. 먼저 터미널을 열고 패키지 목록을 업데이트한다:

    ```bash
    sudo apt update
    ```

2. OpenSSH 서버를 설치한다:

    ```bash
    sudo apt install openssh-server
    ```

3. 설치가 완료되면 SSH 서비스가 자동으로 시작된다. SSH 서비스의 상태를 확인하려면 다음 명령어를 입력한다:

    ```bash
    sudo systemctl status ssh
    ```

    서비스가 실행 중이지 않다면, 다음 명령어로 시작할 수 있다:

    ```bash
    sudo systemctl start ssh
    ```

4. SSH 서비스가 부팅 시 자동으로 시작되도록 설정한다:

    ```bash
    sudo systemctl enable ssh
    ```

    이 명령어는 시스템이 부팅될 때 SSH 서비스가 자동으로 시작되도록 보장한다.

## SSH 서버 설정하기

1. SSH 설정 파일을 연다:

    ```bash
    sudo nano /etc/ssh/sshd_config
    ```

2. 필요에 따라 다음 설정을 변경할 수 있다:

    - **포트 변경**: 기본 포트 22를 다른 포트로 변경하여 보안을 강화할 수 있다. 예를 들어, 포트를 2222로 변경하려면:

        ```bash
        Port 2222
        ```

    - **루트 로그인 비활성화**: 루트 계정으로의 SSH 로그인을 비활성화하여 보안을 강화할 수 있다:

        ```bash
        PermitRootLogin no
        ```

    - **비밀번호 인증 비활성화**: 공개키 인증을 사용하는 경우, 비밀번호 인증을 비활성화할 수 있다:

        ```bash
        PasswordAuthentication no
        ```

3. 변경 사항을 저장하고 편집기를 종료한다. (`Ctrl+O`로 저장하고 `Ctrl+X`로 종료)

4. SSH 서비스를 재시작하여 변경 사항을 적용한다:

    ```bash
    sudo systemctl restart ssh
    ```

## 방화벽 설정

Ubuntu의 기본 방화벽인 UFW를 사용 중이라면, SSH 접속을 허용해야 한다. UFW가 활성화되어 있는지 확인하고 SSH 접속을 허용하자:

```bash
sudo ufw status
sudo ufw allow ssh
```

비표준 포트를 사용하는 경우, 다음과 같이 포트를 지정하여 허용할 수 있다:

```bash
sudo ufw allow 2222/tcp
```

## SSH 접속하기

1. 클라이언트 컴퓨터에서 다음 명령어로 SSH 접속을 시도한다:

    ```bash
    ssh username@server_ip
    ```

    여기서 `username`은 서버의 사용자 이름이고, `server_ip`는 서버의 IP 주소이다. 비표준 포트를 사용하는 경우, 포트를 지정하여 접속할 수 있다:

    ```bash
    ssh -p 2222 username@server_ip
    ```

2. 처음 접속할 때는 서버의 신뢰성을 확인하는 메시지가 나타난다. "yes"를 입력하여 계속 진행하자.

3. 비밀번호를 입력하여 로그인한다.

## 보안 강화 팁

1. **강력한 비밀번호 사용**: 예측하기 어려운 강력한 비밀번호를 사용하자.
2. **공개키 인증 사용**: 비밀번호 대신 공개키 인증을 사용하여 보안을 강화하자.
3. **비표준 포트 사용**: 기본 포트 22 대신 다른 포트를 사용하여 무차별 대입 공격을 줄이자.
4. **fail2ban 설치**: 무차별 대입 공격을 방지하기 위해 `fail2ban`을 설치하자:

    ```bash
    sudo apt install fail2ban
    ```

5. **정기적인 업데이트 및 패치 적용**: 시스템과 패키지를 정기적으로 업데이트하여 보안을 유지하자.

## 결론

이제 Ubuntu 시스템에 SSH 서버를 설치하고 자동으로 실행되도록 설정하는 방법과, SSH 서버에 접속하는 방법을 알게 되었다. SSH는 원격 시스템 관리에 필수적인 도구이지만, 보안에 주의를 기울여야 한다. 위에서 제시한 보안 강화 팁을 따르면 더욱 안전한 SSH 환경을 구축할 수 있다.
