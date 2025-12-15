//
//  ButtonPracticeView.swift
//  today-s-sound
//
//  Button 스타일링 연습용 뷰
//

import SwiftUI

struct ButtonPracticeView: View {
  @State private var count = 0
  @State private var isEnabled = true
  @EnvironmentObject var appTheme: AppThemeManager

  var body: some View {
    ScrollView {
      VStack(spacing: 30) {
        // 제목
        Text("Button 스타일링 연습")
          .font(.KoddiBold28)
          .foregroundColor(Color.text(appTheme.theme))
          .padding(.top, 20)

        // ============================================
        // 1. 기본 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("1. 기본 Button")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button("클릭하세요") {
            count += 1
          }
          .font(.KoddiBold18)
          .foregroundColor(.white)
          .padding()
          .background(Color.primaryGreen)
          .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 2. 아이콘 + 텍스트 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("2. 아이콘 + 텍스트 Button")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button(action: {
            count += 1
          }) {
            HStack {
              Image(systemName: "plus.circle.fill")
              Text("증가")
            }
            .font(.KoddiBold18)
            .foregroundColor(.white)
            .padding()
            .background(Color.primaryGreen)
            .cornerRadius(8)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 3. 전체 너비 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("3. 전체 너비 Button (maxWidth: .infinity)")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button("전체 너비 버튼") {
            count += 1
          }
          .font(.KoddiBold18)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity) // 👈 이게 핵심!
          .padding(.vertical, 16)
          .background(Color.primaryGreen)
          .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 4. 둥근 모서리 배경 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("4. RoundedRectangle 배경")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button("둥근 모서리") {
            count += 1
          }
          .font(.KoddiBold18)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.primaryGreen)
          )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 5. 테두리 있는 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("5. 테두리 있는 Button (overlay)")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button("테두리 버튼") {
            count += 1
          }
          .font(.KoddiBold18)
          .foregroundColor(Color.primaryGreen)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(Color.background(appTheme.theme))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.primaryGreen, lineWidth: 2)
          )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 6. 비활성화 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("6. 비활성화 Button")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button("비활성화 버튼") {
            count += 1
          }
          .font(.KoddiBold18)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(
            isEnabled ? Color.primaryGreen : Color.primaryGreen.opacity(0.4)
          )
          .cornerRadius(8)
          .disabled(!isEnabled)

          Toggle("버튼 활성화", isOn: $isEnabled)
            .font(.KoddiRegular16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 7. 원형 Button (Circle)
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("7. 원형 Button")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button(action: {
            count += 1
          }) {
            Image(systemName: "play.fill")
              .font(.system(size: 24))
              .foregroundColor(.white)
              .frame(width: 80, height: 80)
              .background(
                Circle()
                  .fill(Color.primaryGreen)
              )
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 8. 그림자 있는 Button
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("8. 그림자 있는 Button")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button("그림자 버튼") {
            count += 1
          }
          .font(.KoddiBold18)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(Color.primaryGreen)
          .cornerRadius(8)
          .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 9. 프로젝트 스타일 Button (AddSubscriptionButton 참고)
        // ============================================
        VStack(alignment: .leading, spacing: 10) {
          Text("9. 프로젝트 스타일 Button")
            .font(.KoddiBold20)
            .foregroundColor(Color.text(appTheme.theme))

          Button(action: {
            count += 1
          }) {
            Text("등록 승인 요청")
              .font(.KoddiExtraBold32)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 82)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color.primaryGreen)
              )
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)

        // ============================================
        // 10. 카운터 표시
        // ============================================
        VStack(spacing: 10) {
          Text("버튼 클릭 횟수: \(count)")
            .font(.KoddiBold24)
            .foregroundColor(Color.text(appTheme.theme))

          Button("리셋") {
            count = 0
          }
          .font(.KoddiBold18)
          .foregroundColor(.white)
          .padding(.horizontal, 30)
          .padding(.vertical, 12)
          .background(Color.urgentPink)
          .cornerRadius(8)
        }
        .padding(.vertical, 20)
      }
    }
    .background(Color.background(appTheme.theme))
  }
}

// MARK: - Preview

#Preview {
  ButtonPracticeView()
    .environmentObject(AppThemeManager())
}

