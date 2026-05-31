import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // XP Progress Bar
                    XPProgressBar(level: gameState.userLevel)
                        .padding(.horizontal)
                        .accessibilityIdentifier("home_xp_bar")
                    
                    // Today's mission cards
                    TodayMissionSection()
                        .accessibilityIdentifier("home_today_missions")
                    
                    // Health Cards Grid
                    HealthCardsSection()
                        .accessibilityIdentifier("home_health_cards")
                    
                    // Pull card button
                    PullCardButton()
                        .accessibilityIdentifier("home_pull_button")
                }
                .padding(.vertical)
            }
            .background(VitaTheme.Colors.background)
            .navigationTitle("VitaMindGo")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .accessibilityIdentifier("home_view")
    }
}

// MARK: - Today's Mission Section
struct TodayMissionSection: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Missions")
                    .font(VitaTheme.Fonts.title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(gameState.todayHabitsCompleted)/\(gameState.habitCards.count)")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(VitaTheme.Colors.primary.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(gameState.habitCards.enumerated()), id: \.element.id) { index, habit in
                        MissionCard(habit: habit, index: index)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MissionCard: View {
    let habit: HabitCard
    let index: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(habit.isCompletedToday ? VitaTheme.Colors.success : VitaTheme.Colors.surface)
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 22))
                    .foregroundColor(habit.isCompletedToday ? .white : Color(hex: habit.color))
            }
            
            Text(habit.name)
                .font(VitaTheme.Fonts.caption)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.md)
                .fill(VitaTheme.Colors.surface)
        )
        .accessibilityIdentifier("mission_card_\(index)")
    }
}

// MARK: - Health Cards Section
struct HealthCardsSection: View {
    @EnvironmentObject var gameState: GameState
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Stats")
                    .font(VitaTheme.Fonts.title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(gameState.totalCardsCollected) collected")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(gameState.healthCards.enumerated()), id: \.element.id) { index, card in
                    NavigationLink(destination: HealthCardDetailView(card: card)) {
                        GameCardView(card: card, isInteractive: true)
                    }
                    .accessibilityIdentifier("health_card_\(index)")
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HealthCardDetailView: View {
    let card: HealthCard
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ZStack {
            VitaTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                GameCardView(card: card, isInteractive: false)
                    .accessibilityIdentifier("detail_card")
                
                VStack(spacing: 16) {
                    Text(card.name)
                        .font(VitaTheme.Fonts.displayBold)
                        .foregroundColor(.white)
                    
                    Text(card.description)
                        .font(VitaTheme.Fonts.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    // Current stats
                    HStack(spacing: 32) {
                        VStack {
                            Text("\(Int(card.currentValue))")
                                .font(VitaTheme.Fonts.statNumber)
                                .foregroundColor(VitaTheme.Colors.primary)
                            Text(card.unit)
                                .font(VitaTheme.Fonts.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Pull Card Button
struct PullCardButton: View {
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    var body: some View {
        Button(action: {
            // Trigger gacha animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
                showConfetti = true
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(VitaTheme.Colors.primary)
                        .frame(width: 50, height: 50)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Pull")
                        .font(VitaTheme.Fonts.titleMedium)
                        .foregroundColor(.white)
                    
                    Text("Try your luck!")
                        .font(VitaTheme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                    .fill(VitaTheme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                            .stroke(VitaTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
        }
        .accessibilityIdentifier("pull_card_button")
    }
}