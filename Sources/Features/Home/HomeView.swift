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
                    PullCardButton(gameState: gameState)
                        .accessibilityIdentifier("home_pull_button")

                    // Bottom clearance for floating tab bar.
                    Color.clear.frame(height: 80)
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
                    .foregroundColor(VitaTheme.Colors.textPrimary)

                Spacer()

                Text("\(gameState.todayHabitsCompleted)/\(gameState.habitCards.count)")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(VitaTheme.Colors.textSecondary)
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
            .overlay(alignment: .trailing) {
                // Right-edge fade gradient hints the row is horizontally
                // scrollable when more than 4 missions are present.
                LinearGradient(
                    colors: [VitaTheme.Colors.background.opacity(0), VitaTheme.Colors.background],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 40)
                .allowsHitTesting(false)
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
                .foregroundColor(VitaTheme.Colors.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.md)
                .fill(VitaTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.md)
                        .stroke(VitaTheme.Colors.border, lineWidth: 1)
                )
                .cardShadow(VitaTheme.Shadows.cardTight)
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
                    .foregroundColor(VitaTheme.Colors.textPrimary)

                Spacer()

                Text("\(gameState.totalCardsCollected) collected")
                    .font(VitaTheme.Fonts.caption)
                    .foregroundColor(VitaTheme.Colors.textSecondary)
            }
            .padding(.horizontal)

            if gameState.healthCards.isEmpty {
                // Empty state — visible placeholder that explains what
                // goes here and how to populate it.
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 40))
                        .foregroundColor(VitaTheme.Colors.textTertiary)
                    Text("No health data yet")
                        .font(VitaTheme.Fonts.body)
                        .foregroundColor(VitaTheme.Colors.textPrimary)
                    Text("Connect Health in Settings → Privacy to start collecting cards")
                        .font(VitaTheme.Fonts.caption)
                        .foregroundColor(VitaTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                        .fill(VitaTheme.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                                .stroke(VitaTheme.Colors.border, lineWidth: 1)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        )
                )
                .padding(.horizontal)
            } else {
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
                        .foregroundColor(VitaTheme.Colors.textPrimary)
                    
                    Text(card.description)
                        .font(VitaTheme.Fonts.body)
                        .foregroundColor(VitaTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // Current stats
                    HStack(spacing: 32) {
                        VStack {
                            Text("\(Int(card.currentValue))")
                                .font(VitaTheme.Fonts.statNumber)
                                .foregroundColor(VitaTheme.Colors.primary)
                            Text(card.unit)
                                .font(VitaTheme.Fonts.caption)
                                .foregroundColor(VitaTheme.Colors.textTertiary)
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
    @ObservedObject var gameState: GameState
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    var body: some View {
        Button(action: {
            // Trigger gacha animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isAnimating = false
                self.showConfetti = true
                // Pull a new daily card
                if let newCard = self.gameState.pullDailyCard() {
                    print("Pulled new card: \(newCard.name)")
                }
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
                        .foregroundColor(VitaTheme.Colors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Pull")
                        .font(VitaTheme.Fonts.titleMedium)
                        .foregroundColor(VitaTheme.Colors.textPrimary)
                    
                    Text("Try your luck!")
                        .font(VitaTheme.Fonts.caption)
                        .foregroundColor(VitaTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(VitaTheme.Colors.textTertiary)
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