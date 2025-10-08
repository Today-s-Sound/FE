
import SwiftUI

struct AddSubscriptionView: View {
    @StateObject private var viewModel = AddSubscriptionViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color(white: 0.95))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 상단 바
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)

                    // 타이틀
                    Text("새 웹페이지 추가")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    ScrollView {
                        VStack(spacing: 24) {
                            // URL 입력 섹션
                            VStack(alignment: .leading, spacing: 12) {
                                Text("웹사이트 URL")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                TextField("https://www.example.com", text: $viewModel.urlText)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                                    )
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                Text("모니터링 할 웹페이지 URL을 입력하세요.")
                                    .font(.system(size: 13))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                            }

                            // 웹페이지 별명 섹션
                            VStack(alignment: .leading, spacing: 12) {
                                Text("웹페이지 별명")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                TextField("동국대학교 공지사항", text: $viewModel.nameText)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                                    )
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                Text("웹 페이지를 식별할 명칭을 입력하세요.")
                                    .font(.system(size: 13))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                            }

                            // 키워드 벡터 섹션
                            VStack(alignment: .leading, spacing: 12) {
                                Text("키워드 벡터")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                TextField("장학금, 교직, 학생회", text: $viewModel.keywordsText)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                                    )
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                HStack(spacing: 8) {
                                    KeywordBadge(text: "장학금", colorScheme: colorScheme)
                                    KeywordBadge(text: "교직부공지사항", colorScheme: colorScheme)
                                }

                                Text("관심 키워드가 포함된 내용을 걸러낼 필요가 있으면 입력하세요.")
                                    .font(.system(size: 13))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                            }

                            // 긴급 알림으로 설정 토글
                            HStack {
                                Text("긴급 알림으로 설정")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Toggle("", isOn: $viewModel.isUrgent)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                            )

                            // 하단 버튼
                            Button(action: {}) {
                                Text("등록 승인 요청")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.9))
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct KeywordBadge: View {
    let text: String
    let colorScheme: ColorScheme

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.2))
            )
    }
}

struct AddSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubscriptionView()
    }
}
