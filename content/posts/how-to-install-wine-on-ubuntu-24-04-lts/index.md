---
title: "우분투 24.04 LTS Wine 설치"
date: 2025-02-23T04:51:24+09:00
draft: false
description: "우분투 24.04 LTS에서 Wine을 설치하고 설정하는 방법을 다룬다."
tags: ["Linux", "Ubuntu", "Wine"]
---

## Wine의 개념과 작동 원리

Wine(Wine Is Not an Emulator)은 Ubuntu 24.04 LTS를 포함한 Linux, macOS, BSD와 같은 UNIX 호환 운영체제에서 Windows 프로그램을 실행할 수 있게 해주는 호환성 레이어(Compatibility Layer)로, 1993년 Bob Amstadt와 Eric Youngdale에 의해 시작된 오픈 소스 프로젝트이며 30년 이상의 개발 역사를 가지고 있다. Wine의 이름은 재귀적 약어로 "Wine Is Not an Emulator"를 의미하며, 이는 Wine이 단순한 에뮬레이터가 아니라는 점을 강조하기 위해 선택되었다.

Wine은 가상 머신이나 에뮬레이터와는 근본적으로 다른 방식으로 작동하며, Windows API 호출을 실시간으로 POSIX 호환 시스템 호출로 변환하는 역할을 수행한다. 가상화 소프트웨어인 VirtualBox나 VMware는 완전한 Windows 운영체제를 가상 환경에서 실행하므로 상당한 시스템 리소스를 소비하는 반면, Wine은 Windows 프로그램이 호출하는 API(Application Programming Interface) 함수들을 Linux 시스템이 이해할 수 있는 형태로 변환하여 네이티브에 가까운 성능을 제공한다. 예를 들어 Windows 프로그램이 파일을 열기 위해 `CreateFile` 함수를 호출하면 Wine은 이를 리눅스의 `open` 시스템 콜로 변환하여 실행한다.

### Wine의 주요 특징과 장점

Wine은 별도의 가상 머신이나 Windows 라이선스 없이도 작동하므로 시스템 리소스를 효율적으로 사용하며, 가상화 방식에 비해 메모리 사용량이 적고 프로그램 실행 속도가 빠르다. DirectX, OpenGL, Vulkan과 같은 그래픽 API를 지원하여 Windows 게임을 실행할 수 있으며, 특히 Valve의 Proton(Wine 기반)을 통해 Steam 게임들이 Linux에서 실행 가능하다. Microsoft Office, Adobe 제품군, 각종 비즈니스 소프트웨어 등 다양한 Windows 전용 프로그램을 Ubuntu에서 사용할 수 있어, Linux로의 전환을 고려하는 사용자들에게 필수적인 도구로 자리잡았다.

### Wine의 한계

