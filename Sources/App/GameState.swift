import SwiftUI
import Combine

// MARK: - GameState (Central State Manager)
@MainActor
final class GameState: ObservableObject {
    // MARK: - Published Properties
    @Published var userLevel: UserLevel = UserLevel(level: 1, currentXP: 0, totalXP: 0)
    @Published var healthCards: [HealthCard] = []
    @Published var habitCards: [HabitCard] = []
    @Published var achievements: [Achievement] = []
    @Published var lastPulledCard: HealthCard?
    @Published var showCardAnimation: Bool = false
    @Published var totalCardsCollected: Int = 0
    @Published var todayHabitsCompleted: Int = 0
    @Published var currentXPAnimation: Int = 0
    @Published var isLoading: Bool = false
    @Published var isHealthKitAuthorized: Bool = false
    
    // MARK: - Services
    private let healthKit = HealthKitService.shared
    private let persistence = PersistenceService.shared
    private let miniMax = MiniMaxService.shared
    
    // MARK: - XP Config
    private let xpPerHabit = 25
    private let xpPerCard = 50
    private let xpPerStreak = 10
    
    // MARK: - Initialization
    init() {
        loadPersistedData()
        setupDefaultDataIfNeeded()
    }
    
    // MARK: - Load Persisted Data
    private func loadPersistedData() {
        userLevel = persistence.loadUserLevel()
        habitCards = persistence.loadHabitCards()
        achievements = persistence.loadAchievements()
        
        // Calculate today's completed habits
        todayHabitsCompleted = habitCards.filter(\.isCompletedToday).count
        
        // Load health cards from persistence or create new
        let savedHealthCards = persistence.loadHealthCards()
        if !savedHealthCards.isEmpty {
            healthCards = savedHealthCards
            totalCardsCollected = healthCards.filter(\.isCollected).count
        }
    }
    
    private func setupDefaultDataIfNeeded() {
        if habitCards.isEmpty {
            habitCards = persistence.loadHabitCards() // This creates defaults
        }
        if achievements.isEmpty {
            achievements = persistence.loadAchievements()
        }
    }
    
    // MARK: - HealthKit Authorization
    func requestHealthKitAuthorization() async {
        do {
            try await healthKit.requestAuthorization()
            isHealthKitAuthorized = true
            await refreshHealthCardsFromHealthKit()
        } catch {
            print("HealthKit authorization failed: \(error)")
            isHealthKitAuthorized = false
            // Create mock health cards if not authorized
            setupMockHealthCards()
        }
    }
    
    // MARK: - Refresh Health Data from HealthKit
    func refreshHealthCardsFromHealthKit() async {
        await healthKit.fetchAllData()
        
        // Map HealthKit data to HealthCards
        healthCards = HealthDataType.allCases.map { type in
            healthKit.createHealthCard(type: type)
        }
        
        // Save to persistence
        persistence.saveHealthCards(healthCards)
        totalCardsCollected = healthCards.count
        
        // Update achievements based on health data
        if healthKit.todaySteps >= 10000 {
            unlockAchievement(id: "health_hero")
        }
    }
    
    private func setupMockHealthCards() {
        healthCards = [
            HealthCard(id: "steps", name: "Steps", description: "Track your daily steps", type: .health, rarity: .epic, icon: "figure.walk", color: "4ECDC4", currentValue: 5420, maxValue: 10000, unit: "steps", isCollected: true, isShiny: false, level: 1),
            HealthCard(id: "heartRate", name: "Heart Rate", description: "Monitor your heart rate", type: .health, rarity: .rare, icon: "heart.fill", color: "FF6B6B", currentValue: 72, maxValue: 200, unit: "BPM", isCollected: true, isShiny: false, level: 1),
            HealthCard(id: "sleep", name: "Sleep", description: "Track your sleep hours", type: .health, rarity: .uncommon, icon: "moon.fill", color: "9B59B6", currentValue: 7.5, maxValue: 9, unit: "hours", isCollected: true, isShiny: false, level: 1),
            HealthCard(id: "water", name: "Hydration", description: "Stay hydrated", type: .health, rarity: .common, icon: "drop.fill", color: "3498DB", currentValue: 4, maxValue: 8, unit: "glasses", isCollected: true, isShiny: false, level: 1),
            HealthCard(id: "meditation", name: "Meditation", description: "Mindful minutes", type: .health, rarity: .uncommon, icon: "brain.head.profile", color: "6B4EFF", currentValue: 10, maxValue: 30, unit: "min", isCollected: true, isShiny: false, level: 1),
        ]
        totalCardsCollected = healthCards.count
    }
    
