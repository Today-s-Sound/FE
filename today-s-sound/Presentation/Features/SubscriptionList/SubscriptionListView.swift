
import SwiftUI


struct SubscriptionListView: View {
    @StateObject private var viewModel = SubscriptionListViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddSubscription = false
    let customGreen = Color(red: 0 / 255, green: 223 / 255, blue: 119 / 255)
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : .white)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {

                    Spacer()
                    // 타이틀
                    Text("구독 설정")
                        .font(.system(size: 31, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    Text("구독 중인 페이지")
                        .font(.system(size:28, weight: .bold))
                        .foregroundStyle(customGreen)
                        .padding(.horizontal, 24)
                    
                    // 구독 목록
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.subscriptions) { subscription in
                                SubscriptionCardView(subscription: subscription, colorScheme: colorScheme)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    // 하단 버튼
                    VStack(spacing: 12) {
                        Button(action: { 
                            showAddSubscription = true 
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                Text("새로운 웹페이지 추가")
                                    .font(.system(size: 24, weight: .semibold))
                            }
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
                    .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddSubscription) {
            AddSubscriptionView()
        }
    }
}

struct SubscriptionCardView: View {
    let subscription: Subscription
    let colorScheme: ColorScheme
    
    let cardGreyColor = Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255)
    
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(subscription.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text(subscription.url)
                    .font(.system(size: 13))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    StatusBadge(text: "등록중", colorScheme: colorScheme)
                    StatusBadge(text: "일이삼사", colorScheme: colorScheme)
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(white: 0.15) : cardGreyColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct StatusBadge: View {
    let text: String
    let colorScheme: ColorScheme

    let fontgreenColor = Color(red: 0 / 255, green: 223 / 255, blue: 119 / 255)
    let badgeBackgroundColor = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255, opacity: 0.16)
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(colorScheme == .dark ? .white :fontgreenColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(badgeBackgroundColor)
            )
    }
}

struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionListView()
    }
}
