//
//  DebugSettingsView.swift
//  today-s-sound
//
//  디버그용 설정 화면
//

import SwiftUI

struct DebugSettingsView: View {
  @EnvironmentObject var sessionStore: SessionStore
  @Environment(\.dismiss) var dismiss
  @State private var showingAlert = false

  var body: some View {
    NavigationView {
      Form {
        // MARK: - 키체인 정보

        Section {
          if let userId = sessionStore.userId {
            VStack(alignment: .leading, spacing: 8) {
              Text("User ID")
                .font(.caption)
                .foregroundColor(.secondary)

              Text(userId)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
            }
          } else {
            Text("User ID: (없음)")
              .foregroundColor(.secondary)
          }

          if let deviceSecret = Keychain.getString(for: KeychainKey.deviceSecret) {
            VStack(alignment: .leading, spacing: 8) {
              Text("Device Secret")
                .font(.caption)
                .foregroundColor(.secondary)

              Text(deviceSecret.prefix(40) + "...")
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
            }
          } else {
            Text("Device Secret: (없음)")
              .foregroundColor(.secondary)
          }
        } header: {
          Label("키체인 정보", systemImage: "key.fill")
        }

        // MARK: - 위험 구역

        Section {
          Button(role: .destructive, action: {
            showingAlert = true
          }) {
            HStack {
              Image(systemName: "trash.fill")
              Text("키체인 초기화 (로그아웃)")
            }
          }
        } header: {
          Label("위험 구역", systemImage: "exclamationmark.triangle.fill")
        } footer: {
          Text("⚠️ 키체인을 초기화하면 다시 온보딩 화면으로 돌아갑니다.")
            .font(.caption)
        }
      }
      .navigationTitle("디버그 설정")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("닫기") {
            dismiss()
          }
        }
      }
      .alert("키체인 초기화", isPresented: $showingAlert) {
        Button("취소", role: .cancel) {}
        Button("초기화", role: .destructive) {
          sessionStore.logout()
          dismiss()
        }
      } message: {
        Text("모든 키체인 데이터를 삭제하고 처음부터 시작합니다.")
      }
    }
  }
}

#if DEBUG
  struct DebugSettingsView_Previews: PreviewProvider {
    static var previews: some View {
      DebugSettingsView()
        .environmentObject(SessionStore())
    }
  }
#endif
