---
title: "리눅스 논리 볼륨 관리자(LVM) 이해하기"
date: 2025-02-21T04:17:24+09:00
draft: false
description: "리눅스의 논리 볼륨 관리자(LVM)의 개념과 구성 요소를 이해하고, 실제 환경에서의 구축과 관리 방법을 상세히 설명합니다."
tags: ["LVM", "스토리지", "파티션", "볼륨관리", "서버관리"]
---

리눅스 시스템에서 스토리지 관리는 시스템 관리자가 직면하는 가장 중요한 과제 중 하나다. LVM(Logical Volume Manager)은 물리적 디스크를 논리적 단위로 추상화하여 유연한 스토리지 관리를 가능하게 한다.

## LVM의 기본 구조

LVM은 세 가지 핵심 계층으로 구성된다:

### 물리 볼륨 (Physical Volume)

실제 디스크나 파티션을 LVM이 사용할 수 있도록 초기화한 상태다. `/dev/sda1`, `/dev/sdb` 같은 물리적 저장 장치가 여기에 해당한다.

### 볼륨 그룹 (Volume Group)

여러 물리 볼륨을 하나의 스토리지 풀로 통합한 것이다. 이 단계에서 물리적 디스크의 경계가 사라지고 하나의 큰 저장 공간이 된다.

### 논리 볼륨 (Logical Volume)

볼륨 그룹에서 필요한 만큼 할당받아 실제로 사용하는 볼륨이다. 파일시스템이 생성되는 대상이다.

## LVM 구성 과정

실제 LVM 구성은 다음과 같은 단계로 진행된다:

### 기본 구성

```bash
# 1. 물리 볼륨 생성
pvcreate /dev/sdb

# 2. 볼륨 그룹 생성
vgcreate vg_data /dev/sdb

# 3. 논리 볼륨 생성
lvcreate -n lv_data -L 100G vg_data
```

## 모니터링과 관리

### 용량 모니터링

```bash
# 물리 볼륨 상태
pvs
PV         VG      Fmt  Attr PSize   PFree
/dev/sda2  vg_data lvm2 a--  100.00g 20.00g
/dev/sdb1  vg_data lvm2 a--  100.00g 10.00g

# 볼륨 그룹 상태
vgs
VG      #PV #LV #SN Attr   VSize   VFree
vg_data   2   2   0 wz--n- 199.99g 30.00g
```

## 백업과 복구

LVM에서는 스냅샷을 통한 백업과 복구가 가능하다:

### 스냅샷 생성과 복구

```bash
# 스냅샷 생성
lvcreate -s -n snap_data -L 10G /dev/vg_data/lv_data

# 스냅샷으로부터 복구
lvconvert --merge /dev/vg_data/snap_data
```

## 성능 최적화

LVM 성능은 여러 요소에 의해 영향을 받는다:

1. 물리 확장(PE) 크기 최적화
2. 스트라이핑 설정
3. 캐시 활용
4. I/O 스케줄러 조정
