import SwiftUI
import Combine

final class AnonymousTestViewModel: ObservableObject {
  @Published var deviceSecret: String = UUID().uuidString
  @Published var userId: String = ""
  @Published var log: String = ""

  private let api = APIService()
  private var cancellables: Set<AnyCancellable> = []

  func createAnonymous() {
    log = "요청 중..."
    api.createAnonymous(deviceSecret: deviceSecret)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          break
        case let .failure(error):
          self?.log = "실패: \(error)"
        }
      } receiveValue: { [weak self] response in
        self?.userId = response.result.userId
        self?.log = "성공: user_id=\(response.result.userId)"
      }
      .store(in: &cancellables)
  }
}

struct AnonymousTestView: View {
  @StateObject private var vm = AnonymousTestViewModel()

  var body: some View {
    Form {
      Section(header: Text("디바이스 시크릿")) {
        TextField("deviceSecret", text: $vm.deviceSecret)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
      }
      Section(header: Text("동작")) {
        Button("익명 사용자 생성") {
          vm.createAnonymous()
        }
      }
      if !vm.userId.isEmpty {
        Section(header: Text("결과 user_id")) {
          Text(vm.userId)
            .font(.system(.body, design: .monospaced))
        }
      }
      Section(header: Text("로그")) {
        Text(vm.log)
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


