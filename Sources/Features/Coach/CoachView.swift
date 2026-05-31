import SwiftUI

struct CoachView: View {
    @EnvironmentObject var gameState: GameState
    @State private var userMessage = ""
    @State private var messages: [CoachMessage] = [
        CoachMessage(text: "Welcome, trainer! I'm your VitaCoach. How can I help you today?", isUser: false, timestamp: Date())
    ]
    @State private var isTyping = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VitaTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Coach avatar header
                    CoachHeaderView()
                        .accessibilityIdentifier("coach_header")
                    
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                                    CoachMessageBubble(message: message, index: index)
                                }
                                
                                if isTyping {
                                    TypingIndicatorView()
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input bar
                    CoachInputBar(
                        text: $userMessage,
                        onSend: sendMessage
                    )
                    .accessibilityIdentifier("coach_input_bar")
                }
            }
            .navigationTitle("Coach")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .accessibilityIdentifier("coach_view")
    }
    
    private func sendMessage() {
        guard !userMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMsg = CoachMessage(text: userMessage, isUser: true, timestamp: Date())
        messages.append(userMsg)
        let currentMessage = userMessage
        userMessage = ""
        isTyping = true
        
        // Convert to ChatMessage format for AIService
        let history = messages.dropLast().map { ChatMessage(role: $0.isUser ? "user" : "assistant", content: $0.text) }
        
        Task { @MainActor in
            isTyping = false
            do {
                let response = try await AIService.shared.sendMessage(currentMessage, history: Array(history))
                let aiMsg = CoachMessage(
                    text: response,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(aiMsg)
            } catch {
                let aiMsg = CoachMessage(
                    text: "抱歉，AI 服务暂时不可用: \(error.localizedDescription)",
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(aiMsg)
            }
        }
    }
}

struct CoachMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct CoachHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [VitaTheme.Colors.primary, VitaTheme.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("VitaCoach")
                    .font(VitaTheme.Fonts.title)
                    .foregroundColor(.white)
                
                Text("Online • Ready to help")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(VitaTheme.Colors.success)
            }
            
            Spacer()
        }
        .padding()
        .background(VitaTheme.Colors.surface)
    }
}

struct CoachMessageBubble: View {
    let message: CoachMessage
    let index: Int
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(VitaTheme.Fonts.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                            .fill(message.isUser ? VitaTheme.Colors.primary : VitaTheme.Colors.surface)
                    )
                
                Text(formatTime(message.timestamp))
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            
            if !message.isUser { Spacer() }
        }
        .accessibilityIdentifier("coach_message_\(index)")
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicatorView: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(VitaTheme.Colors.primary)
                            .frame(width: 8, height: 8)
                            .offset(y: dotOffset)
                            .animation(
                                .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.15),
                                value: dotOffset
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                        .fill(VitaTheme.Colors.surface)
                )
            }
            Spacer()
        }
        .onAppear { dotOffset = -5 }
    }
}

struct CoachInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask VitaCoach...", text: $text)
                .font(VitaTheme.Fonts.body)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.xl)
                        .fill(VitaTheme.Colors.surface)
                )
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(text.isEmpty ? .gray : VitaTheme.Colors.primary)
            }
            .disabled(text.isEmpty)
        }
        .padding()
        .background(VitaTheme.Colors.surface)
    }
}