    // MARK: - Habit Operations
    func completeHabit(_ habitId: String) {
        guard let index = habitCards.firstIndex(where: { $0.id == habitId }) else { return }
        var habit = habitCards[index]
        
        if !habit.isCompletedToday {
            habit.isCompletedToday = true
            habit.currentStreak += 1
            habit.lastCompleted = Date()
            if habit.currentStreak > habit.longestStreak {
                habit.longestStreak = habit.currentStreak
            }
            habitCards[index] = habit
            todayHabitsCompleted += 1
            
            // Award XP
            let earnedXP = xpPerHabit + (habit.currentStreak > 7 ? xpPerStreak : 0)
            userLevel.addXP(earnedXP)
            currentXPAnimation = earnedXP
            triggerXPAnimation()
            
            // Update persistence
            persistence.saveHabitCards(habitCards)
            persistence.saveUserLevel(userLevel)
            
            // Check achievements
            checkAllAchievements()
            
            // Check if all habits completed today
            if todayHabitsCompleted >= habitCards.count {
                unlockAchievement(id: "perfect_day")
            }
        }
    }
    
    // MARK: - Card Pull (Daily Gacha)
    func pullDailyCard() -> HealthCard? {
        guard persistence.canPullToday() else {
            return nil // Already pulled today
        }
        
        // Determine rarity based on random chance
        let rarity = RarityRoll.roll()
        
        // Get a random health card of that rarity (or default to steps)
        let cardType = HealthDataType.allCases.randomElement() ?? .steps
        let newCard = HealthCard(
            id: cardType.id,
            name: cardType.name,
            description: "Track your \(cardType.name.lowercased())",
            type: .health,
            rarity: rarity,
            icon: cardType.icon,
            color: cardType.color,
            currentValue: 0,
            maxValue: cardType == .steps ? 10000 : (cardType == .heartRate ? 200 : (cardType == .sleep ? 9 : 100)),
            unit: cardType == .steps ? "steps" : (cardType == .heartRate ? "BPM" : (cardType == .sleep ? "hours" : "count")),
            isCollected: true,
            isShiny: RarityRoll.isShiny(rarity: rarity),
            level: 1
        )
        
        // Update state
        lastPulledCard = newCard
        showCardAnimation = true
        
        // Add to collection
        if let index = healthCards.firstIndex(where: { $0.id == newCard.id }) {
            var existingCard = healthCards[index]
            // Upgrade existing card
            existingCard.level += 1
            existingCard.isShiny = existingCard.isShiny || newCard.isShiny
            existingCard.currentValue = max(existingCard.currentValue, newCard.currentValue)
            healthCards[index] = existingCard
        } else {
            healthCards.append(newCard)
        }
        
        // Award XP for pulling
        userLevel.addXP(xpPerCard + (rarity.stars * 10))
        totalCardsCollected = healthCards.count
        
        // Update persistence
        persistence.saveHealthCards(healthCards)
        persistence.saveUserLevel(userLevel)
        persistence.saveLastPullDate(Date())
        
        // Update achievements
        updateAchievementProgress(id: "card_collector")
        if newCard.isShiny {
            unlockAchievement(id: "shiny_hunter")
        }
        
        return newCard
    }
    
    func dismissCardAnimation() {
        showCardAnimation = false
        lastPulledCard = nil
    }
    
    // MARK: - AI Coach
    func sendMessageToCoach(_ message: String) async -> String {
        do {
            // Use MiniMax API
            let response = try await miniMax.sendMessage(message)
            return response
        } catch {
            // Return mock response if API fails
            return generateMockResponse(to: message)
        }
    }
    
    func generateHealthAdvice() async -> String {
        do {
            return try await miniMax.generateHealthAdvice(
                steps: healthKit.todaySteps,
                heartRate: healthKit.todayHeartRate,
                sleep: healthKit.todaySleepHours,
                water: healthKit.todayWaterGlasses
            )
        } catch {
            return generateMockHealthAdvice()
        }
    }
    