모든 Windows 프로그램이 Wine에서 완벽하게 작동하는 것은 아니며, 특히 커널 수준 드라이버를 필요로 하는 프로그램(안티치트 시스템을 사용하는 게임, 하드웨어 직접 제어 프로그램)이나 최신 Windows API를 사용하는 프로그램은 실행되지 않거나 오류가 발생할 수 있다. Wine 프로젝트는 지속적으로 Windows API 호환성을 개선하고 있지만, Microsoft가 새로운 Windows 버전을 출시할 때마다 Wine 개발팀은 이를 따라잡아야 하는 과제를 안고 있다. WineHQ 데이터베이스(https://www.winehq.org/search)에서 특정 프로그램의 Wine 호환성을 미리 확인할 수 있으며, 각 프로그램은 Platinum(완벽), Gold(설정 후 완벽), Silver(사소한 문제), Bronze(심각한 문제), Garbage(실행 불가)로 평가된다.

## Ubuntu 24.04 LTS에 Wine 설치하기

### 1. 시스템 준비

Wine 설치를 시작하기 전에 시스템을 최신 상태로 업데이트하는 것이 중요하며, 이는 패키지 저장소 정보를 최신화하고 기존 패키지들을 업그레이드하여 의존성 충돌을 방지하기 위함이다.

```bash
sudo apt update
sudo apt upgrade
```

`apt update`는 패키지 저장소의 메타데이터를 새로고침하여 최신 패키지 목록을 가져오고, `apt upgrade`는 설치된 패키지들을 사용 가능한 최신 버전으로 업그레이드한다.

#### 32비트 아키텍처 지원 활성화

많은 Windows 프로그램과 게임이 32비트로 컴파일되어 있으므로, 64비트 Ubuntu 24.04 LTS에서도 32비트 라이브러리를 설치하고 실행할 수 있도록 멀티아키텍처 지원을 활성화해야 한다. Ubuntu는 기본적으로 64비트(amd64) 아키텍처만 활성화되어 있으며, i386(32비트) 아키텍처는 수동으로 추가해야 한다.

```bash
sudo dpkg --add-architecture i386
```

이 명령어는 dpkg 패키지 관리 시스템에 i386 아키텍처를 추가하며, 이후 `apt` 명령어로 32비트 패키지를 설치할 수 있게 된다. Wine은 내부적으로 수많은 32비트 라이브러리를 사용하므로 이 단계는 필수적이며, 생략하면 Wine 설치 시 의존성 오류가 발생한다.

### 2. WineHQ 공식 저장소 추가

Ubuntu의 기본 저장소에도 Wine이 포함되어 있지만, WineHQ 공식 저장소를 사용하면 최신 안정 버전과 개발 버전을 선택할 수 있고 더 빠른 업데이트를 받을 수 있다. WineHQ는 Wine 프로젝트의 공식 웹사이트이자 저장소로, Stable(안정), Development(개발), Staging(실험) 세 가지 버전의 Wine을 제공한다.

#### GPG 키 추가

패키지 저장소의 신뢰성을 검증하기 위해 WineHQ의 GPG(GNU Privacy Guard) 공개 키를 시스템에 추가해야 하며, 이는 다운로드하는 패키지가 WineHQ에서 서명한 정품임을 확인하여 중간자 공격이나 악의적인 패키지 설치를 방지하기 위함이다.

```bash
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
```

첫 번째 명령어는 `/etc/apt/keyrings` 디렉토리를 생성하며 `-p` 옵션으로 상위 디렉토리도 함께 생성하고 `-m755` 옵션으로 적절한 권한을 설정한다. 두 번째 명령어는 WineHQ의 GPG 키를 다운로드하여 해당 디렉토리에 저장하며, Ubuntu 24.04부터는 보안 강화를 위해 `/etc/apt/keyrings` 디렉토리를 사용하는 것이 권장된다.

#### Wine 저장소 파일 추가

WineHQ 저장소 정보를 시스템에 추가하며, `lsb_release -sc` 명령어를 사용하여 현재 Ubuntu 버전의 코드명(noble)을 자동으로 감지하고 해당 버전에 맞는 저장소를 설정한다.

```bash
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources
```

이 명령어는 Ubuntu 24.04 LTS(코드명: noble)의 경우 `winehq-noble.sources` 파일을 다운로드하며, `-N` 옵션은 서버의 파일이 더 최신일 때만 다운로드하고 `-P` 옵션은 저장 위치를 지정한다. 다운로드된 `.sources` 파일은 DEB822 형식을 사용하여 저장소 정보를 기술하며, 이는 Ubuntu 22.04 이후 도입된 현대적인 저장소 관리 방식이다.

### 3. Wine 설치

새로운 저장소를 추가했으므로 패키지 목록을 다시 업데이트하여 WineHQ 저장소의 패키지 정보를 가져오고, 이후 안정 버전의 Wine을 설치한다.

```bash
sudo apt update
sudo apt install --install-recommends winehq-stable
```

`apt update` 명령어는 방금 추가한 WineHQ 저장소를 포함한 모든 저장소의 패키지 메타데이터를 갱신하며, `winehq-stable`은 WineHQ의 안정 버전 패키지를 의미한다. `--install-recommends` 옵션은 Wine이 권장하는 추가 패키지들을 함께 설치하도록 지시하며, 여기에는 Mono(Windows .NET Framework 호환성), Gecko(Internet Explorer 호환성), 그래픽 드라이버, 오디오 라이브러리 등이 포함되어 있어 대부분의 Windows 프로그램이 정상적으로 작동하는 데 필요하다.

#### Wine 버전 선택

WineHQ는 세 가지 버전의 Wine을 제공하며, 각 버전은 안정성과 최신 기능 간의 균형이 다르다.

-   **winehq-stable**: 안정 버전으로 철저한 테스트를 거쳐 출시되며, 프로덕션 환경이나 일반 사용자에게 권장된다. 최신 기능은 부족할 수 있지만 안정성이 보장된다.
-   **winehq-devel**: 개발 버전으로 최신 기능과 버그 수정을 포함하지만, 새로운 버그가 도입될 수 있으므로 테스트 목적이나 최신 기능이 필요한 사용자에게 적합하다.
-   **winehq-staging**: 실험 버전으로 아직 메인 브랜치에 병합되지 않은 실험적인 패치들을 포함하며, 특정 게임이나 프로그램의 호환성을 위해 필요한 경우에만 사용하는 것이 좋다.

일반적으로는 `winehq-stable`을 설치하는 것이 가장 안전하며, 설치 후에도 `sudo apt install winehq-devel` 명령어로 다른 버전으로 변경할 수 있다.

### 4. Wine 초기 설정

Wine 설치가 완료되면 Wine 환경을 초기화하고 설정을 구성해야 하며, `winecfg` 명령어를 사용하여 Wine 설정 도구를 실행한다.

```bash
winecfg
```

이 명령어를 처음 실행하면 Wine은 홈 디렉토리에 `~/.wine` 디렉토리를 생성하고 기본 Windows 환경을 구축한다. 이 디렉토리는 Wine prefix라고 불리며, Windows의 `C:\` 드라이브에 해당하는 가상 파일 시스템과 레지스트리 파일들을 포함한다. Wine은 `C:\windows`, `C:\Program Files`, `C:\users` 등의 디렉토리 구조를 생성하여 Windows 프로그램이 예상하는 환경을 제공하며, 각 프로그램이 설치된 파일과 설정은 이 prefix 내에 저장된다.

![와인 설정 화면](image.png)

#### Wine 설정 도구 주요 옵션

winecfg 설정 창에서는 다양한 옵션을 조정할 수 있으며, 각 탭은 특정 영역의 설정을 담당한다.

-   **Applications 탭**: Windows 버전을 설정하며, Wine이 Windows XP, Vista, 7, 8, 10, 11 중 어떤 버전으로 동작할지 선택할 수 있다. 프로그램에 따라 특정 Windows 버전을 요구하는 경우가 있으므로, 프로그램별로 다른 버전을 설정할 수도 있다.
-   **Libraries 탭**: DLL(Dynamic Link Library) 파일의 로드 순서를 설정하며, Wine 내장 DLL을 사용할지 네이티브 Windows DLL을 사용할지 선택할 수 있다. 일부 프로그램은 특정 DLL이 네이티브 모드로 실행되어야 정상 작동하므로 이 설정이 중요하다.
-   **Graphics 탭**: 화면 해상도, 가상 데스크톱 모드, DPI 설정 등을 조정하며, 가상 데스크톱을 활성화하면 Windows 프로그램이 별도의 창에서 실행되어 Linux 데스크톱과 분리된다.
-   **Audio 탭**: 오디오 드라이버를 선택하며, ALSA, PulseAudio, OSS 등의 옵션이 있고 Ubuntu 24.04에서는 PulseAudio나 PipeWire를 사용하는 것이 일반적이다.

### 5. DirectX 라이브러리 설정

많은 Windows 프로그램과 게임이 DirectX를 사용하여 그래픽을 렌더링하며, DirectX는 Microsoft가 개발한 멀티미디어 및 게임 프로그래밍 API 모음으로 Direct3D, DirectSound, DirectInput 등의 컴포넌트로 구성되어 있다. Wine은 DirectX를 부분적으로 지원하지만, 일부 DirectX DLL 파일은 명시적으로 로드되도록 설정해야 하며 특히 Direct3D 11과 관련된 `d3dx11_43.dll`은 많은 최신 게임과 3D 애플리케이션에서 필수적으로 요구된다.

#### DirectX DLL 재정의 설정

Wine 설정에서 특정 DLL을 네이티브 모드로 로드하도록 설정하면 Windows DLL을 직접 사용하여 호환성이 향상되며, 다음 단계를 따라 설정한다.

1. Wine 설정 도구를 실행한다.

```bash
winecfg
```

2. "라이브러리(Libraries)" 탭으로 이동한다.
3. "새 라이브러리 재정의(New override for library)" 드롭다운 메뉴에서 `d3dx11_43`을 입력하거나 선택한다.

![와인 설정 화면](image-1.png)

4. "추가(Add)" 버튼을 클릭하여 재정의 목록에 추가한다.
5. "적용(Apply)" 버튼을 누르고 "확인(OK)"으로 설정을 저장한다.

이 설정을 통해 Wine은 `d3dx11_43.dll`을 네이티브 우선(Native then Builtin) 모드로 로드하며, 이는 Windows의 원본 DLL을 먼저 찾아 사용하고 없으면 Wine 내장 구현을 사용한다는 의미이다.

#### 추가 DirectX 구성 요소 설치

더 많은 DirectX 기능을 사용하려면 Winetricks를 사용하여 추가 구성 요소를 설치할 수 있으며, Winetricks는 Wine에서 자주 필요한 라이브러리와 설정을 자동으로 설치해주는 스크립트 도구이다.

```bash
sudo apt install winetricks
winetricks d3dx9 d3dx10 d3dx11_43 dxvk
```

이 명령어는 DirectX 9, 10, 11의 핵심 라이브러리와 DXVK(DirectX를 Vulkan으로 변환하는 레이어)를 설치하며, DXVK는 DirectX 11과 12 게임의 성능을 크게 향상시키는 것으로 알려져 있다.

### 6. Windows 프로그램 실행

Wine 설정이 완료되면 Windows 실행 파일(.exe)을 직접 실행할 수 있으며, 터미널에서 `wine` 명령어와 함께 프로그램 경로를 지정하거나 파일 관리자에서 더블 클릭하여 실행할 수 있다.

```bash
wine program.exe
```

예를 들어 다운로드 폴더에 있는 `setup.exe` 설치 파일을 실행하려면 다음과 같이 입력한다.

```bash
wine ~/Downloads/setup.exe
```

프로그램이 설치되면 Wine은 자동으로 `~/.wine/drive_c/Program Files` 디렉토리에 프로그램을 설치하며, 설치된 프로그램은 메뉴나 바탕화면에 바로가기가 생성되어 다음번부터는 클릭만으로 실행할 수 있다.

#### 명령줄 옵션과 환경 변수

Wine은 다양한 환경 변수와 옵션을 지원하여 프로그램 실행을 제어할 수 있으며, 대표적인 환경 변수는 다음과 같다.

-   **WINEPREFIX**: Wine prefix 경로를 지정하여 여러 개의 독립적인 Wine 환경을 사용할 수 있다.

```bash
WINEPREFIX=~/.wine-custom wine program.exe
```

-   **WINEDEBUG**: 디버그 메시지 출력을 제어하며, `-all`로 설정하면 모든 디버그 메시지를 숨긴다.

```bash
WINEDEBUG=-all wine program.exe
```

-   **WINEARCH**: Wine 아키텍처를 지정하며, `win32`는 32비트, `win64`는 64비트를 의미한다.

```bash
WINEARCH=win32 WINEPREFIX=~/.wine32 winecfg
```

#### 파일 관리자에서 실행

Ubuntu의 파일 관리자(Nautilus)에서 `.exe` 파일을 더블 클릭하면 자동으로 Wine이 실행되며, 이는 Wine 설치 시 파일 연결(File Association)이 자동으로 설정되기 때문이다. 만약 더블 클릭이 작동하지 않으면 파일을 마우스 오른쪽 버튼으로 클릭하고 "다른 애플리케이션으로 열기(Open with another application)"를 선택한 후 Wine을 선택한다.

## 문제 해결

### 프로그램이 실행되지 않는 경우

프로그램이 실행되지 않거나 오류가 발생하는 경우 다음 방법들을 시도할 수 있다.

-   **WineHQ AppDB 확인**: https://appdb.winehq.org에서 해당 프로그램의 호환성 정보와 특별한 설정을 확인한다.
-   **Windows 버전 변경**: `winecfg`에서 다른 Windows 버전으로 설정을 변경한다.
-   **DLL 재정의**: 특정 DLL을 네이티브 모드로 로드하도록 설정한다.
-   **디버그 로그 확인**: `WINEDEBUG=+all wine program.exe 2>&1 | tee wine.log` 명령어로 상세한 로그를 생성하여 오류 원인을 파악한다.

### 한글이 깨지는 경우

Windows 프로그램에서 한글이 깨져 보이는 경우 Windows 한글 폰트를 설치하면 해결된다.

```bash
winetricks corefonts cjkfonts
```

이 명령어는 Windows의 기본 폰트와 한중일(CJK) 폰트를 Wine 환경에 설치한다.

### 성능이 느린 경우

프로그램이나 게임의 성능이 느린 경우 DXVK를 설치하여 DirectX를 Vulkan으로 변환하면 성능이 크게 향상될 수 있다.

```bash
winetricks dxvk
```

## 결론

Ubuntu 24.04 LTS에 Wine을 설치하면 Windows 전용 프로그램을 Linux 환경에서 실행할 수 있으며, 가상 머신 없이도 비즈니스 소프트웨어, 게임, 유틸리티 등을 사용할 수 있어 Linux로의 전환 장벽을 낮출 수 있다. Wine은 30년 이상의 개발 역사를 가진 성숙한 프로젝트로 지속적으로 Windows API 호환성을 개선하고 있으며, Valve의 Proton을 통해 게이밍 분야에서도 활발히 사용되고 있다. 모든 Windows 프로그램이 완벽하게 작동하는 것은 아니지만, 적절한 설정과 추가 구성 요소 설치를 통해 대부분의 프로그램을 실행할 수 있으며, WineHQ AppDB와 커뮤니티의 도움을 받으면 특정 프로그램의 호환성 문제를 해결하는 데 큰 도움이 된다.
