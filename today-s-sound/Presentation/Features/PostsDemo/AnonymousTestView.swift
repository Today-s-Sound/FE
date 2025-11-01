import Combine
import SwiftUI

@MainActor
final class AnonymousTestViewModel: ObservableObject {
  @Published var deviceSecret: String = DeviceSecretGenerator.generate()
  @Published var userId: String = ""
  @Published var log: String = ""
  @Published var isLoading: Bool = false
  @Published var keychainData: [String: String] = [:]
  
  private let apiService = APIService()
  private var cancellables: Set<AnyCancellable> = []
  
  // 키체인 데이터 로드
  func loadKeychainData() {
    keychainData.removeAll()
    
    if let secret = Keychain.getString(for: KeychainKey.deviceSecret) {
      keychainData["deviceSecret"] = secret
    } else {
      keychainData["deviceSecret"] = "(없음)"
    }
    
    if let uid = Keychain.getString(for: KeychainKey.userId) {
      keychainData["userId"] = uid
    } else {
      keychainData["userId"] = "(없음)"
    }
    
    if let apiKey = Keychain.getString(for: KeychainKey.apiKey) {
      keychainData["apiKey"] = apiKey
    } else {
      keychainData["apiKey"] = "(없음)"
    }
    
    log = "🔑 키체인 데이터 로드 완료"
  }
  
  // 키체인 초기화
  func clearKeychain() {
    Keychain.delete(for: KeychainKey.deviceSecret)
    Keychain.delete(for: KeychainKey.userId)
    Keychain.delete(for: KeychainKey.apiKey)
    
    loadKeychainData()
    log = "🗑️ 키체인 데이터 삭제 완료"
  }
  
  // 디바이스 시크릿 재생성
  func regenerateDeviceSecret() {
    deviceSecret = DeviceSecretGenerator.generate()
    log = "새로운 deviceSecret 생성됨"
  }
  
  // 익명 사용자 등록
  func registerAnonymous() {
    isLoading = true
    userId = ""
    log = "📤 익명 사용자 등록 요청 중...\ndeviceSecret: \(deviceSecret.prefix(20))..."
    
    apiService.registerAnonymous(deviceSecret: deviceSecret)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          guard let self = self else { return }
          self.isLoading = false
          
          switch completion {
          case .finished:
            break
            
          case .failure(let error):
            // 상세한 에러 메시지
            var errorLog = "❌ 등록 실패\n"
            switch error {
            case .serverError(let statusCode):
              errorLog += "서버 오류 (상태: \(statusCode))"
              
            case .decodingFailed(let decodeError):
              errorLog += "응답 처리 실패\n\(decodeError.localizedDescription)"
              
            case .requestFailed(let requestError):
              errorLog += "요청 실패\n\(requestError.localizedDescription)"
              
            case .invalidURL:
              errorLog += "잘못된 URL"
              
            case .unknown:
              errorLog += "알 수 없는 오류"
            }
            
            self.log = errorLog
            print("❌ \(errorLog)")
          }
        },
        receiveValue: { [weak self] response in
          guard let self = self else { return }
          
          self.userId = response.result.userId
          
          var successLog = "✅ 등록 성공!\n"
          successLog += "━━━━━━━━━━━━━━━━━━\n"
          successLog += "User ID: \(response.result.userId)\n"
          successLog += "Message: \(response.message)\n"
          if let errorCode = response.errorCode {
            successLog += "Error Code: \(errorCode)\n"
          }
          successLog += "━━━━━━━━━━━━━━━━━━"
          
          self.log = successLog
          print("✅ 익명 사용자 등록 성공: \(response.result.userId)")
        }
      )
      .store(in: &cancellables)
  }
}

struct AnonymousTestView: View {
  @StateObject private var viewModel = AnonymousTestViewModel()
  
  var body: some View {
    Form {
      // MARK: - Device Secret 섹션
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text("Device Secret")
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text(viewModel.deviceSecret)
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.primary)
            .textSelection(.enabled)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
          
          Button(action: viewModel.regenerateDeviceSecret) {
            HStack {
              Image(systemName: "arrow.clockwise")
              Text("새로 생성")
            }
            .font(.caption)
          }
          .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
      } header: {
        Label("디바이스 시크릿", systemImage: "key.fill")
      }
      
      // MARK: - 동작 섹션
      Section {
        Button(action: viewModel.registerAnonymous) {
          HStack {
            if viewModel.isLoading {
              ProgressView()
                .progressViewStyle(.circular)
            } else {
              Image(systemName: "person.badge.plus")
            }
            Text(viewModel.isLoading ? "등록 중..." : "익명 사용자 등록")
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        .disabled(viewModel.isLoading || viewModel.deviceSecret.isEmpty)
      } header: {
        Label("동작", systemImage: "bolt.fill")
      } footer: {
        Text("서버에 익명 사용자를 등록합니다.")
          .font(.caption)
      }
      
      // MARK: - 결과 섹션
      if !viewModel.userId.isEmpty {
        Section {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("User ID")
                .font(.caption)
                .foregroundColor(.secondary)
              Spacer()
              Button(action: {
                UIPasteboard.general.string = viewModel.userId
              }) {
                Label("복사", systemImage: "doc.on.doc")
                  .font(.caption)
              }
              .buttonStyle(.borderless)
            }
            
            Text(viewModel.userId)
              .font(.system(.body, design: .monospaced))
              .foregroundColor(.green)
              .textSelection(.enabled)
              .padding(8)
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(Color.green.opacity(0.1))
              .cornerRadius(8)
          }
          .padding(.vertical, 4)
        } header: {
          Label("결과", systemImage: "checkmark.circle.fill")
            .foregroundColor(.green)
        }
      }
      
      // MARK: - 키체인 확인 섹션
      Section {
        Button(action: viewModel.loadKeychainData) {
          HStack {
            Image(systemName: "key.fill")
            Text("키체인 데이터 확인")
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        
        if !viewModel.keychainData.isEmpty {
          VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.keychainData.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
              VStack(alignment: .leading, spacing: 4) {
                Text(key)
                  .font(.caption)
                  .foregroundColor(.secondary)
                
                Text(value)
                  .font(.system(.caption, design: .monospaced))
                  .foregroundColor(value == "(없음)" ? .red : .primary)
                  .textSelection(.enabled)
                  .padding(8)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(value == "(없음)" ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
                  .cornerRadius(8)
              }
            }
          }
          .padding(.vertical, 8)
          
          Button(action: viewModel.clearKeychain) {
            HStack {
              Image(systemName: "trash.fill")
              Text("키체인 초기화")
            }
            .font(.caption)
            .foregroundColor(.red)
          }
          .buttonStyle(.borderless)
        }
      } header: {
        Label("키체인 확인 (디버그)", systemImage: "externaldrive.fill")
      } footer: {
        Text("시뮬레이터에 저장된 Keychain 데이터를 확인합니다.")
          .font(.caption)
      }
      
      // MARK: - 로그 섹션
      if !viewModel.log.isEmpty {
        Section {
          ScrollView {
            Text(viewModel.log)
              .font(.system(.caption, design: .monospaced))
              .foregroundColor(viewModel.log.contains("❌") ? .red : 
                              viewModel.log.contains("✅") ? .green : .secondary)
              .textSelection(.enabled)
              .padding(8)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(minHeight: 100)
        } header: {
          Label("로그", systemImage: "text.alignleft")
        }
      }
    }
    .navigationTitle("익명 사용자 등록 테스트")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.loadKeychainData()
    }
  }
}

#if DEBUG
  struct AnonymousTestView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView { AnonymousTestView() }
    }
  }
#endif
