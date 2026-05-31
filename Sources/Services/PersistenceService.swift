import Foundation

final class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys
    private enum Keys {
        static let userLevel = "vita_user_level"
        static let healthCards = "vita_health_cards"
        static let habitCards = "vita_habit_cards"
        static let achievements = "vita_achievements"
        static let lastPullDate = "vita_last_pull_date"
        static let totalXPEarned = "vita_total_xp_earned"
        static let pullStreak = "vita_pull_streak"
    }
    
    private init() {}
    
    // MARK: - User Level
    
    func saveUserLevel(_ level: UserLevel) {
        if let data = try? encoder.encode(level) {
            defaults.set(data, forKey: Keys.userLevel)
        }
    }
    
    func loadUserLevel() -> UserLevel {
        guard let data = defaults.data(forKey: Keys.userLevel),
              let level = try? decoder.decode(UserLevel.self, from: data) else {
            return UserLevel(level: 1, currentXP: 0, totalXP: 0)
        }
        return level
    }
    
    // MARK: - Health Cards
    
    func saveHealthCards(_ cards: [HealthCard]) {
        if let data = try? encoder.encode(cards) {
            defaults.set(data, forKey: Keys.healthCards)
        }
    }
    
    func loadHealthCards() -> [HealthCard] {
        guard let data = defaults.data(forKey: Keys.healthCards),
              let cards = try? decoder.decode([HealthCard].self, from: data) else {
            return []
        }
        return cards
    }
    
    // MARK: - Habit Cards
    
    func saveHabitCards(_ cards: [HabitCard]) {
        if let data = try? encoder.encode(cards) {
            defaults.set(data, forKey: Keys.habitCards)
        }
    }
    
    func loadHabitCards() -> [HabitCard] {
        guard let data = defaults.data(forKey: Keys.habitCards),
              let cards = try? decoder.decode([HabitCard].self, from: data) else {
            return createDefaultHabits()
        }
        return cards
    }
    
    // MARK: - Achievements
    
    func saveAchievements(_ achievements: [Achievement]) {
        if let data = try? encoder.encode(achievements) {
            defaults.set(data, forKey: Keys.achievements)
        }
    }
    
    func loadAchievements() -> [Achievement] {
        guard let data = defaults.data(forKey: Keys.achievements),
              let achievements = try? decoder.decode([Achievement].self, from: data) else {
            return createDefaultAchievements()
        }
        return achievements
    }
    
    // MARK: - Pull State
    
    func saveLastPullDate(_ date: Date) {
        defaults.set(date, forKey: Keys.lastPullDate)
    }
    
    func loadLastPullDate() -> Date? {
        defaults.object(forKey: Keys.lastPullDate) as? Date
    }
    
    func canPullToday() -> Bool {
        guard let lastPull = loadLastPullDate() else { return true }
        return !Calendar.current.isDateInToday(lastPull)
    }
    
    // MARK: - XP
    
    func saveTotalXPEarned(_ xp: Int) {
        defaults.set(xp, forKey: Keys.totalXPEarned)
    }
    
    func loadTotalXPEarned() -> Int {
        defaults.integer(forKey: Keys.totalXPEarned)
    }
    
    func addXPEarned(_ xp: Int) {
        let current = loadTotalXPEarned()
        saveTotalXPEarned(current + xp)
    }
    
    // MARK: - Pull Streak
    
    func savePullStreak(_ streak: Int) {
        defaults.set(streak, forKey: Keys.pullStreak)
    }
    
    func loadPullStreak() -> Int {
        defaults.integer(forKey: Keys.pullStreak)
    }
    
    func incrementPullStreak() {
        let current = loadPullStreak()
        savePullStreak(current + 1)
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        let keys = [Keys.userLevel, Keys.healthCards, Keys.habitCards, Keys.achievements, Keys.lastPullDate, Keys.totalXPEarned, Keys.pullStreak]
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
    
    // MARK: - Defaults
    
    private func createDefaultHabits() -> [HabitCard] {
        [
            HabitCard(id: "habit_1", name: "Morning Walk", description: "Start your day with a refreshing walk", icon: "sunrise.fill", color: "FF9500", currentStreak: 0, longestStreak: 0, isCompletedToday: false, xpReward: 20),
            HabitCard(id: "habit_2", name: "Drink Water", description: "Stay hydrated throughout the day", icon: "drop.fill", color: "3498DB", currentStreak: 0, longestStreak: 0, isCompletedToday: false, xpReward: 10),
            HabitCard(id: "habit_3", name: "Meditation", description: "Clear your mind and relax", icon: "brain.head.profile", color: "6B4EFF", currentStreak: 0, longestStreak: 0, isCompletedToday: false, xpReward: 30),
            HabitCard(id: "habit_4", name: "Evening Stretch", description: "Relax your body before sleep", icon: "figure.cooldown", color: "9B59B6", currentStreak: 0, longestStreak: 0, isCompletedToday: false, xpReward: 15),
            HabitCard(id: "habit_5", name: "Read Book", description: "Read for at least 20 minutes", icon: "book.fill", color: "2ECC71", currentStreak: 0, longestStreak: 0, isCompletedToday: false, xpReward: 25),
        ]
    }
    
    private func createDefaultAchievements() -> [Achievement] {
        [
            Achievement(id: "ach_1", name: "First Steps", description: "Complete your first habit", icon: "star.fill", requirement: 1, progress: 0, isUnlocked: false, rarity: .common, xpReward: 50),
            Achievement(id: "ach_2", name: "Week Warrior", description: "Maintain a 7-day streak", icon: "flame.fill", requirement: 7, progress: 0, isUnlocked: false, rarity: .uncommon, xpReward: 100),
            Achievement(id: "ach_3", name: "Card Collector", description: "Collect 10 health cards", icon: "square.stack.fill", requirement: 10, progress: 0, isUnlocked: false, rarity: .common, xpReward: 75),
            Achievement(id: "ach_4", name: "Health Hero", description: "Reach 10,000 steps in a day", icon: "heart.fill", requirement: 1, progress: 0, isUnlocked: false, rarity: .uncommon, xpReward: 80),
            Achievement(id: "ach_5", name: "Mindful Master", description: "Complete 30 days of meditation", icon: "brain.head.profile", requirement: 30, progress: 0, isUnlocked: false, rarity: .rare, xpReward: 200),
            Achievement(id: "ach_6", name: "Shiny Hunter", description: "Collect your first shiny card", icon: "sparkle", requirement: 1, progress: 0, isUnlocked: false, rarity: .epic, xpReward: 150),
        ]
    }
}