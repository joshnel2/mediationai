import SwiftUI

struct LiveFeedView: View {
    @StateObject private var socialService = SocialAPIService()
    @State private var isRefreshing = false
    @State private var navigateClashID: String?
    @EnvironmentObject var viralService: ViralAPIService
    @EnvironmentObject var authService: MockAuthService
    @State private var tab = 0 // 0 = Explore, 1 = Following
    @State private var exploreFeed:[Clash] = []
    @State private var followingFeed:[Clash] = []

    private let batchSize = 20

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
                                        DispatchQueue.main.async { navigateClashID = id }
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }

                    // Fancy toggle
                    CapsuleToggle(selection: $tab, titles: ["Explore","Following"])
                        .padding(.vertical,4)

                    contentView
                }
            }
            .navigationTitle("")
            .toolbar {
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
        .onChange(of: tab) { idx in loadTab(idx) }
    }

    private func loadTab(_ index:Int){
        switch index {
        case 0: socialService.fetchLiveClashes()
        default: socialService.fetchFollowingClashes()
        }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.1){
            exploreFeed = socialService.liveClashes
            followingFeed = socialService.followingClashes
        }
    }

    private var contentView: some View {
        Group {
            let listBinding = tab == 0 ? $exploreFeed : $followingFeed
            let list = listBinding.wrappedValue

            if socialService.isLoading && list.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if list.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bolt.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.8))
                    Text("No crashouts here yet\nCheck back soon!")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(list.indices, id: \.self) { idx in
                            let clash = list[idx]
                            NavigationLink(destination: destinationView(for: clash)) {
                                FeedClashRow(clash: clash)
                                    .environmentObject(socialService)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear{
                                if idx >= list.count - 3 {
                                    appendMoreItems()
                                }
                            }
                            // Divider between rows
                            if idx < list.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .refreshable { await refresh() }
                }
            }
        }
    }

    // Helper to build destination
    private func destinationView(for clash:Clash) -> some View {
        if let disp = socialService.dispute(withId: clash.id) {
            return AnyView(ConversationView(dispute: disp).environmentObject(socialService))
        } else {
            let placeholder = MockDispute(id: clash.id, title: "\(clash.streamerA) vs \(clash.streamerB)", statementA: "", statementB: "", votesA: clash.votes ?? 0, votesB: 0)
            return AnyView(ConversationView(dispute: placeholder).environmentObject(socialService))
        }
    }

    // MARK: - Row
    private struct FeedClashRow: View {
        let clash: Clash
        @EnvironmentObject var social: SocialAPIService
        @EnvironmentObject var authService: MockAuthService
        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                // Avatars
                AsyncImage(url: social.avatarURL(id: clash.streamerA, size: 80)) { phase in
                    (phase.image ?? Image(systemName: "person.circle")).resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                AsyncImage(url: social.avatarURL(id: clash.streamerB, size: 80)) { phase in
                    (phase.image ?? Image(systemName: "person.circle")).resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("\(clash.streamerA)").bold()
                        Text("vs")
                        Text("\(clash.streamerB)").bold()
                        if let votes = clash.votes {
                            Text("🔥 \(votes)")
                                .font(.caption)
                        }
                    }
                    .font(.subheadline)

                    Text("👀 \(clash.viewerCount) viewers")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded { HapticManager.impact(.light) })
        }

        private func followStreamers(){
            // Follow both streamerA and streamerB if we can resolve their IDs
            if let idA = social.overallLeaders.first(where: { $0.displayName == clash.streamerA })?.id {
                social.toggleFollow(id: idA, followerID: authService.currentUser?.id.uuidString ?? "")
            }
            if let idB = social.overallLeaders.first(where: { $0.displayName == clash.streamerB })?.id {
                social.toggleFollow(id: idB, followerID: authService.currentUser?.id.uuidString ?? "")
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

    private func appendMoreItems(){
        if tab==0 {
            let extras = socialService.liveClashes.shuffled().prefix(batchSize)
            exploreFeed.append(contentsOf: extras)
        } else {
            let extras = socialService.followingClashes.shuffled().prefix(batchSize)
            followingFeed.append(contentsOf: extras)
        }
    }
}

// MARK: CapsuleToggle

private struct CapsuleToggle: View {
    @Binding var selection: Int
    let titles: [String]
    @Namespace private var ns
    var body: some View {
        HStack(spacing:0){
            ForEach(titles.indices, id: \.self){ idx in
                ZStack{
                    if selection == idx {
                        RoundedRectangle(cornerRadius:12)
                            .fill(AppTheme.accent)
                            .matchedGeometryEffect(id:"feedtog", in: ns)
                    }
                    Text(titles[idx])
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selection==idx ? .white : .white.opacity(0.7))
                        .frame(maxWidth:.infinity)
                        .padding(.vertical,8)
                }
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.spring()) { selection = idx } }
            }
        }
        .background(RoundedRectangle(cornerRadius:12).fill(Color.white.opacity(0.15)))
        .padding(.horizontal)
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
    @EnvironmentObject var social: SocialAPIService
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
                    AsyncImage(url: social.avatarURL(id:clash.streamerA, size:80)) { phase in
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
                    AsyncImage(url: social.avatarURL(id:clash.streamerB, size:80)) { phase in
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