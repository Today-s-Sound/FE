# ===== Config =====
SCHEME   ?= today-s-sound
PROJECT  ?= today-s-sound.xcodeproj
DEST     ?= platform=iOS Simulator,name=iPhone 16 Pro
CONFIG   ?= Debug
SDK      ?= iphonesimulator

.PHONY: fix check build test ci

# 코드 자동 수정(포맷) + 간단 린트
fix:
	@swiftformat .
	@swiftlint

# 수정 없이 체크만(실패 시 1)
check:
	@swiftformat . --lint
	@swiftlint --strict

# 시뮬레이터 빌드
build:
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)' -sdk $(SDK) -configuration $(CONFIG) clean build

# 테스트 타깃 없으므로 build로 대행
test: build
	@echo "(info) No tests configured; 'test' ran 'build'."

# 로컬에서 CI처럼 돌리기
ci: check build
