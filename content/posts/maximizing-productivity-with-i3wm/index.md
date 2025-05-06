---
title: "i3wm으로 생산성 극대화하기"
date: 2025-05-05T22:01:34+09:00
draft: false
description: "i3 윈도우 매니저의 설치부터 기본 설정까지, 효율적인 워크플로우 구성법"
tags:
    [
        "리눅스",
        "i3wm",
        "타일링 윈도우 매니저",
        "생산성",
        "커스터마이징",
        "경량",
        "키보드 중심",
        "워크스페이스",
        "X11",
        "Wayland",
        "설치 가이드",
    ]
---

## 서론

![i3wm 기본 레이아웃](image.png)

i3 윈도우 매니저(i3wm)는 효율성과 생산성에 초점을 맞춘 타일링 윈도우 매니저로, 2009년 Michael Stapelberg에 의해 처음 개발되었다. C언어로 작성된 i3는 가벼우면서도 강력한 기능을 제공하며, 특히 키보드 중심의 워크플로우를 선호하는 개발자와 파워 유저들 사이에서 큰 인기를 얻고 있다. i3는 X Window System 환경에서 동작하며, 최근에는 Wayland 호환 버전인 Sway도 널리 사용되고 있다. 불필요한 시각적 요소를 최소화하고 화면 공간을 최대한 활용하는 철학을 바탕으로, 다중 모니터 지원, 효율적인 창 관리, 그리고 높은 수준의 사용자 정의 기능을 제공한다.

