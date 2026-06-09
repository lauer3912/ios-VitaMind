import SwiftUI

struct CoachView: View {
    @EnvironmentObject var gameState: GameState
    @State private var userMessage = ""
    @State private var messages: [CoachMessage] = [
        CoachMessage(text: "Welcome, trainer! I'm your VitaCoach. How can I help you today?", isUser: false, timestamp: Date())
    ]
    @State private var isTyping = false
    @AppStorage("vita_coach_disclaimer_acknowledged") private var disclaimerAcknowledged: Bool = false
    @State private var showFirstTimeDisclaimer: Bool = false
    
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
            // toolbarColorScheme removed — let nav bar follow appearance
        }
        .accessibilityIdentifier("coach_view")
        .onAppear {
            if !disclaimerAcknowledged {
                showFirstTimeDisclaimer = true
            }
        }
        .alert("Important Medical Disclaimer", isPresented: $showFirstTimeDisclaimer) {
            Button("I Understand") {
                disclaimerAcknowledged = true
            }
        } message: {
            Text("VitaCoach provides general wellness information only, not medical advice. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional before making any medical decisions. If you think you may have a medical emergency, call 911 or your local emergency number immediately.")
        }
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
            do {
                let response = try await AIService.shared.sendMessage(currentMessage, history: Array(history))
                let aiMsg = CoachMessage(
                    text: response.text,
                    isUser: false,
                    timestamp: Date(),
                    citations: response.citations
                )
                messages.append(aiMsg)
            } catch {
                // Check if API key is not configured
                if !AIService.shared.isConfigured {
                    let aiMsg = CoachMessage(
                        text: "⚠️ AI service is not configured. Please go to the [Settings] tab and set up your API Key to continue.",
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
            // Turn the typing indicator off *after* the response (or error)
            // lands, so the user actually sees it. Previously this was set
            // before the `try` and the indicator was effectively invisible.
            isTyping = false
        }
    }
}

struct CoachMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    /// Citations extracted from the AI's "### Sources" block (Apple Guideline
    /// 1.4.1, 2026-06-09 build 10). User messages and the welcome message
    /// have an empty array. AI messages get the citations rendered as a
    /// dedicated footer card directly below the message bubble.
    var citations: [Citation] = []
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
                    .foregroundColor(VitaTheme.Colors.textPrimary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(VitaTheme.Colors.success)
                        .frame(width: 8, height: 8)
                    Text("Online • Ready to help")
                        .font(VitaTheme.Fonts.caption)
                        .foregroundColor(VitaTheme.Colors.textSecondary)
                }

                // Medical disclaimer (Apple Guideline 1.4.1, 2026-06-08)
                Text("For informational purposes only — not medical advice. Consult a qualified healthcare professional before making medical decisions.")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(VitaTheme.Colors.textSecondary)
                    .padding(.top, 2)
                    .accessibilityIdentifier("coach_medical_disclaimer")
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                .fill(VitaTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                        .stroke(VitaTheme.Colors.border, lineWidth: 1)
                )
                .cardShadow(VitaTheme.Shadows.cardTight)
        )
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}

struct CoachMessageBubble: View {
    let message: CoachMessage
    let index: Int
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
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
                        .foregroundColor(VitaTheme.Colors.textPrimary)
                }
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                MarkdownText(content: message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isUser ? VitaTheme.Colors.primary : VitaTheme.Colors.surface)
                    )

                // Citation footer (Apple Guideline 1.4.1, build 10).
                // Rendered as a separate card directly below the AI message
                // so reviewers and users can find sources at a glance.
                if !message.isUser && !message.citations.isEmpty {
                    CitationFooterView(citations: message.citations)
                }

                Text(formatTime(message.timestamp))
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(VitaTheme.Colors.textTertiary)
            }

            if message.isUser {
                ZStack {
                    Circle()
                        .fill(VitaTheme.Colors.accent.opacity(0.8))
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(VitaTheme.Colors.textPrimary)
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

// MARK: - Citation Footer (Apple Guideline 1.4.1, build 10)

/// Renders the "Sources" card that appears directly below each AI response.
/// Apple specifically called out (2026-06-09 rejection) that citations
/// "should be easy for the user to find", so this view is intentionally
/// visually distinct from the prose bubble: it has its own header, an info
/// icon, a numbered list of tappable links, and a domain whitelist
/// indication. Non-whitelisted domains (if the model ever deviates) are
/// visually flagged with a warning.
struct CitationFooterView: View {
    let citations: [Citation]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(VitaTheme.Colors.primary)
                Text("Sources")
                    .font(VitaTheme.Fonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(VitaTheme.Colors.textPrimary)
                Text("(\(citations.count))")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(VitaTheme.Colors.textSecondary)
                Spacer()
            }

            // Numbered citation list
            ForEach(Array(citations.enumerated()), id: \.offset) { index, citation in
                CitationRow(index: index + 1, citation: citation)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(VitaTheme.Colors.surface.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(VitaTheme.Colors.primary.opacity(0.4), lineWidth: 1)
        )
        .frame(maxWidth: 280, alignment: .leading)
        .accessibilityIdentifier("coach_citation_footer")
    }
}

/// Single row inside the citation footer. Shows [N], the title as a tappable
/// link, the host, and a warning icon if the host isn't on the Apple
/// 1.4.1 whitelist.
private struct CitationRow: View {
    let index: Int
    let citation: Citation

    private var isWhitelisted: Bool {
        HealthSourceCatalog.isAllowed(citation.url)
    }

    private var host: String {
        URL(string: citation.url)?.host ?? citation.url
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("[\(index)]")
                .font(VitaTheme.Fonts.caption)
                .fontWeight(.bold)
                .foregroundColor(VitaTheme.Colors.primary)

            VStack(alignment: .leading, spacing: 1) {
                Link(destination: URL(string: citation.url) ?? URL(string: "https://example.com")!) {
                    Text(citation.title.isEmpty ? HealthSourceCatalog.defaultTitle(for: citation.url) : citation.title)
                        .font(VitaTheme.Fonts.caption)
                        .foregroundColor(VitaTheme.Colors.primary)
                        .underline()
                        .lineLimit(2)
                }
                Text(host)
                    .font(.system(size: 10))
                    .foregroundColor(VitaTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            if !isWhitelisted {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(VitaTheme.Colors.accent)
                    .accessibilityLabel("Non-whitelisted source")
            }
        }
        .accessibilityIdentifier("coach_citation_row_\(index)")
    }
}

// MARK: - Markdown Text Renderer

struct MarkdownText: View {
    let content: String
    
    private var cleanedContent: String {
        // Remove <think>...</think> blocks entirely from display
        content.replacingOccurrences(
            of: "<think>[\\s\\S]*?</think>",
            with: "",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        if let attributed = try? AttributedString(
            markdown: cleanedContent,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        ) {
            Text(attributed)
                .font(VitaTheme.Fonts.body)
                .foregroundColor(VitaTheme.Colors.textPrimary)
        } else {
            Text(cleanedContent)
                .font(VitaTheme.Fonts.body)
                .foregroundColor(VitaTheme.Colors.textPrimary)
        }
    }
}

// MARK: - Typing Indicator (improved)

struct TypingIndicatorView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
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
                    .foregroundColor(VitaTheme.Colors.textPrimary)
            }
            
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
                RoundedRectangle(cornerRadius: 18)
                    .fill(VitaTheme.Colors.surface)
            )
            
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
                .foregroundColor(VitaTheme.Colors.textPrimary)
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