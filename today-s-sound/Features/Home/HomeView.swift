//
//  HomeView.swift
//  today-s-sound
//
//  Created by 하승연 on 9/28/25.
//

import SwiftUI

struct HomeView: View {
  var body: some View {
    VStack {
      Group {
        Text("오늘의 소리")
          .font(.KoddiBold56)
          .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
      }
      .foregroundStyle(Color.black)
    }
  }
}

#Preview {
  HomeView()
}
