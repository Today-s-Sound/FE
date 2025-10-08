
import SwiftUI


struct SubscriptionListView: View {
    @StateObject private var viewModel = SubscriptionListViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddSubscription = false
    var body: some View {
        NavigationView {
            ZStack {
                Color.background(colorScheme)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {

                    Spacer()
                    // 타이틀
                    Text("구독 설정")
                        .font(.system(size: 31, weight: .bold))
                        .foregroundColor(Color.text(colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    Text("구독 중인 페이지")
                        .font(.system(size:28, weight: .bold))
                        .foregroundStyle(Color.primaryGreen)
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
                                    .fill(Color.primaryGreen90)
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
    
    
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(subscription.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.text(colorScheme))

                Text(subscription.url)
                    .font(.system(size: 13))
                    .foregroundColor(Color.secondaryText(colorScheme))
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
                .fill(Color.secondaryBackground(colorScheme))
                .shadow(color: .black5, radius: 4, x: 0, y: 2)
        )
    }
}


struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionListView()
    }
}
