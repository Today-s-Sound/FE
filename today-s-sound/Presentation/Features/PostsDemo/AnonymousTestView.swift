import SwiftUI

struct AnonymousTestView: View {
  @StateObject private var store = SessionStore()
  @State private var log: String = ""

  var body: some View {
    Form {
      Section(header: Text("동작")) {
        Button("익명 사용자 등록") {
          log = "요청 중..."
          Task {
            await store.registerIfNeeded()
            if let err = store.lastError {
              log = "실패: \(err)"
            } else if let id = store.userId {
              log = "성공: user_id=\(id)"
            } else {
              log = "상태 변경 없음"
            }
          }
        }
      }
      if let id = store.userId, !id.isEmpty {
        Section(header: Text("결과 user_id")) {
          Text(id)
            .font(.system(.body, design: .monospaced))
        }
      }
      if let err = store.lastError, !err.isEmpty {
        Section(header: Text("에러")) {
          Text(err)
            .font(.footnote)
            .foregroundColor(.red)
        }
      }
      Section(header: Text("로그")) {
        Text(log)
          .font(.footnote)
          .foregroundColor(.gray)
      }
    }
    .navigationTitle("익명 생성 테스트")
  }
}

#if DEBUG
  struct AnonymousTestView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView { AnonymousTestView() }
    }
  }
#endif
