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
            .navigationTitle(tab == 0 ? "Hot" : (tab == 1 ? "Drama" : "Following"))
            .toolbar {
                // Segmented control right under the nav bar title
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $tab) {
                        Text("Hot").tag(0)
                        Text("Drama").tag(1)
                        Text("Following").tag(2)
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
        default: socialService.fetchFollowingClashes()
        }
    }

    private var contentView: some View {
        Group {
            let list: [Clash] = {
                if tab == 0 {
                    return socialService.liveClashes.sorted { ($0.votes ?? 0) > ($1.votes ?? 0) }
                } else if tab == 1 {
                    return socialService.dramaClashes
                } else {
                    return socialService.followingClashes
                }
            }()
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
                            NavigationLink(destination: ClashWatchView(clash: clash)) {
                                HotCardView(clash: clash)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height:320)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(list) { clash in
                                NavigationLink(destination: tab == 1 ? AnyView(ConversationView(dispute: socialService.disputes(for: clash.streamerA).first ?? MockDispute(id: UUID().uuidString, title: "\(clash.streamerA) vs \(clash.streamerB)", statementA: clash.streamerA, statementB: clash.streamerB, votesA: 0, votesB: 0))) : AnyView(ClashWatchView(clash: clash))) {
                                    (tab==1 ? AnyView(DramaCardView(clash: clash)) : AnyView(ClashCardView(clash: clash)))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
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
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.15))
                .background(
                    RoundedRectangle(cornerRadius:24).stroke(Color.white.opacity(0.25),lineWidth:1)
                )

            // Content overlay
            HStack {
                VStack(spacing:6){
                    AsyncImage(url: URL(string:"https://i.pravatar.cc/80?u=\(clash.streamerA)")) { phase in
                        if let img = phase.image {
                            img.resizable()
                        } else {
                            Color.white.opacity(0.2)
                        }
                    }
                        .frame(width:60,height:60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.8),lineWidth:2))
                    Text(clash.streamerA)
                        .font(.caption2).bold().foregroundColor(.white)
                }
                Spacer()
                VStack(spacing:6){
                    AsyncImage(url: URL(string:"https://i.pravatar.cc/80?u=\(clash.streamerB)")) { phase in
                        if let img = phase.image {
                            img.resizable()
                        } else {
                            Color.white.opacity(0.2)
                        }
                    }
                        .frame(width:60,height:60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.8),lineWidth:2))
                    Text(clash.streamerB)
                        .font(.caption2).bold().foregroundColor(.white)
                }
            }
            .padding(.horizontal,24)

            // VS label
            VStack(spacing:4){
                Text("VS").font(.caption).foregroundColor(.white.opacity(0.8))
                if let votes = clash.votes {
                    Text("🔥 \(votes) votes")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            // Vote ratio bar
            if let votes = clash.votes, votes > 0 {
                let percentA = Double((clash.votes ?? 0) % 100) / Double(votes)
                VStack{
                    Spacer()
                    GeometryReader{ geo in
                        ZStack(alignment:.leading){
                            RoundedRectangle(cornerRadius:4).fill(Color.white.opacity(0.15)).frame(height:8)
                            RoundedRectangle(cornerRadius:4).fill(AppTheme.primary).frame(width:geo.size.width*percentA, height:8)
                        }
                    }.frame(height:8)
                }.padding(.horizontal,24).padding(.bottom,16)
            }
        }
        .frame(height:140)
        .cornerRadius(24)
        .shadow(color:.black.opacity(0.15),radius:6,x:0,y:3)
    }
}

struct HotCardView: View {
    let clash: Clash
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors:[Color.orange,Color.red],startPoint:.topLeading,endPoint:.bottomTrailing))
                .shadow(color:.black.opacity(0.25),radius:6,x:0,y:4)
            VStack(spacing:20){
                HStack{
                    Image(systemName:"flame.fill").foregroundColor(.yellow)
                    Text("Trending Crashout")
                        .font(.subheadline).bold().foregroundColor(.white)
                    Spacer()
                    Text("👀 \(clash.viewerCount)")
                        .font(.caption).foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal)
                VStack(spacing:4){
                    Text("\(clash.streamerA)").bold()
                    Text("vs")
                    Text("\(clash.streamerB)").bold()
                }
                .foregroundColor(.white).font(.title3)
                if let votes = clash.votes {
                    Text("🔥 \(votes) votes")
                        .font(.caption2).foregroundColor(.white.opacity(0.85))
                }
            }
            .padding(.vertical,20)
        }
        .padding(.horizontal,24)
    }
}

struct LiveFeedView_Previews: PreviewProvider {
    static var previews: some View {
        LiveFeedView()
    }
}