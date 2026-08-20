<div align="center">

# 🎧 오늘의 소리 · iOS

시각장애인을 위한 맞춤형 정보 구독 알림 서비스의 iOS 앱입니다.
구독한 웹페이지의 새 글 요약을 받아 음성으로 들려줍니다.

<img src="https://raw.githubusercontent.com/Today-s-Sound/.github/main/docs/screenshots/home.jpg" width="200"/>

[![App Store](https://img.shields.io/badge/App_Store-다운로드-0D96F6?style=flat-square&logo=appstore&logoColor=white)](https://apps.apple.com/kr/app/%EC%98%A4%EB%8A%98%EC%9D%98-%EC%86%8C%EB%A6%AC/id6756462316)
[![전체 문서](https://img.shields.io/badge/프로젝트_전체_문서-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Today-s-Sound)

![Swift](https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0071E3?style=flat-square&logo=swift&logoColor=white)
![SwiftLint](https://img.shields.io/badge/SwiftLint-FF5A5F?style=flat-square)
![SwiftFormat](https://img.shields.io/badge/SwiftFormat-4B8BBE?style=flat-square)

</div>

---

## 📂 디렉터리 구조

```
today-s-sound/
├─ .github/
│  └─ workflows/ci.yml
├─ today-s-sound.xcodeproj/      # Xcode 프로젝트
├─ today-s-sound/                # 앱 소스 루트
│  ├─ App/
│  │  └─ TodaySSoundApp.swift    # 앱 진입점
│  ├─ Core/                      # 앱 전역 인프라 계층
│  │  ├─ Network/                # APITargetType, Provider, Service, Targets
│  │  ├─ Auth/                   # UserSession, UserCredentialsProvider
│  │  ├─ Security/               # Keychain
│  │  ├─ AppState/               # SessionStore, AppThemeManager(고대비)
│  │  ├─ Pagination/
│  │  └─ Error/
│  ├─ Data/
│  │  └─ Models/                 # User, Subscription, Feed, Alarm, Keyword …
│  ├─ Presentation/
│  │  ├─ Base/Component/         # 공통 컴포넌트
│  │  └─ Features/               # Main, Feed, NotificationList,
│  │                             # SubscriptionList, AddSubscription,
│  │                             # OnBoarding, Settings
│  ├─ Services/
│  │  └─ SpeechService.swift     # 음성(TTS) 재생
│  ├─ Resources/
│  │  ├─ Fonts.swift / Colors.swift
│  │  └─ KoddiUDOnGothic-*.otf
│  ├─ Assets.xcassets/
│  └─ Info.plist
├─ .gitignore
├─ .swiftformat
├─ .swiftlint.yml
├─ Makefile
└─ README.md
```

화면(`Presentation/Features`)은 View / ViewModel / Model로 나누고, 네트워크·인증·저장 같은 공통 관심사는 `Core`에 둡니다.

---

## ♿️ 접근성 구현

이 앱의 주 사용자는 스크린리더 사용자입니다. 화면을 만들 때 다음을 기본으로 지킵니다.

- **VoiceOver 대응** — 모든 인터랙션 요소에 `accessibilityLabel`(71곳)과 `accessibilityHint`(42곳)를 부여하고, 장식용 요소는 `accessibilityHidden`으로 감춥니다. 카드처럼 묶어 읽어야 하는 영역은 `accessibilityElement(children:)`로 하나의 요소로 합칩니다.
- **음성 재생** — `Services/SpeechService.swift`에서 요약문을 TTS로 읽어 줍니다. 홈의 큰 재생 버튼 하나로 오늘 도착한 요약을 이어서 듣습니다.
- **고대비 모드** — `Core/AppState/AppThemeManager.swift`와 `Resources/Colors.swift`로 색상 세트를 전환합니다. 설정에서 켜고 끕니다.
- **서체** — 한국장애인개발원 **KoddiUD 온고딕**(Regular / Bold / ExtraBold)을 사용합니다.
- **터치 영역** — 주요 버튼은 크게, 화면당 조작 수는 적게 유지합니다.

새 화면을 추가할 때는 VoiceOver를 켠 상태에서 한 번 훑어 보고 PR을 올려 주세요.

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

---

## 🔗 관련 저장소

| 저장소                                                              | 설명                        |
| ------------------------------------------------------------------- | --------------------------- |
| [server](https://github.com/Today-s-Sound/server)                   | 백엔드 API · 배포/크롤링 문서 |
| [crawler](https://github.com/Today-s-Sound/crawler)                 | 구독 사이트 크롤러 (Python) |
| [terraform-infra](https://github.com/Today-s-Sound/terraform-infra) | AWS 인프라 IaC (Terraform)  |
