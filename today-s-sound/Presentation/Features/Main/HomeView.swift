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
      (colorScheme == .dark ? Color.black : Color.white)
        .ignoresSafeArea()

      VStack(spacing: 0) {
//        HStack {
//            Button(action: {}) {
//              Image(systemName: "bell")
//                .font(.system(size: 48, weight: .medium))
//                .foregroundColor(colorScheme == .dark ? .white : Color.green.opacity(0.9))
//            }
//            Spacer()
//            Button(action: {}) {
//              Image(systemName: "line.3.horizontal")
//                .font(.system(size: 48, weight: .medium))
//                .foregroundColor(colorScheme == .dark ? .white : Color.green.opacity(0.9))
//            }
//        }
//        .padding(.horizontal, 24)
//        .padding(.top, 16)
//
//        Spacer()
          Spacer()

        // 오늘의 소리 타이틀
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
          .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
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
            .foregroundColor(Color.green.opacity(0.9))
            .padding(40)
        }
        .padding(.bottom, 60)

        // 속도 조절
        HStack(spacing: 48) {
          Button(action: { viewModel.decreaseRate() }) {
            Image(systemName: "minus")
              .font(.system(size: 35, weight: .medium))
              .foregroundColor(colorScheme == .dark ? .white : Color.green.opacity(0.9))
          }
            
          Text(String(format: "%.1f x", viewModel.playbackRate))
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .monospacedDigit()
            .frame(minWidth: 100)

          Button(action: { viewModel.increaseRate() }) {
            Image(systemName: "plus")
              .font(.system(size: 35, weight: .medium))
              .foregroundColor(colorScheme == .dark ? .white : Color.green.opacity(0.9))
          }
        }

        Spacer()

        VStack(spacing: 16) {
          Text("현재 카테고리")
            .font(.system(size: 28))
            .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))

          Text(viewModel.currentCategoryName)
            .font(.system(size: 32, weight: .semibold))
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(width: 340, height: 85)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.9))
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
