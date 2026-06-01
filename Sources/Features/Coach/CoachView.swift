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
                // Check if API key is not configured
                if !AIService.shared.isConfigured {
                    let aiMsg = CoachMessage(
                        text: "⚠️ AI 服务未配置，请在【Settings】Tab 中设置 API Key 后重试。",
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMsg)
                } else {
                    let aiMsg = CoachMessage(
                        text: "Sorry, AI service is temporarily unavailable. \(error.localizedDescription)",
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiMsg)
                }
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
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [VitaTheme.Colors.primary, VitaTheme.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Bubble with tail indicator
                ZStack(alignment: message.isUser ? .bottomTrailing : .bottomLeading) {
                    Text(message.text)
                        .font(VitaTheme.Fonts.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            ChatBubbleShape(isUser: message.isUser)
                                .fill(message.isUser ? VitaTheme.Colors.primary : VitaTheme.Colors.surface)
                        )
                    
                    // Tail triangle
                    if !message.isUser {
                        Triangle()
                            .fill(VitaTheme.Colors.surface)
                            .frame(width: 12, height: 8)
                            .offset(x: -16, y: 4)
                    }
                }
                
                Text(formatTime(message.timestamp))
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            if message.isUser {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(VitaTheme.Colors.accent.opacity(0.8))
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            } else {
                Spacer()
            }
        }
        .accessibilityIdentifier("coach_message_\(index)")
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Chat Bubble Shape (rounded with tail)

struct ChatBubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        let tailSize: CGFloat = 8
        
        var path = Path()
        
        if isUser {
            // User bubble: tail on right side
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius - tailSize, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - tailSize, y: rect.minY + radius), control: CGPoint(x: rect.maxX - tailSize, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - tailSize, y: rect.maxY - radius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - radius - tailSize, y: rect.maxY), control: CGPoint(x: rect.maxX - tailSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - radius), control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        } else {
            // AI bubble: tail on left side
            path.move(to: CGPoint(x: rect.minX + radius + tailSize, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + radius + tailSize, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX + tailSize, y: rect.maxY - radius), control: CGPoint(x: rect.minX + tailSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + tailSize, y: rect.minY + radius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + radius + tailSize, y: rect.minY), control: CGPoint(x: rect.minX + tailSize, y: rect.minY))
        }
        
        path.closeSubpath()
        return path
    }
}

// Triangle shape for bubble tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Typing Indicator (improved)

struct TypingIndicatorView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [VitaTheme.Colors.primary, VitaTheme.Colors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(VitaTheme.Colors.primary.opacity(0.7))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animating ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                                value: animating
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    ChatBubbleShape(isUser: false)
                        .fill(VitaTheme.Colors.surface)
                )
            }
            
            Spacer()
        }
        .onAppear { animating = true }
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