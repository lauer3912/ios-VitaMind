import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedTab = 0
    @State private var tabBounceIndex: Int? = nil
    
    var body: some View {
        ZStack {
            // Background
            VitaTheme.Colors.background
                .ignoresSafeArea()
            
            // Main content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Pocket", systemImage: "star.circle.fill")
                    }
                    .tag(0)
                    .accessibilityIdentifier("tab_home")
                
                HabitsView()
                    .tabItem {
                        Label("Habits", systemImage: "checkmark.seal.fill")
                    }
                    .tag(1)
                    .accessibilityIdentifier("tab_habits")
                    .accessibilityIdentifier("tab_button_1")
                
                CoachView()
                    .tabItem {
                        Label("Coach", systemImage: "brain.head.profile")
                    }
                    .tag(2)
                    .accessibilityIdentifier("tab_coach")
                
                CollectionView()
                    .tabItem {
                        Label("Collection", systemImage: "square.stack.fill")
                    }
                    .tag(3)
                    .accessibilityIdentifier("tab_collection")
            }
            .tint(VitaTheme.Colors.primary)
            
            // Card pull animation overlay
            if gameState.showCardAnimation, let card = gameState.lastPulledCard {
                CardPullOverlay(card: card)
            }
        }
        .accessibilityIdentifier("main_content_view")
    }
}

// MARK: - Card Pull Overlay Animation
struct CardPullOverlay: View {
    let card: HealthCard
    @State private var opacity: Double = 0
    @State private var cardScale: CGFloat = 0.3
    @State private var cardRotation: Double = -30
    @State private var glowOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(opacity * 0.7)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 24) {
                Text("NEW CARD!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(VitaTheme.Colors.accent)
                    .tracking(4)
                    .opacity(opacity)
                
                GameCardView(card: card, isInteractive: false)
                    .scaleEffect(cardScale)
                    .rotationEffect(.degrees(cardRotation))
                    .opacity(opacity)
                
                Text(card.rarity.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(card.rarity.color)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Card entrance animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                cardScale = 1.0
                cardRotation = 0
                opacity = 1
            }
            
            // Glow pulse
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                glowOpacity = 1
            }
        }
    }
}

// MARK: - Main Tab Container
struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { index in
                TabButton(
                    index: index,
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            VitaTheme.Colors.surface
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
        )
    }
}

struct TabButton: View {
    let index: Int
    let isSelected: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1
    
    private var icon: String {
        switch index {
        case 0: return "star.circle.fill"
        case 1: return "checkmark.seal.fill"
        case 2: return "brain.head.profile"
        case 3: return "square.stack.fill"
        default: return "circle"
        }
    }
    
    private var label: String {
        switch index {
        case 0: return "Pocket"
        case 1: return "Habits"
        case 2: return "Coach"
        case 3: return "Collection"
        default: return ""
        }
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? VitaTheme.Colors.primary : .white.opacity(0.5))
                    .scaleEffect(scale)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? VitaTheme.Colors.primary : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier("tab_button_\(index)")
    }
}