import Foundation
import SwiftUI

// MARK: - Rarity
enum CardRarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var stars: Int {
        switch self {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 5
        }
    }
    
    var color: Color {
        switch self {
        case .common: return VitaTheme.Colors.cardCommon
        case .uncommon: return VitaTheme.Colors.cardUncommon
        case .rare: return VitaTheme.Colors.cardRare
        case .epic: return VitaTheme.Colors.cardEpic
        case .legendary: return VitaTheme.Colors.cardLegendary
        }
    }
    
    var glowColor: Color {
        color.opacity(0.4)
    }
}

// MARK: - Card Type
enum CardType: String, Codable, CaseIterable {
    case health = "Health"
    case habit = "Habit"
    case achievement = "Achievement"
    case coach = "Coach"
    case milestone = "Milestone"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .habit: return "checkmark.seal.fill"
        case .achievement: return "trophy.fill"
        case .coach: return "brain.head.profile"
        case .milestone: return "star.circle.fill"
        }
    }
}

// MARK: - HealthCard
struct HealthCard: Identifiable, Codable, Equatable {
    var id: String
    let name: String
    let description: String
    let type: CardType
    let rarity: CardRarity
    let icon: String
    let color: String
    var currentValue: Double
    var maxValue: Double
    var unit: String
    var isCollected: Bool
    var isShiny: Bool
    var level: Int
    
    var progress: Double {
        guard maxValue > 0 else { return 0 }
        return min(currentValue / maxValue, 1.0)
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        type: CardType,
        rarity: CardRarity,
        icon: String,
        color: String,
        currentValue: Double = 0,
        maxValue: Double = 100,
        unit: String = "",
        isCollected: Bool = false,
        isShiny: Bool = false,
        level: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.rarity = rarity
        self.icon = icon
        self.color = color
        self.currentValue = currentValue
        self.maxValue = maxValue
        self.unit = unit
        self.isCollected = isCollected
        self.isShiny = isShiny
        self.level = level
    }
    
    static func heartRate(value: Double) -> HealthCard {
        HealthCard(
            name: "Heart Rate",
            description: "Keep your heart strong!",
            type: .health,
            rarity: .rare,
            icon: "heart.fill",
            color: "FF6B6B",
            currentValue: value,
            maxValue: 200,
            unit: "BPM"
        )
    }
    
    static func steps(value: Double) -> HealthCard {
        HealthCard(
            name: "Steps",
            description: "10,000 steps a day!",
            type: .health,
            rarity: .epic,
            icon: "figure.walk",
            color: "4ECDC4",
            currentValue: value,
            maxValue: 10000,
            unit: "steps"
        )
    }
    
    static func sleep(value: Double) -> HealthCard {
        HealthCard(
            name: "Sleep",
            description: "Rest well, live well.",
            type: .health,
            rarity: .rare,
            icon: "moon.fill",
            color: "9B59B6",
            currentValue: value,
            maxValue: 9,
            unit: "hours"
        )
    }
    
    static func water(count: Int) -> HealthCard {
        HealthCard(
            name: "Hydration",
            description: "Stay hydrated!",
            type: .habit,
            rarity: .common,
            icon: "drop.fill",
            color: "3498DB",
            currentValue: Double(count),
            maxValue: 8,
            unit: "glasses"
        )
    }
    
    static func meditation(done: Bool) -> HealthCard {
        HealthCard(
            name: "Meditation",
            description: "Clear your mind.",
            type: .habit,
            rarity: .uncommon,
            icon: "brain.head.profile",
            color: "9B59B6",
            currentValue: done ? 1 : 0,
            maxValue: 1,
            unit: "session"
        )
    }
}

// MARK: - HabitCard
struct HabitCard: Identifiable, Codable, Equatable {
    var id: String
    let name: String
    let description: String
    let icon: String
    let color: String
    var targetCount: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCompleted: Date?
    var isCompletedToday: Bool
    let rarity: CardRarity
    var xpReward: Int
    
    var streakIcon: String {
        if longestStreak >= 30 { return "flame.circle.fill" }
        if longestStreak >= 7 { return "flame.fill" }
        if longestStreak >= 3 { return "sparkles" }
        return "circle"
    }
    
    var evolutionStage: Int {
        if longestStreak >= 30 { return 3 }
        if longestStreak >= 7 { return 2 }
        if longestStreak >= 1 { return 1 }
        return 0
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        icon: String,
        color: String,
        targetCount: Int = 1,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompleted: Date? = nil,
        isCompletedToday: Bool = false,
        xpReward: Int = 20,
        rarity: CardRarity = .common
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.targetCount = targetCount
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCompleted = lastCompleted
        self.isCompletedToday = isCompletedToday
        self.xpReward = xpReward
        self.rarity = rarity
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    var id: String
    let name: String
    let description: String
    let icon: String
    var progress: Int
    var progressTarget: Int
    var isUnlocked: Bool
    let rarity: CardRarity
    var xpReward: Int
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        icon: String,
        requirement: Int,
        progress: Int = 0,
        isUnlocked: Bool = false,
        rarity: CardRarity,
        xpReward: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.progress = progress
        self.progressTarget = requirement
        self.isUnlocked = isUnlocked
        self.rarity = rarity
        self.xpReward = xpReward
    }
    
    var progressPercent: Double {
        guard progressTarget > 0 else { return 0 }
        return min(Double(progress) / Double(progressTarget), 1.0)
    }
}

// MARK: - User Level
struct UserLevel: Codable {
    var level: Int
    var currentXP: Int
    var totalXP: Int
    
    var xpForNextLevel: Int {
        level * 100 + 50
    }
    
    var progress: Double {
        let needed = xpForNextLevel
        guard needed > 0 else { return 0 }
        return min(Double(currentXP) / Double(needed), 1.0)
    }
    
    var title: String {
        switch level {
        case 1...5: return "Novice"
        case 6...10: return "Apprentice"
        case 11...20: return "Adventurer"
        case 21...50: return "Champion"
        case 51...100: return "Master"
        default: return "Legend"
        }
    }
    
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        currentXP += amount
        while currentXP >= xpForNextLevel {
            currentXP -= xpForNextLevel
            level += 1
        }
    }
    
    init(level: Int = 1, currentXP: Int = 0, totalXP: Int = 0) {
        self.level = level
        self.currentXP = currentXP
        self.totalXP = totalXP
    }
}