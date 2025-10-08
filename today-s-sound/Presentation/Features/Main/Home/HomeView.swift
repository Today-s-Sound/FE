//
//  HomeView.swift
//  today-s-sound
//
//  Created by 하승연 on 9/28/25.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = MainViewModel()
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    ZStack {
      // 다크모드에 따라 배경색 변경
      Color.background(colorScheme)
        .ignoresSafeArea()

      VStack(spacing: 0) {
          Spacer()

        // 오늘의 소리 타이틀
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .foregroundStyle(Color.text(colorScheme))
          .shadow(color: .black25, radius: 2, x: 0, y: 4)
          .padding(.bottom, 60)

        Button(action: {
          if let first = viewModel.recentAlerts.first {
            viewModel.playAlert(first)
          }
        }) {
          Image(systemName: "play.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .foregroundColor(Color.primaryGreen90)
            .padding(40)
        }
        .padding(.bottom, 60)

        // 속도 조절
        HStack(spacing: 48) {
          Button(action: { viewModel.decreaseRate() }) {
            Image(systemName: "minus")
              .font(.system(size: 35, weight: .medium))
              .foregroundColor(colorScheme == .dark ? .white : Color.primaryGreen90)
          }
            
          Text(String(format: "%.1f x", viewModel.playbackRate))
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(Color.text(colorScheme))
            .monospacedDigit()
            .frame(minWidth: 100)

          Button(action: { viewModel.increaseRate() }) {
            Image(systemName: "plus")
              .font(.system(size: 35, weight: .medium))
              .foregroundColor(colorScheme == .dark ? .white : Color.primaryGreen90)
          }
        }

        Spacer()

        VStack(spacing: 16) {
          Text("현재 카테고리")
            .font(.system(size: 28))
            .foregroundColor(Color.secondaryText(colorScheme))

          Text(viewModel.currentCategoryName)
            .font(.system(size: 32, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(width: 340, height: 85)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.primaryGreen90)
            )
            .foregroundColor(.white)
        }
        .padding(.bottom, 32)
      }
    }
  }
}

#Preview {
  HomeView()
}
