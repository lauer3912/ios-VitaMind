import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            ZStack {
                VitaTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Streak summary
                        StreakSummaryView()
                            .accessibilityIdentifier("habits_streak_summary")

                        // Habit cards
                        VStack(spacing: 12) {
                            ForEach(Array(gameState.habitCards.enumerated()), id: \.element.id) { index, habit in
                                HabitCardView(habit: habit) {
                                    gameState.completeHabit(habit.id)
                                }
                                .accessibilityIdentifier("habit_card_\(index)")
                            }
                        }
                        .padding(.horizontal)

                        // Bottom breathing room so the last card never hides
                        // behind the floating tab bar.
                        Color.clear.frame(height: 80)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Habits")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .accessibilityIdentifier("habits_view")
    }
}

struct StreakSummaryView: View {
    @EnvironmentObject var gameState: GameState
    
    private var totalStreak: Int {
        gameState.habitCards.map(\.currentStreak).max() ?? 0
    }
    
    private var longestStreak: Int {
        gameState.habitCards.map(\.longestStreak).max() ?? 0
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StreakItem(
                icon: "flame.fill",
                value: totalStreak,
                label: "Current Streak",
                color: VitaTheme.Colors.warning
            )
            
            Divider()
                .frame(height: 40)
                .background(VitaTheme.Colors.surfaceLight)
            
            StreakItem(
                icon: "trophy.fill",
                value: longestStreak,
                label: "Best Streak",
                color: VitaTheme.Colors.accent
            )
            
            Divider()
                .frame(height: 40)
                .background(VitaTheme.Colors.surfaceLight)
            
            StreakItem(
                icon: "checkmark.seal.fill",
                value: gameState.todayHabitsCompleted,
                label: "Today",
                color: VitaTheme.Colors.success
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: VitaTheme.Radius.lg)
                .fill(VitaTheme.Colors.surface)
        )
        .padding(.horizontal)
    }
}

struct StreakItem: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text("\(value)")
                .font(VitaTheme.Fonts.statNumber)
                .foregroundColor(VitaTheme.Colors.textPrimary)
            
            Text(label)
                .font(VitaTheme.Fonts.statLabel)
                .foregroundColor(VitaTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}