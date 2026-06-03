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
    private let notifications = NotificationManager.shared
    
    // MARK: - XP Config
    private let xpPerHabit = 25
    private let xpPerCard = 50
    private let xpPerStreak = 10
    
    // MARK: - Initialization
    init() {
        // For UI tests, force a clean pull state so each test starts with
        // a pullable slot (canPullToday = true) regardless of the device's
        // persisted UserDefaults.
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            UserDefaults.standard.removeObject(forKey: "vita_last_pull_date")
            UserDefaults.standard.removeObject(forKey: "vita_pull_streak")
        }
        loadPersistedData()
        setupDefaultDataIfNeeded()
        // No mock seeding. If `healthCards` is empty (no HealthKit auth,
        // no real data), HomeView shows its built-in "No health data yet"
        // empty state which guides the user to connect Health.
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
        
        // Load and sync Widget data
        if let widgetData = persistence.loadWidgetData() {
            // Widget data is available, it will be updated when HealthKit data is fetched
            print("Widget data loaded: steps=\(widgetData.steps), heartRate=\(widgetData.heartRate)")
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
            // Don't seed mock data on auth failure. The HomeView will
            // show its empty-state card, prompting the user to retry
            // from Settings → HealthKit.
        }
    }

    // MARK: - Notification Bootstrap
    /// Request notification permission + re-schedule the three daily reminders
    /// based on the current habit count. Safe to call multiple times.
    func bootstrapNotifications() async {
        await notifications.requestAuthorization()
        await notifications.rescheduleAll(habitCount: habitCards.count)
    }

    /// Called by the Settings toggle. Re-applies the schedule immediately
    /// so the change is visible in pending notifications right away.
    func applyNotificationPreferenceChange() async {
        if notifications.isEnabled {
            await notifications.rescheduleAll(habitCount: habitCards.count)
        } else {
            notifications.cancelAll()
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
        
        // Update Widget data for App Group sharing
        persistence.saveWidgetData(
            steps: Int(healthKit.todaySteps),
            heartRate: Int(healthKit.todayHeartRate),
            sleepHours: healthKit.todaySleepHours,
            waterGlasses: Int(healthKit.todayWaterGlasses)
        )
        
        // Update achievements based on health data
        if healthKit.todaySteps >= 10000 {
            unlockAchievement(id: "health_hero")
        }
    }
    
    // MARK: - Mock Health Cards (REMOVED)
    //
    // Previously this method seeded 5 fake health cards (5420 steps,
    // 72 BPM, 7.5h sleep, etc.) on first launch or when HealthKit
    // authorization was denied. That made the Home tab look populated
    // for App Store review but showed fabricated data to real users.
    //
    // Removed for App Store submission (commit 3xxx). The HomeView
    // already has a "No health data yet" empty state with a dashed
    // border and a pointer to Settings → HealthKit, which is what
    // new users will see until they connect Health.
    //
    
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
    enum PullResult {
        case pulled(HealthCard)
        case alreadyPulledToday
    }

    func pullDailyCard() -> PullResult {
        guard persistence.canPullToday() else {
            return .alreadyPulledToday
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
        
        return .pulled(newCard)
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
            // No mock fallback — be honest with the user that the
            // AI service is unavailable instead of fabricating a reply.
            // Otherwise the Coach tab would pretend to be a real AI
            // while actually serving hard-coded strings.
            return "AI service is temporarily unavailable. Please try again in a moment."
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
            // Same honest-failure principle as sendMessageToCoach().
            return "Unable to generate personalised advice right now. Please try again later."
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
    
    // MARK: - Mock Response Generator (REMOVED)
    //
    // Previously this section held two hard-coded response generators
    // (generateMockResponse + generateMockHealthAdvice) that produced
    // a fake "AI" reply when the MiniMax API call failed. The Coach
    // tab would then appear to be working while actually showing
    // canned strings, which would mislead users and risk App Store
    // review feedback.
    //
    // Removed for App Store submission. The catch blocks in
    // sendMessageToCoach / generateHealthAdvice now return honest
    // "AI service is temporarily unavailable" messages instead.
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