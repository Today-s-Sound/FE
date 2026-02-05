//
//  HelpView.swift
//  today-s-sound
//

import SwiftUI

struct HelpView: View {
  let theme: AppTheme

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        // MARK: - 서론

        introSection

        // MARK: - 이런 분들께 추천해요

        recommendSection

        // MARK: - 주요 기능 소개

        featureSection

        // MARK: - 이 앱의 특징

        characteristicsSection

        // MARK: - 문의하기

        contactSection

        // MARK: - 후원 안내

        sponsorSection
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 24)
    }
    .background(Color.background(theme))
  }

  // MARK: - 서론

  private var introSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("오늘의 소리란?")
        .font(.KoddiExtraBold32)
        .foregroundColor(Color.text(theme))
        .accessibilityAddTraits(.isHeader)

      VStack(alignment: .leading, spacing: 12) {
        Text("복잡한 웹사이트에서 필요한 정보를 찾다가 지쳐본 적 있으신가요?\n공지사항을 늦게 확인해서 마감 기한을 놓치거나 모르고 지나간 경험이 있나요?")
          .font(.KoddiRegular20)
          .foregroundColor(Color.text(theme))

        Text("오늘의 소리는 시각장애인을 위해 설계된 맞춤형 정보 구독 알림 서비스로, 필요한 정보만 빠르게 전달하는 데 집중합니다.")
          .font(.KoddiRegular20)
          .foregroundColor(Color.text(theme))

        Text("화면 구조가 복잡하거나 접근이 불편했던 웹사이트를 대신 확인하고, 핵심만 정리해 새로운 소식을 알려드립니다.")
          .font(.KoddiRegular20)
          .foregroundColor(Color.text(theme))

        Text("더 이상 웹사이트를 반복해 열어보지 않아도, 쉽고 빠르게 정보를 스스로 관리할 수 있는 경험을 제공합니다.")
          .font(.KoddiRegular20)
          .foregroundColor(Color.text(theme))
      }
    }
  }

  // MARK: - 이런 분들께 추천해요

  private var recommendSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("이런 분들께 추천해요")
        .font(.KoddiExtraBold32)
        .foregroundColor(Color.text(theme))
        .accessibilityAddTraits(.isHeader)

      VStack(alignment: .leading, spacing: 12) {
        bulletPoint("화면 탐색 없이 간결한 동작으로 정보를 빠르게 파악하고 싶은 시각장애인 및 저시력자")
        bulletPoint("불필요한 탐색 시간은 줄이고, 원하는 정보만 선별해 정보 피로를 줄이고 싶은 분")
        bulletPoint("뉴스, 자주 보는 공지사항의 새로운 글 등 오늘의 소리를 꾸준히 쉽게 확인하고 싶은 분")
      }
    }
  }

  // MARK: - 주요 기능 소개

  private var featureSection: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text("주요 기능 소개")
        .font(.KoddiExtraBold32)
        .foregroundColor(Color.text(theme))
        .accessibilityAddTraits(.isHeader)

      Text("오늘의 소리는 네 개의 탭으로 구성된 하단 바를 기본으로 동작합니다.")
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))

      // 홈 탭
      featureItem(
        title: "홈 탭",
        description: "최신 업데이트를 재생 버튼 하나로 확인할 수 있습니다. 구독 중인 웹페이지들에 올라온 새로운 글들을 앱에서 감지하여, 사용자 동작 없이 연속해서 라디오처럼 틀어두고 청취할 수 있습니다. 휴대폰 조작이 어려워도 빠르게 최신 소식을 쉽게 들을 수 있게 제공합니다."
      )

      // 피드 탭
      featureItem(
        title: "피드 탭",
        description: "최신 업데이트를 짧은 핵심 피드로 확인할 수 있습니다. 상단의 필터링 기능을 통해 구독 글을 모아서, 또는 웹페이지별로 필터링하여 나누어서 읽어볼 수 있습니다.\n\n각 피드는 웹페이지 이름, 새로운 글 제목, AI 요약된 본문, 업데이트 시간, 원문 보기 링크로 구성됩니다. 홈 탭에서 듣던 오늘의 소리를 직접 빠르게 읽어보고, 궁금한 소식은 원문 보기 버튼을 통해 원문을 열람해보세요."
      )

      // 알림 탭
      featureItem(
        title: "알림 탭",
        description: "사용자 맞춤 정보를 조회할 수 있습니다. 구독한 페이지에서 설정한 키워드가 포함된 글이나, 알림 설정한 페이지에서 글이 업로드되면 푸시 알림으로 전송해드립니다.\n\n알림들은 알림 탭에서도 확인하고 관리해보세요. 알림 종류에 따라 알림이 구분되어, 우선 확인해야 할 정보를 빠르게 판단할 수 있도록 지원합니다."
      )

      // 관리 탭
      VStack(alignment: .leading, spacing: 12) {
        Text("관리 탭")
          .font(.KoddiBold28)
          .foregroundColor(Color.text(theme))
          .accessibilityAddTraits(.isHeader)

        Text("총 5개의 항목으로 구독 페이지를 관리하고 다양한 맞춤 설정을 제공합니다.")
          .font(.KoddiRegular20)
          .foregroundColor(Color.text(theme))

        VStack(alignment: .leading, spacing: 8) {
          numberedItem(number: "1", text: "구독 페이지 관리 및 추가: 새롭게 구독할 페이지를 추가하고, 현재 구독 중인 페이지의 설정을 편집할 수도 있습니다. 손쉽게 페이지를 선택하고 키워드 필터를 통해 맞춤 정보를 더 빠르게 받아보세요.")
          numberedItem(number: "2", text: "재생 설정: 홈 탭에서 재생되는 오늘의 소리의 속도를 조절할 수 있습니다.")
          numberedItem(number: "3", text: "개발자에게 문의: 문의할 이메일 주소를 복사할 수 있습니다.")
          numberedItem(number: "4", text: "고대비 모드 설정: 일반 모드로 전환할 수 있습니다.")
          numberedItem(number: "5", text: "앱 초기화: 앱의 데이터를 모두 삭제하고 재시작할 수 있습니다.")
        }
      }

      // 유의사항
      Text("유의사항: 앱 설치 후 구독한 페이지가 없거나, 구독한 페이지에서 새로운 글이 올라오지 않으면 홈, 피드, 알림 탭에서 표시되는 내용이 없습니다. 구독한 페이지에서 새로운 글이 올라오면 홈 탭과 피드 탭에서 확인하실 수 있으며, 그중 특정 글들이 푸시 알림으로 발송 및 알림 탭에 표시됩니다.")
        .font(.KoddiRegular16)
        .foregroundColor(Color.text(theme).opacity(0.8))
    }
  }

  // MARK: - 이 앱의 특징

  private var characteristicsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("이 앱의 특징")
        .font(.KoddiExtraBold32)
        .foregroundColor(Color.text(theme))
        .accessibilityAddTraits(.isHeader)

      VStack(alignment: .leading, spacing: 12) {
        bulletPoint("맞춤형 웹 모니터링")
        bulletPoint("AI 요약 및 음성 알림")
        bulletPoint("관심 키워드 필터링")
        bulletPoint("시각장애인 유저 테스트 완료")
        bulletPoint("고대비의 간결한 레이아웃")
        bulletPoint("VoiceOver에 친화적인 접근성 중심 디자인")
      }
    }
  }

  // MARK: - 문의하기

  private var contactSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("문의하기")
        .font(.KoddiExtraBold32)
        .foregroundColor(Color.text(theme))
        .accessibilityAddTraits(.isHeader)

      Text("현재 앱에 존재하지 않는 웹사이트와 키워드 추가 요청, 기타 문의사항은 아래 이메일로 문의해주세요.")
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))

      Text("todaysound.official@gmail.com")
        .font(.KoddiBold20)
        .foregroundColor(Color.primaryGreen)
    }
  }

  // MARK: - 후원 안내

  private var sponsorSection: some View {
    Text("이 앱은 현대오토에버와 서울사회복지공동모금회의 지원으로 제작되었습니다.")
      .font(.KoddiRegular16)
      .foregroundColor(Color.text(theme).opacity(0.8))
      .padding(.bottom, 40)
  }

  // MARK: - Helper Views

  private func bulletPoint(_ text: String) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Text("•")
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))
      Text(text)
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))
    }
  }

  private func numberedItem(number: String, text: String) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Text("\(number).")
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))
      Text(text)
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))
    }
  }

  private func featureItem(title: String, description: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.KoddiBold28)
        .foregroundColor(Color.text(theme))
        .accessibilityAddTraits(.isHeader)
      Text(description)
        .font(.KoddiRegular20)
        .foregroundColor(Color.text(theme))
    }
  }
}

#Preview("도움말 - 라이트") {
  HelpView(theme: .normal)
}

#Preview("도움말 - 고대비") {
  HelpView(theme: .highContrast)
}