i3wm은 뛰어난 공식 문서화로 유명하다. 모든 기능과 설정이 명확하게 기술되어 있어 초보자도 쉽게 시작하고 환경을 구성할 수 있다. 공식 문서는 [i3wm.org/docs](https://i3wm.org/docs/)에서 확인할 수 있다.

### 타일링 시스템

![i3wm 타일링 레이아웃 예시](image-1.png)

i3wm의 가장 기본적인 특징은 '타일링' 창 배치 방식이다. 전통적인 스태킹 윈도우 매니저(GNOME, KDE 등)와 달리, i3는 화면을 분할하여 창들을 자동으로 정렬해 겹치지 않고 화면 공간을 최대한 활용한다.

**주요 타일링 특성:**

-   **자동 레이아웃**: 새 창이 열리면 자동으로 기존 공간을 분할
-   **방향성 분할**: 수평/수직 방향으로 공간 분할
-   **비율 조절**: 분할된 창 사이의 경계 크기 조절
-   **레이아웃 전환**: 타일링, 스태킹, 탭 모드 간 즉시 전환

i3의 기본 타일링 알고리즘은 이진 트리(binary tree) 구조를 기반으로 한다. 사용자가 새 창을 열 때마다 현재 선택된 창의 공간이 둘로 나뉘며, 분할 방향은 설정 또는 모드에 따라 결정된다.

## i3wm 설치하기

다양한 리눅스 배포판에서 i3wm을 쉽게 설치할 수 있다.

**Debian/Ubuntu 계열**: `sudo apt install i3`

**Fedora**: `sudo dnf install i3`

**Arch Linux**: `sudo pacman -S i3-wm`

설치 후 로그아웃하고 로그인 화면에서 i3 세션을 선택한다. 첫 실행 시 설정 파일 생성 여부와 mod 키 설정을 물어보는 창이 나타난다. mod 키는 보통 Alt(Mod1) 또는 윈도우 키(Mod4)로 설정한다.

![i3wm 첫 실행 화면](image-2.png)

## 기본 키 조합

i3wm은 키보드 중심의 환경을 제공하기 때문에, 기본 키 조합을 익히는 것이 중요하다.

![i3wm 키보드 단축키 참조-1](image-3.png)
![i3wm 키보드 단축키 참조-2](image-4.png)

### 기본 제어

-   **$mod + Enter**: 기본 터미널 실행
-   **$mod + d**: 어플리케이션 실행 메뉴 열기
-   **$mod + Shift + q**: 현재 창 닫기
-   **$mod + Shift + r**: i3 설정 다시 불러오기
-   **$mod + Shift + e**: i3 종료 메뉴
-   **$mod + Shift + c**: i3 설정 파일 다시 불러오기

### 창 관리

-   **$mod + j/k/l/;**: 좌/하/상/우 방향으로 창 이동 (기본값)
-   **$mod + Shift + j/k/l/;**: 현재 창을 좌/하/상/우 방향으로 이동
-   **$mod + f**: 현재 창 전체화면 토글
-   **$mod + h**: 다음 창 수평 분할
-   **$mod + v**: 다음 창 수직 분할
-   **$mod + r**: 크기 조절 모드
-   **$mod + space**: 타일링/플로팅 모드 전환

i3wm은 vim과 달리 jkl;를 방향키로 사용한다. 필요시 설정 파일에서 hjkl 스타일로 변경 가능하다. 개인적으로는 hjkl를 방향키로 사용하는 것이 더 편리하다고 느꼈다.

### 워크스페이스 관리

-   **$mod + 숫자(1-0)**: 해당 번호의 워크스페이스로 이동
-   **$mod + Shift + 숫자(1-0)**: 현재 창을 해당 워크스페이스로 이동

## i3wm 설정 파일 구성하기

i3wm의 설정은 텍스트 기반 설정 파일(`~/.config/i3/config`)을 통해 이루어진다.

### 설정 파일 내용

1. 기본 변수 설정(mod 키, 폰트 등)
2. 자동 실행 프로그램 설정
3. 다크 모드 및 전원 관리 설정
4. 미디어 키 바인딩
5. 기본 창 조작 키 바인딩
6. 워크스페이스 설정
7. 창 스타일 및 색상 설정
8. 바(i3bar) 설정

### 설정 예시

```bash
# 기본 변수 설정
set $mod Mod1
font pango:JetBrains Mono 10

# 기본 프로그램
bindsym $mod+Return exec alacritty
bindsym $mod+d exec --no-startup-id rofi -show drun

# 창 이동 기본값 (jkl;)
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# 창 분할 방식
bindsym $mod+h split h
bindsym $mod+v split v
```

## 워크스페이스 효율적으로 활용하기

i3wm의 워크스페이스 시스템은 작업 관리에 매우 효율적이다. 기본적으로 10개의 워크스페이스가 제공된다.

### 워크스페이스 설정

```bash
# 워크스페이스 정의 (간결한 숫자 이름)
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"

# 워크스페이스 전환
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2

# 윈도우 워크스페이스 이동
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
```

나의 설정에서는 단순히 숫자만 사용한 간결한 워크스페이스 이름을 사용하고 있다. 필요에 따라 숫자 뒤에 콜론과 설명을 추가할 수도 있다.

## i3bar와 i3status 커스터마이징

i3wm은 화면 하단(또는 상단)에 상태 표시줄을 제공한다. 이 표시줄은 i3bar와 i3status 컴포넌트로 구성된다.

### i3bar 설정

```bash
bar {
    position bottom
    status_command i3status
    tray_output primary
    font pango:JetBrains Mono 10

    mode hide  # 평소에는 숨김
    hidden_state hide
    modifier $mod

    colors {
        background #1c1c1c
        statusline #c0c5ce
        focused_workspace  #2b303b #2b303b #c0c5ce
        inactive_workspace #1c1c1c #1c1c1c #888888
    }
}
```

주요 특징: 평소에는 숨겨졌다가 $mod 키를 누를 때만 표시되며, 다크 테마 기반 색상을 사용하고, 마우스 휠로 볼륨 조절이 가능하다.

## 생산성 향상을 위한 팁

### 리사이즈 모드

창 크기를 정밀하게 조절하는 리사이즈 모드:

```bash
mode "resize" {
    # 크기 조절 바인딩
    bindsym j resize shrink width 10 px or 10 ppt
    bindsym k resize grow height 10 px or 10 ppt
    bindsym l resize shrink height 10 px or 10 ppt
    bindsym semicolon resize grow width 10 px or 10 ppt

    # 모드 빠져나가기
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
```

### 키 바인딩 커스터마이징

기본 jkl; 배열을 VI 편집기 스타일의 hjkl 키로 변경:

```bash
# VI 스타일 hjkl 변경
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# 창 분할키 변경 (h가 이미 사용됨)
bindsym $mod+b split h  # 수평 분할
```

### 유용한 단축키 설정

```bash
# 스크린샷
bindsym Print exec --no-startup-id scrot '%Y-%m-%d_%H-%M-%S.png' -e 'mv $f ~/Pictures/'

# 시스템 제어
bindsym $mod+Shift+x exec xtrlock  # 화면 잠금
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m '종료하시겠습니까?'"
```

더 자세한 설정 예시와 내가 실제 사용 중인 설정은 GitHub 레포지토리([github.com/in-jun/i3wm-setup](https://github.com/in-jun/i3wm-setup))에서 확인할 수 있다.

## 결론

i3wm은 전통적인 데스크톱 환경과 다른 접근 방식을 취하지만, 익숙해지면 놀라운 생산성 향상을 경험할 수 있다. 키보드 중심의 인터페이스, 효율적인 창 관리, 높은 사용자화 가능성은 개발자와 파워 유저들에게 매력적이다.

학습 곡선은 다소 가파를 수 있지만, 공식 문서가 매우 상세하게 작성되어 있어 참고하기 좋다.