    // MARK: - XP Animation
    private func triggerXPAnimation() {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.currentXPAnimation = 0
            }
        }
    }
    
    // MARK: - Achievement Operations
    private func checkAllAchievements() {
        // First Steps - complete first habit
        if todayHabitsCompleted >= 1 {
            unlockAchievement(id: "first_steps")
        }
        
        // Week Warrior - 7 day streak
        if habitCards.contains(where: { $0.currentStreak >= 7 }) {
            unlockAchievement(id: "week_warrior")
        }
        
        // Habit Master - complete 10 habits total
        let totalCompleted = habitCards.reduce(0) { $0 + $1.currentStreak }
        if totalCompleted >= 10 {
            unlockAchievement(id: "habit_master")
        }
        
        // Perfect Day
        if todayHabitsCompleted >= habitCards.count && habitCards.count > 0 {
            unlockAchievement(id: "perfect_day")
        }
    }
    
    private func updateAchievementProgress(id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        var achievement = achievements[index]
        achievement.progress = min(achievement.progress + 1, achievement.progressTarget)
        achievements[index] = achievement
        
        if achievement.progress >= achievement.progressTarget {
            achievement.isUnlocked = true
        }
        persistence.saveAchievements(achievements)
    }
    
    private func unlockAchievement(id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        var achievement = achievements[index]
        if !achievement.isUnlocked {
            achievement.isUnlocked = true
            achievement.progress = achievement.progressTarget
            achievements[index] = achievement
            userLevel.addXP(achievement.xpReward)
            persistence.saveAchievements(achievements)
            persistence.saveUserLevel(userLevel)
        }
    }
    
    // MARK: - Save Data
    func saveData() {
        persistence.saveUserLevel(userLevel)
        persistence.saveHabitCards(habitCards)
        persistence.saveHealthCards(healthCards)
        persistence.saveAchievements(achievements)
    }
    
    // MARK: - Reset Day (Call at midnight)
    func resetDailyHabits() {
        for index in habitCards.indices {
            habitCards[index].isCompletedToday = false
        }
        todayHabitsCompleted = 0
        persistence.saveHabitCards(habitCards)
    }
    
    // MARK: - Mock Response Generator
    private func generateMockResponse(to message: String) -> String {
        let lowercased = message.lowercased()
        
        if lowercased.contains("steps") || lowercased.contains("walk") {
            return "Great question about steps! 💪 Walking 10,000 steps a day is a fantastic goal. Even a 15-minute walk after meals can make a big difference. Keep moving!"
        } else if lowercased.contains("sleep") || lowercased.contains("rest") {
            return "Sleep is so important! 😴 Try to get 7-9 hours and keep a consistent schedule. Avoid screens 1 hour before bed."
        } else if lowercased.contains("water") || lowercased.contains("drink") {
            return "Hydration key! 💧 Aim for 8 glasses a day. Start your morning with a big glass of water to kickstart your metabolism."
        } else if lowercased.contains("meditat") || lowercased.contains("mindful") {
            return "Meditation is powerful! 🧘 Even 5 minutes a day can reduce stress. Try focusing on your breath when your mind wanders."
        } else {
            return "That's a great point! Remember, consistency beats perfection. Small daily actions lead to big results over time. 🌟"
        }
    }
    
    private func generateMockHealthAdvice() -> String {
        var tips: [String] = []
        
        if healthKit.todaySteps < 5000 {
            tips.append("You're below 5,000 steps today. Try a short walk!")
        }
        if healthKit.todayWaterGlasses < 4 {
            tips.append("Remember to drink more water!")
        }
        if healthKit.todaySleepHours < 7 {
            tips.append("You might need more sleep tonight.")
        }
        
        if tips.isEmpty {
            return "You're doing great today! Keep up the excellent work. 🌟"
        }
        return tips.joined(separator: " ")
    }
}

// MARK: - Rarity Roll
enum RarityRoll {
    static func roll() -> CardRarity {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1...5: return .legendary    // 5%
        case 6...15: return .epic        // 10%
        case 16...30: return .rare       // 15%
        case 31...55: return .uncommon   // 25%
        default: return .common          // 45%
        }
    }
    
    static func isShiny(rarity: CardRarity) -> Bool {
        let chance: Int
        switch rarity {
        case .legendary: chance = 20   // 20%
        case .epic: chance = 10        // 10%
        case .rare: chance = 5          // 5%
        case .uncommon: chance = 2     // 2%
        case .common: chance = 1       // 1%
        }
        return Int.random(in: 1...100) <= chance
    }
}