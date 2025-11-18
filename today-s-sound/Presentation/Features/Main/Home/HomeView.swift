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
          .padding(.bottom, 30)

        Button(
          action: {
            if let first = viewModel.recentAlerts.first {
              viewModel.playAlert(first)
            }
          },
          label: {
            Image("play")
              .resizable()
              .scaledToFit()
              .frame(width: 180, height: 180)
              .padding(20)
          }
        )
        .padding(.bottom, 60)

        // 속도 조절
        HStack(spacing: 48) {
          Button(
            action: { viewModel.decreaseRate() },
            label: {
              Image(systemName: "minus")
                    .font(.KoddiBold48)
                .foregroundColor(Color.primaryGreen)
            }
          )

          Text(String(format: "%.1f x", viewModel.playbackRate))
            .font(.KoddiBold48)
            .foregroundColor(Color.text(colorScheme))
            .monospacedDigit()
            .frame(minWidth: 100)

          Button(
            action: { viewModel.increaseRate() },
            label: {
              Image(systemName: "plus")
                .font(.KoddiBold48)
                .foregroundColor(Color.primaryGreen)
            }
          )
        }
        .padding(.bottom, 60)

        VStack(spacing: 16) {
          Text("현재 카테고리")
                .font(.KoddiBold28)
            .foregroundColor(Color.text(colorScheme))
    
          Text(viewModel.currentCategoryName)
            .font(.KoddiExtraBold32)
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .frame(width: 360, height: 84)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(Color.primaryGreen)
            )
            .foregroundColor(.white)
        }
        .padding(.bottom, 16)
      }
    }
  }
}

#Preview {
  HomeView()
}
