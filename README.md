# 🎧 오늘의 소리

## 📂 디렉터리 구조

```
today-s-sound/
├─ .github/                      
│  └─ workflows/ci.yml
├─ today-s-sound.xcodeproj/      # Xcode 프로젝트
├─ today-s-sound/                # 앱 소스 루트
│  ├─ Preview Content/
│  ├─ App/
│  │  └─ TodaySSoundApp.swift
│  ├─ Features/
│  │  └─ Home/
│  │     ├─ HomeModel.swift
│  │     ├─ HomeView.swift
│  │     └─ HomeViewModel.swift
│  ├─ Services/
│  │  └─ Network/
│  ├─ Resources/
│  │  ├─ Fonts.swift
│  │  └─ KoddiUDOnGothic-*.otf
│  ├─ Assets.xcassets/
│  └─ Info.plist
├─ .gitignore
├─ .swiftformat
├─ .swiftlint.yml
├─ Makefile
└─ README.md
```

---

## 🌱 브랜치 전략

* 기본 브랜치: `main`, 작업 브랜치 분기: `dev`
* **작업 흐름**

  1. `dev`에서 새 브랜치 생성

     * 브랜치명: `토픽/#이슈번호` (예: `feature/#123`)
  2. 작업 후 **PR 대상은 항상 `dev`**
  3. 코드리뷰/CI 통과 후 `dev`에 머지 → 이후 운영 전략에 따라 `main` 반영

---

## ✍️ 커밋 & PR 컨벤션

* **이슈 제목 / PR 제목 / 커밋 메시지(Title) 통일**

  * 포맷: 템플릿에 맞춰 이슈 생성 후, 커밋 메시지 제목 및 PR 제목은 **`[토픽/#이슈번호] 제목`**으로 작성
  * 예: `[Feature/#123] 홈 화면 녹음 버튼 추가`
* **본문(Description)**: 변경 사항을 **줄바꿈 리스트**로 간단히

  * 커밋 메시지 예:
  
    [Feature/#123] 홈 화면 녹음 버튼 추가
      * 녹음 시작/정지 토글 추가
      * 접근성 라벨 보강
      * 리소스 경로 정리
* **토픽(타입) 목록** *(내용은 라벨을 참고)*
  
  `Feature`, `Fix`, `Refactor`, `Chore`, `Setting`, `Deploy`

---

## 🧪 로컬 검사 명령어

> 커밋/푸시 전에 아래 순서로 실행해 주세요.

```bash
# 1) 자동 포맷 + 린트(느슨)
make fix

# 2) 수정 없이 검사(엄격)
make check

# 3) 시뮬레이터 빌드
make build

# 4) CI와 유사하게 한 번에(체크 + 빌드)
make ci
```

> 현재 테스트 타깃 미구성 → `make test`는 `build`를 대행하도록 설정되어 있습니다.

---

## 🚦 PR에서 자동 검사(CI)

* 워크플로: `.github/workflows/ci.yml`
* 트리거: `pull_request` (모든 PR에서 자동 실행)
* 수행: SwiftFormat 체크 → SwiftLint 엄격 모드 → iOS 시뮬레이터 빌드
