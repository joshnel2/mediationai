import SwiftUI
import Combine
import PhotosUI
import AVKit
import UniformTypeIdentifiers

// MARK: - Bubble Tail Shape
struct BubbleTail: Shape {
    var isMySide: Bool
    func path(in rect: CGRect) -> Path {
        var p = Path()
        if isMySide {
            p.move(to: CGPoint(x: rect.maxX, y: rect.minY+10))
            p.addLine(to: CGPoint(x: rect.maxX+6, y: rect.minY+16))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY+22))
        } else {
            p.move(to: CGPoint(x: rect.minX, y: rect.minY+10))
            p.addLine(to: CGPoint(x: rect.minX-6, y: rect.minY+16))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY+22))
        }
        return p
    }
}

struct ConversationView: View {
    @EnvironmentObject var social: SocialAPIService
    let dispute: MockDispute

    // Preference key to detect vertical scroll offset
    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
    }

    // Simple chat model
    struct ChatMsg: Identifiable {
        enum Sender { case a, b, ai }
        enum Kind { case text(String), image(UIImage), file(URL) }
        var pending: Bool = false
        let id = UUID()
        let kind: Kind
        let sender: Sender
    }

    @State private var messages: [ChatMsg] = []
    @StateObject private var network = NetworkMonitor.shared
    @State private var pickerItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var pickedFile: URL?
    @State private var showFileImporter = false
    @State private var input: String = ""
    @State private var aiThinking = false
    @State private var voted = false
    @State private var votesA:Int = 0
    @State private var votesB:Int = 0

    // Swipeable view selection: 0 = A, 1 = B, 2 = AI Resolution
    @State private var selectedTab = 0

    // Live summary of the debate
    @State private var argumentSummary: String = "No summary yet"

    // Collapsing header state – 1 = full size, 0.6 = collapsed
    @State private var headerScale: CGFloat = 1.0
    private var avatarOpacity: Double {
        // Map headerScale 1.0→1 to 0.6→0
        let t = (headerScale - 0.6) / 0.4
        return Double(max(0, min(1, t)))
    }

    // Pull-to-refresh state
    @State private var pullOffset: CGFloat = 0

    private var pullProgress: Double {
        // 0 → 60pt maps to 0→1
        Double(min(max(pullOffset / 60, 0), 1))
    }

    // Scroll-to-bottom helper
    @State private var showScrollToBottom: Bool = false

    // Search sheet
    @State private var showSearch: Bool = false
    @State private var scrollToMessageID: UUID?

    // Reactions
    @State private var activeReactionTarget: UUID? = nil
    @State private var showReactionPicker: Bool = false
    @State private var reactions: [UUID: String] = [:]

    // Pull-to-refresh success indicator
    @State private var hasTriggeredRefresh = false
    @State private var showRefreshSuccess = false

    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var featureFlags: FeatureFlags

    // Determine if the current signed-in user is a participant in this crash-out.
    private var isParticipant: Bool {
        guard let myID = authService.currentUser?.id.uuidString else { return false }
        // A user is considered a participant if this dispute appears in their personal dispute list
        return social.disputesByUser[myID]?.contains(where: { $0.id == dispute.id }) ?? false
    }

    private var meIsA: Bool { Bool.random() } // placeholder

    // Attempt to infer participant names from the title formatted like "Alice vs Bob"
    private var sideAName: String {
        dispute.title.components(separatedBy: " vs ").first ?? "Side A"
    }
    private var sideBName: String {
        dispute.title.components(separatedBy: " vs ").last ?? "Side B"
    }

    var body: some View {
        VStack {
            // Topic title & scoreboard + live summary
            VStack(spacing:AppTheme.spacingSM){
                // Clean VS layout
                versusSection

                // Topic capsule
                Text(dispute.title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal,12).padding(.vertical,4)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())

                if !argumentSummary.isEmpty {
                    Text(argumentSummary)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal,8).padding(.vertical,4)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }

                HStack(alignment:.center){
                    VStack(spacing:2){
                        Text("🔥 \(votesA)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.primary)
                        Text(sideAName)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(spacing:2){
                        Text("🔥 \(votesB)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.accent)
                        Text(sideBName)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }

                // Progress bar with glow
                GeometryReader { geo in
                    ZStack(alignment:.leading){
                        RoundedRectangle(cornerRadius:4)
                            .fill(Color.white.opacity(0.15))
                        let total = max(1, votesA + votesB)
                        let percentA = CGFloat(votesA) / CGFloat(total)
                        RoundedRectangle(cornerRadius:4)
                            .fill(AppTheme.primary)
                            .frame(width: geo.size.width * percentA)
                            .shadow(color: AppTheme.primary.opacity(0.6), radius:6)
                    }
                }
                .frame(height:8)

                // Tab chooser
                HStack(spacing:0){
                    tabLabel(title:sideAName, index:0, color:AppTheme.primary)
                    tabLabel(title:sideBName, index:1, color:AppTheme.accent)
                    tabLabel(title:"Result", index:2, color:Color.yellow)
                }
            }
            .scaleEffect(headerScale, anchor: .top)
            .padding(8)
            .background(AppTheme.cardGradient)
            .cornerRadius(16)
            .padding(.top,2)

            // Swipeable pages
            TabView(selection:$selectedTab){
                chatPage(for:.a)
                    .tag(0)
                chatPage(for:.b)
                    .tag(1)
                resolutionPage
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode:.never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSearch = true }) {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search messages")
            }
        }
        // Floating scroll-to-bottom button
        .overlay(alignment: .bottomTrailing) {
            if showScrollToBottom {
                Button(action: scrollToBottom) {
                    Image(systemName: "arrow.down")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Jump to latest message")
            }
        }
        .sheet(isPresented: $showSearch) {
            MessageSearchView(messages: messages) { msg in
                scrollToMessageID = msg.id
                showSearch = false
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: scrollToMessageID) { id in
            guard let id else { return }
            scrollTo(id: id)
            scrollToMessageID = nil
        }
        .onAppear{ seed(); updateSummary() }
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            // value is negative when scrolled up; Compress header between 1.0 and 0.6
            let newScale = max(0.6, 1 - (-value / 240))
            withAnimation(.easeOut(duration: 0.2)) { headerScale = newScale }

            // Track pull offset (positive values)
            pullOffset = max(0, value)
        }
        .overlay(
            Group {
                if showReactionPicker, featureFlags.reactionsEnabled, let target = activeReactionTarget {
                    ReactionPicker { emoji in
                        reactions[target] = emoji
                        showReactionPicker = false
                        HapticManager.shared.selection()
                    } onCancel: {
                        showReactionPicker = false
                    }
                }
            }
        )
        .onAppear {
            let cached = MessageCache.load(disputeId: dispute.id)
            if messages.isEmpty {
                messages = cached.map { ChatMsg(kind: .text($0), sender: .ai) }
            }
        }
        .onChange(of: messages) { msgs in
            let texts = msgs.compactMap { msg -> String? in
                if case .text(let t) = msg.kind { return t } else { return nil }
            }
            MessageCache.save(disputeId: dispute.id, messages: texts)
        }
        .onReceive(network.$isOnline) { _ in attemptResend() }
    }

    // MARK: - Live Summary Helper
    private func updateSummary(){
        let plain = messages.compactMap { msg -> String? in
            if case let .text(t) = msg.kind { return t }
            return nil
        }
        SummarizationService.generateSummary(for: plain) { sum in
            DispatchQueue.main.async { argumentSummary = sum }
        }
    }

    // Reaction helper
    private func reactionButton(_ emoji:String)->some View{
        Text(emoji).font(.title)
            .onTapGesture {
                // activeReactions.append(emoji) // Removed reaction state
                // remove after animation duration
                DispatchQueue.main.asyncAfter(deadline: .now()+2.4){ /* activeReactions.removeFirst() */ }
            }
    }

    // Quick vote
    private func voteButton(side:ChatMsg.Sender,label:String)->some View{
        Text(label)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.vertical,6)
            .padding(.horizontal,20)
            .background(voted ? Color.clear : (side == .a ? AppTheme.primary : AppTheme.accent))
            .onTapGesture {
                guard voted else { return }
                if side == .a { votesA += 1 } else { votesB += 1 }
                voted = true
            }
    }

    private func seed(){
        // Build an extended mock conversation so spectators see depth
        let sideAExtras = [
            "I predicted their rotations every round—check my pings on minimap.",
            "My utility usage forced their duelists to waste cooldowns early.",
            "I won the mental game; their IGL admitted it post-match.",
            "When you look at ADR I’m 30% ahead—impact speaks louder than K/D."
        ].shuffled().prefix(3)

        let sideBExtras = [
            "Your ‘prediction’ was luck; I counter-flanked and caught you twice.",
            "Utility is pointless if you burn it with no follow-up—basic economics.",
            "We adapted mid-game and you went 3-10 afterwards—momentum lost.",
            "ADR ignores entry damage vs finishing—context matters."
        ].shuffled().prefix(3)

        messages = [
            ChatMsg(kind: .text(dispute.statementA), sender:.a),
            ChatMsg(kind: .text(dispute.statementB), sender:.b),
        ]

        // Interleave extra arguments with AI probing
        for i in 0..<3 {
            messages.append(ChatMsg(kind: .text(Array(sideAExtras)[i]), sender:.a))
            messages.append(ChatMsg(kind: .text("AI: Noted. Counter-argument?"), sender:.ai))
            messages.append(ChatMsg(kind: .text(Array(sideBExtras)[i]), sender:.b))
            messages.append(ChatMsg(kind: .text("AI: Let’s keep dissecting the core claim."), sender:.ai))
        }

        messages.append(ChatMsg(kind: .text("AI: We’ve surfaced both micro- and macro-level concerns. Shall we move to closing statements?"), sender:.ai))
        votesA = dispute.votesA
        votesB = dispute.votesB
    }

    // Opponent suggestions
    private var opponentSection: some View {
        VStack(alignment:.leading,spacing:8){
            Text("Challenge someone on the other side")
                .font(.caption)
            let opponents = social.opponentSuggestions(exclude: authService.currentUser?.id.uuidString ?? "")
            ScrollView(.horizontal,showsIndicators:false){
                HStack(spacing:12){
                    ForEach(opponents){ u in
                        Button(action:{ social.createClashBetween(authService.currentUser?.id.uuidString ?? "", u.id) }){
                            VStack{
                                AsyncImage(url: social.avatarURL(id:u.id, size:60)) { phase in
                                    if let img = phase.image {
                                        img.resizable()
                                    } else {
                                        Color.gray
                                    }
                                }
                                    .frame(width:50,height:50).clipShape(Circle())
                                Text(u.displayName).font(.caption2)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func send(){
        let sender: ChatMsg.Sender = meIsA ? .a : .b
        // If sending image
        if let img = pickedImage {
            messages.append(ChatMsg(kind:.image(img), sender: sender))
            pickedImage = nil
            pickerItem = nil
            updateSummary()
            return
        }

        // Moderation check
        guard ModerationService.isClean(input) else { input = ""; return }

        messages.append(ChatMsg(kind:.text(input), sender: sender))
        if sender == .a { votesA += 1 } else { votesB += 1 }
        voted = true
        input = ""
        aiRespond()
        updateSummary()
    }

    private func aiRespond(){
        aiThinking = true
        DispatchQueue.main.asyncAfter(deadline:.now()+1.0){
            messages.append(ChatMsg(kind: .text("AI: Thanks for sharing. I’d like the other party to clarify their stance on that."), sender:.ai))
            aiThinking = false
        }
    }

    @ViewBuilder
    private func bubble(for msg:ChatMsg, showAvatar: Bool)-> some View {
        HStack(alignment:.bottom,spacing:4){
            if msg.sender == .a { avatarView(for: .a, visible: showAvatar) }
            if msg.sender == .b { Spacer() }
            VStack(alignment: msg.sender == .a ? .leading : .trailing){
                content(for: msg)
                    .font(AppTheme.body())
                    .foregroundColor(msg.pending ? .gray : AppTheme.textPrimary)
                    .padding(AppTheme.spacingMD)
                    .background(bubbleGradient(for: msg))
                    .clipShape(RoundedRectangle(cornerRadius: bubbleCorner(for: msg)))
                    .shadow(color: Color.black.opacity(0.05), radius:3, x:0, y:1)
                    .overlay(alignment: .topTrailing) {
                        if let emo = reactions[msg.id] {
                            Text(emo)
                                .font(.system(size: 16))
                                .padding(4)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
            }
            if msg.sender == .a { Spacer() }
            if msg.sender == .b { avatarView(for: .b, visible: showAvatar) }
        }
        .transition(.move(edge: msg.sender == .a ? .leading : .trailing).combined(with:.opacity))
        .animation(.easeOut(duration:0.25), value: messages.count)
        .id(msg.id)
        .onLongPressGesture(minimumDuration: 0.4) {
            guard featureFlags.reactionsEnabled else { return }
            activeReactionTarget = msg.id
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showReactionPicker = true }
        }
        .contextMenu{
            switch msg.kind {
            case .text(let t):
                Button{ UIPasteboard.general.string = t } label:{ Text("Copy") }
                Button{ shareText(t) } label:{ Label("Share",systemImage:"square.and.arrow.up") }
            case .image(let ui):
                Button{ shareImage(ui) } label:{ Label("Share", systemImage: "square.and.arrow.up") }
            case .file(let url):
                Button{ shareText(url.absoluteString) } label:{ Label("Share", systemImage: "square.and.arrow.up") }
            }
        }
    }

    private func bubbleCorner(for msg: ChatMsg) -> CGFloat {
        guard case .text(let text) = msg.kind else { return 20 }
        let lineCount = text.split(separator: "\n").count
        let approxLines = max(lineCount, text.count / 40)
        return approxLines >= 4 ? 10 : 20
    }

    // Avatar helper
    @ViewBuilder
    private func avatarView(for sender: ChatMsg.Sender, visible: Bool) -> some View {
        if !visible {
            Color.clear.frame(width:32, height:32)
        } else {
            switch sender {
            case .a:
                AsyncImage(url: social.avatarURL(id: dispute.id+"a", size:64)) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:32, height:32)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.primary, lineWidth:1))
            case .b:
                AsyncImage(url: social.avatarURL(id: dispute.id+"b", size:64)) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:32, height:32)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.accent, lineWidth:1))
            case .ai:
                Image(systemName: "brain.head.profile").resizable()
                    .frame(width:32, height:32)
                    .foregroundColor(.purple)
            }
        }
    }

    @ViewBuilder private func content(for msg:ChatMsg)-> some View{
        switch msg.kind {
        case .text(let t):
            if let video = videoURL(from: t), let thumb = youtubeThumbnailURL(from: video) {
                VideoPreviewView(videoURL: video, thumbnailURL: thumb) {
                    videoToPlay = video
                }
            } else if let url = URL(string: t), url.scheme?.hasPrefix("http") == true {
                if url.pathExtension.lowercased() == "gif" {
                    GIFPreview(url: url)
                } else if url.pathExtension.lowercased() == "pdf" {
                    PDFPreview(url: url)
                } else {
                    LinkPreviewCard(url: url)
                }
            } else {
                Text(t).font(.body).foregroundColor(.primary)
            }
        case .image(let u):
            Image(uiImage:u)
                .resizable()
                .scaledToFill()
                .frame(maxWidth:200,maxHeight:200)
                .clipped()
                .cornerRadius(12)
        case .file(let url):
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(url.lastPathComponent)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text("Tap to share")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                shareText(url.absoluteString)
            }
        }
    }

    private func shareText(_ text:String){
        guard let window = UIApplication.shared.windows.first else { return }
        let av = UIActivityViewController(activityItems:[text], applicationActivities:nil)
        window.rootViewController?.present(av, animated:true)
    }

    private func shareImage(_ image: UIImage) {
        guard let window = UIApplication.shared.windows.first else { return }
        let av = UIActivityViewController(activityItems:[image], applicationActivities:nil)
        window.rootViewController?.present(av, animated:true)
    }

    private func loadPickedImage(){
        guard let item = pickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let ui = UIImage(data:data){
                pickedImage = ui
                enqueueMessage(ChatMsg(kind: .image(ui), sender: meIsA ? .a : .b, pending: !network.isOnline))
            }
        }
    }

    private func handlePickedFile(_ url: URL) {
        enqueueMessage(ChatMsg(kind: .file(url), sender: meIsA ? .a : .b, pending: !network.isOnline))
    }

    private func enqueueMessage(_ msg: ChatMsg) {
        messages.append(msg)
        if !msg.pending {
            // here you'd send to server
        } else {
            // store to outbox
            pendingOutbox.append(msg.id)
        }
    }

    @State private var pendingOutbox: [UUID] = []

    private func attemptResend() {
        guard network.isOnline else { return }
        for id in pendingOutbox {
            if let idx = messages.firstIndex(where: { $0.id == id }) {
                messages[idx].pending = false
            }
        }
        pendingOutbox.removeAll()
    }

    private func bubbleGradient(for msg:ChatMsg)->LinearGradient{
        switch msg.sender {
        case .ai:
            return LinearGradient(colors:[Color(UIColor.secondarySystemBackground)], startPoint:.topLeading, endPoint:.bottomTrailing)
        case .a:
            return LinearGradient(colors:[AppTheme.primary.opacity(0.15), AppTheme.primary.opacity(0.05)], startPoint:.topLeading, endPoint:.bottomTrailing)
        case .b:
            return LinearGradient(colors:[AppTheme.accent.opacity(0.15), AppTheme.accent.opacity(0.05)], startPoint:.topLeading, endPoint:.bottomTrailing)
        }
    }

    // MARK: - Versus Header
    private var versusSection: some View {
        HStack(alignment:.center, spacing:16) {
            VStack(spacing:4){
                AsyncImage(url: social.avatarURL(id: dispute.id+"a", size:120)) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:56,height:56)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(votesA > votesB ? AppTheme.primary : (votesA == votesB ? Color.secondary : Color.primary.opacity(0.3)), lineWidth: 3)
                        .shadow(color: votesA > votesB ? AppTheme.primary.opacity(0.6) : .clear, radius: 6)
                )
                Text(sideAName)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Text("VS")
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)

            VStack(spacing:4){
                AsyncImage(url: social.avatarURL(id: dispute.id+"b", size:120)) { phase in
                    (phase.image ?? Image(systemName:"person.circle")).resizable()
                }
                .frame(width:56,height:56)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(votesB > votesA ? AppTheme.accent : (votesA == votesB ? Color.secondary : Color.accent.opacity(0.3)), lineWidth: 3)
                        .shadow(color: votesB > votesA ? AppTheme.accent.opacity(0.6) : .clear, radius: 6)
                )
                Text(sideBName)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .opacity(avatarOpacity)
    }

    // Simple blur view helper
    struct BlurView: UIViewRepresentable {
        var style: UIBlurEffect.Style = .systemThinMaterial
        func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: style)) }
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    }

    // Pages
    private func chatPage(for side:ChatMsg.Sender) -> some View {
        ScrollViewReader { proxy in
            HStack(spacing:0){
                // Heat meter sidebar
                if featureFlags.heatMeterEnabled {
                    HeatMeterView(messages: filtered)
                        .frame(width: 4)
                }

                ScrollView {
                    VStack(spacing:12){
                        let filtered = messages.filter { $0.sender == side || $0.sender == .ai }
                        ForEach(filtered.indices, id: \.self) { idx in
                            let msg = filtered[idx]
                            let showAvatar = idx == 0 || filtered[idx - 1].sender != msg.sender
                            bubble(for: msg, showAvatar: showAvatar)
                        }

                        // Typing indicator
                        if aiThinking {
                            typingIndicatorBubble
                        }
                        // GeometryReader to capture offset
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("chatScroll")).minY)
                        }
                        .frame(height: 0)
                    }
                    .padding()
                    // bottom sentinel to detect distance from bottom
                    GeometryReader { geo in
                        Color.clear.preference(key: BottomOffsetKey.self, value: geo.frame(in: .named("chatScroll")).maxY)
                    }
                    .frame(height:1)
                }
                // Custom pull-to-refresh morph icon
                .overlay(alignment: .top) {
                    if showRefreshSuccess {
                        Image(systemName: "checkmark")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.success)
                            .transition(.scale.combined(with:.opacity))
                            .padding(.top, -32)
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.primary)
                            .rotationEffect(.degrees(pullProgress * 180))
                            .scaleEffect(0.7 + pullProgress * 0.4)
                            .opacity(pullProgress)
                            .padding(.top, -32)
                    }
                }
            }
            .coordinateSpace(name: "chatScroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                // Collapse header (existing logic)
                let newScale = max(0.6, 1 - (-value / 240))
                withAnimation(.easeOut(duration: 0.2)) { headerScale = newScale }

                // Track pull offset (positive values)
                pullOffset = max(0, value)

                // Trigger refresh when pulled enough
                if pullOffset > 80, !hasTriggeredRefresh {
                    hasTriggeredRefresh = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        social.fetchLiveClashes() // example refresh
                    }
                }

                // Show success checkmark after release
                if hasTriggeredRefresh && pullOffset == 0 {
                    hasTriggeredRefresh = false
                    showRefreshSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { showRefreshSuccess = false }
                }
            }
            .onPreferenceChange(BottomOffsetKey.self) { bottom in
                // When bottom>150 show button
                withAnimation { showScrollToBottom = bottom < -150 }
            }
            .onChange(of: messages.count){ _ in withAnimation{ proxy.scrollTo(messages.last?.id,anchor:.bottom)} }
        }
    }

    // Bottom offset key
    private struct BottomOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
    }

    private func scrollToBottom() {
        scrollTo(id: messages.last?.id)
    }

    private func scrollTo(id: UUID?) {
        guard let id else { return }
        DispatchQueue.main.async {
            withAnimation {
                // Use NotificationCenter to post scroll request; handled in onChange of messages maybe
            }
        }
    }

    // MARK: - Heat Meter View
    private struct HeatMeterView: View {
        let messages: [ChatMsg]

        private func color(for msg: ChatMsg) -> Color {
            guard case .text(let txt) = msg.kind else { return .blue }
            let exclam = txt.filter { $0 == "!" }.count
            let capsRatio = Double(txt.filter { $0.isUppercase }.count) / Double(max(1, txt.count))
            let angryWords = ["hate", "stupid", "trash", "noob"]
            let hasAngry = angryWords.contains { txt.lowercased().contains($0) }
            let score = Double(exclam) * 0.3 + capsRatio * 0.5 + (hasAngry ? 0.4 : 0)
            switch score {
            case 0..<0.3: return .blue
            case 0.3..<0.6: return .orange
            default: return .red
            }
        }

        var body: some View {
            GeometryReader { geo in
                VStack(spacing: 4) {
                    ForEach(messages) { msg in
                        Rectangle()
                            .fill(color(for: msg))
                            .frame(height: 8)
                            .cornerRadius(2)
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: geo.size.width)
            }
        }
    }

    private var resolutionPage: some View {
        ScrollView{
            VStack(alignment:.leading,spacing:20){
                Text("AI Resolution")
                    .font(.headline)
                Text(resolutionText)

                Button(action:{ showShare = true }){
                    Label("Share Result", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .frame(maxWidth:.infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showShare){
            ActivityViewController(activityItems: [shareMessage, generateShareImage()])
        }
    }

    @State private var showShare = false

    private var shareMessage: String {
        "Crashout debate: \(sideAName) vs \(sideBName) — Verdict: \(resolutionText) #Crashout"
    }

    private func generateShareImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1080, height: 566))
        return renderer.image { ctx in
            // Background gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [AppTheme.primary.cgColor!, AppTheme.accent.cgColor!] as CFArray, locations: [0,1])!
            ctx.cgContext.drawLinearGradient(gradient, start: CGPoint(x:0,y:0), end: CGPoint(x:1080,y:566), options: [])

            // Title
            let title = "\(sideAName) vs \(sideBName)"
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 64),
                .foregroundColor: UIColor.white
            ]
            let titleSize = title.size(withAttributes: titleAttr)
            title.draw(at: CGPoint(x: (1080 - titleSize.width)/2, y: 120), withAttributes: titleAttr)

            // Verdict
            let verdict = resolutionText
            let verdictAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let rect = CGRect(x: 80, y: 280, width: 920, height: 240)
            verdict.draw(with: rect, options: .usesLineFragmentOrigin, attributes: verdictAttr, context: nil)
        }
    }

    private var resolutionText: String {
        if votesA == votesB {
            return "After weighing the evidence, the debate is currently tied. Both sides presented compelling but inconclusive arguments. I recommend additional data or a deciding round."
        }
        let winner = votesA > votesB ? "Side A" : "Side B"
        return "Considering the presented facts, logical coherence, and audience votes, **\(winner)** made the stronger case. Key determining factors included statistical backing, situational awareness, and adaptability under pressure."
    }

    // Tab label helper
    private func tabLabel(title:String,index:Int,color:Color)->some View{
        Text(title)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            // Keep selected tab white text; unselected uses its theme color for full contrast on white background
            .foregroundColor(selectedTab==index ? Color.white : color)
            .padding(.vertical,6)
            .frame(maxWidth:.infinity)
            .background(
                ZStack{
                    if selectedTab==index {
                        RoundedRectangle(cornerRadius:12).fill(color.opacity(0.8)).shadow(radius:4)
                    }
                }
            )
            .onTapGesture { withAnimation(.easeInOut){ selectedTab = index } }
    }

    // old shouldShow no longer needed

    private struct ToggleChip: View {
        let title: String
        @Binding var isOn: Bool
        let color: Color
        var body: some View {
            HStack(spacing:4){
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
                    .font(.caption2)
                Text(title)
            }
            .font(.caption2)
            .padding(.horizontal,10).padding(.vertical,6)
            .background(isOn ? color : Color.white.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius:12).stroke(Color.white.opacity(0.6), lineWidth:1))
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(isOn ? 1.0 : 0.7)
            .onTapGesture { withAnimation{ isOn.toggle() } }
        }
    }

    // MARK: - Typing Indicator Bubble
    private var typingIndicatorBubble: some View {
        HStack {
            Spacer(minLength: 40)
            HStack(spacing: 6) {
                ForEach(0..<3) { idx in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 6, height: 6)
                        .opacity(0.7)
                        .scaleEffect(typingDotScale[idx])
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever().delay(Double(idx) * 0.15), value: typingDotScale[idx])
                }
            }
            .padding(12)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Spacer(minLength: 40)
        }
        .onAppear { startTypingAnimation() }
    }

    @State private var typingDotScale: [CGFloat] = [0.5, 0.5, 0.5]

    private func startTypingAnimation() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                    typingDotScale[i] = 1.0
                }
            }
        }
    }

    // Video player sheet
    @State private var videoToPlay: URL? = nil

    // Helper to detect supported video links (YouTube for now)
    private func videoURL(from text: String) -> URL? {
        guard let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        let host = url.host ?? ""
        if host.contains("youtu.be") || host.contains("youtube.com") {
            return url
        }
        return nil
    }

    // MARK: - Video thumbnail helper
    private func youtubeThumbnailURL(from url: URL) -> URL? {
        // Extract video ID from common YouTube URL patterns
        let urlString = url.absoluteString
        if let range = urlString.range(of: "youtu.be/") {
            let id = String(urlString[range.upperBound...]).components(separatedBy: ["?", "&"]).first ?? ""
            return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
        }
        if let comp = URLComponents(url: url, resolvingAgainstBaseURL: false), comp.host?.contains("youtube.com") == true {
            if let id = comp.queryItems?.first(where: { $0.name == "v" })?.value {
                return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
            }
        }
        return nil
    }

    // MARK: - Message Search View
    private struct MessageSearchView: View {
        let messages: [ChatMsg]
        var didSelect: (ChatMsg) -> Void
        @Environment(\.dismiss) private var dismiss
        @State private var query: String = ""
        var filtered: [ChatMsg] {
            guard !query.isEmpty else { return [] }
            return messages.filter {
                if case .text(let t) = $0.kind { return t.lowercased().contains(query.lowercased()) }
                return false
            }
        }
        var body: some View {
            NavigationView {
                List {
                    ForEach(filtered) { msg in
                        if case .text(let t) = msg.kind {
                            Text(t)
                                .lineLimit(2)
                                .onTapGesture {
                                    didSelect(msg)
                                    dismiss()
                                }
                        }
                    }
                }
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Search Messages")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            }
        }
    }

    // MARK: - ReactionPicker Component
    private struct ReactionPicker: View {
        let emojis = ["👍", "😂", "😮", "🚀", "😢"]
        var didSelect: (String) -> Void
        var onCancel: () -> Void
        @State private var scale: CGFloat = 0.1
        var body: some View {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { onCancel() }

                ZStack {
                    ForEach(emojis.indices, id: \.self) { idx in
                        let angle = Double(idx) / Double(emojis.count) * Double.pi * 2 - Double.pi/2
                        let radius: CGFloat = 60
                        Text(emojis[idx])
                            .font(.system(size: 28))
                            .frame(width:44,height:44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius:2)
                            .position(x: radius * cos(angle), y: radius * sin(angle))
                            .onTapGesture {
                                didSelect(emojis[idx])
                            }
                    }
                }
                .frame(width: 0, height: 0)
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response:0.4,dampingFraction:0.7)) { scale = 1 }
                }
            }
        }
    }

    // MARK: - GIF Preview (basic via WebView)
    private struct GIFPreview: UIViewRepresentable {
        let url: URL
        func makeUIView(context: Context) -> WKWebView {
            let wv = WKWebView()
            wv.scrollView.isScrollEnabled = false
            wv.backgroundColor = .clear
            wv.isOpaque = false
            return wv
        }
        func updateUIView(_ uiView: WKWebView, context: Context) {
            uiView.load(URLRequest(url: url))
        }
    }

    // MARK: - PDF Preview (first page thumbnail)
    private struct PDFPreview: View {
        let url: URL
        var body: some View {
            if let doc = PDFDocument(url: url), let page = doc.page(at: 0) {
                let thumb = page.thumbnail(of: CGSize(width: 200, height: 260), for: .cropBox)
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
                    .cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "doc.richtext").font(.largeTitle)
                    Text(url.lastPathComponent).font(.caption)
                }
            }
        }
    }
}

#if DEBUG
struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(dispute: MockDispute(id: "1", title: "Test", statementA: "A", statementB: "B", votesA: 0, votesB: 0))
            .environmentObject(SocialAPIService())
    }
}
#endif