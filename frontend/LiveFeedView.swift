import SwiftUI

struct LiveFeedView: View {
    @StateObject private var socialService = SocialAPIService()
    @State private var isRefreshing = false
    @State private var navigateClashID: String?
    @EnvironmentObject var viralService: ViralAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var tab = 0

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                VStack {
                    // Drama drop button
                    if !viralService.todayDramaKeyword.isEmpty {
                        DramaDropButton(keyword: viralService.todayDramaKeyword) {
                            if let token = authService.jwtToken {
                                viralService.startDrama(token: token) { id in
                                    if let id = id {
                                        // navigate to clash watch
                                        DispatchQueue.main.async {
                                            navigateClashID = id
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                    // Picker moved to toolbar
                    contentView
                }
            }
            .navigationTitle(tab == 0 ? "Hot" : (tab == 1 ? "Drama" : "Public"))
            .toolbar {
                // Segmented control right under the nav bar title
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $tab) {
                        Text("Hot").tag(0)
                        Text("Drama").tag(1)
                        Text("Public").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 250)
                    .onChange(of: tab) { newVal in
                        loadTab(newVal)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await refresh() } }) {
                        Image(systemName: "arrow.clockwise.circle")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear { loadTab(tab) }
    }

    private func loadTab(_ index:Int){
        switch index {
        case 0: socialService.fetchLiveClashes()
        case 1: socialService.fetchDramaFeed()
        default: socialService.fetchPublicClashes()
        }
    }

    private var contentView: some View {
        Group {
            let list = tab == 0 ? socialService.liveClashes : (tab==1 ? socialService.dramaClashes : socialService.publicClashes)
            if socialService.isLoading && list.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if list.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bolt.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.8))
                    Text("No live clashes yet\nCheck back soon!")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                if tab == 0 {
                    TabView {
                        ForEach(list) { clash in
                            HotCardView(clash: clash)
                                .onTapGesture {
                                    navigateClashID = clash.id
                                }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height:300)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(list) { clash in
                                (tab==1 ? AnyView(DramaCardView(clash: clash)) : AnyView(ClashCardView(clash: clash)))
                                    .background(
                                        NavigationLink(destination: tab == 1 ? AnyView(ConversationView(dispute: socialService.disputes(for: clash.streamerA).first ?? MockDispute(id: "tmp", title: clash.streamerA + " vs " + clash.streamerB, statementA: "Side A", statementB: "Side B", votesA: 0, votesB: 0))) : AnyView(ClashWatchView(clash: clash))) {
                                            EmptyView()
                                        }.opacity(0)
                                    )
                            }
                        }
                        .padding()
                        .refreshable { await refresh() }
                    }
                }
            }
        }
    }

    @MainActor
    private func refresh() async {
        isRefreshing = true
        loadTab(tab)
        // simple delay to end refresh animation
        try? await Task.sleep(nanoseconds: 600_000_000)
        isRefreshing = false
    }
}

struct ClashCardView: View {
    let clash: Clash

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                HStack {
                    Text("🔥 \(clash.streamerA) VS \(clash.streamerB)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text("\(clash.viewerCount)")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
                }

                HStack {
                    Text("Started: \(formattedDate(clash.startedAt))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Image(systemName: "play.rectangle.fill")
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 110)
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .short
            return rel.localizedString(for: date, relativeTo: Date())
        }
        return "now"
    }
}

struct DramaCardView: View {
    let clash: Clash
    var body: some View {
        ZStack {
            HStack(spacing:0){
                Color.red.opacity(0.8)
                Color.blue.opacity(0.8)
            }
            .mask(RoundedRectangle(cornerRadius: 20))
            VStack{
                Text("⚔️ \(clash.streamerA) VS \(clash.streamerB)")
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(maxWidth:.infinity,minHeight:90)
        .cornerRadius(20)
    }
}

struct HotCardView: View {
    let clash: Clash
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors:[.orange,.red],startPoint:.topLeading,endPoint:.bottomTrailing))
            VStack(spacing:16){
                HStack{
                    Image(systemName:"flame.fill").foregroundColor(.yellow)
                    Text("HOT NOW").bold().foregroundColor(.white)
                    Spacer()
                    Text("👀 \(clash.viewerCount)")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                Text("\(clash.streamerA) vs \(clash.streamerB)")
                    .font(.title2).bold().foregroundColor(.white)
                Text("Tap to watch & vote")
                    .font(.caption).foregroundColor(.white.opacity(0.8))
            }
        }.padding(.horizontal,24)
    }
}

struct LiveFeedView_Previews: PreviewProvider {
    static var previews: some View {
        LiveFeedView()
    }
}