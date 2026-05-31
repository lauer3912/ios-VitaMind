import Foundation
import HealthKit

final class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var todaySteps: Double = 0
    @Published var todayHeartRate: Double = 0
    @Published var todaySleepHours: Double = 0
    @Published var todayWaterGlasses: Double = 0
    @Published var todayMeditationMinutes: Double = 0
    @Published var activeCalories: Double = 0
    @Published var distance: Double = 0
    
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
        HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
        HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
        HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
    ]
    
    private init() {}
    
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        
        await MainActor.run {
            self.isAuthorized = true
        }
        
        await fetchAllData()
    }
    
    @MainActor
    func fetchAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchSteps() }
            group.addTask { await self.fetchHeartRate() }
            group.addTask { await self.fetchSleep() }
            group.addTask { await self.fetchWater() }
            group.addTask { await self.fetchMeditation() }
            group.addTask { await self.fetchActiveCalories() }
            group.addTask { await self.fetchDistance() }
        }
    }
    
    // MARK: - Steps
    
    func fetchSteps() async {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let (start, end) = dayDateRange()
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: createPredicate(start: start, end: end), options: .cumulativeSum) { _, stats, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        let value = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                        cont.resume(returning: value)
                    }
                }
                healthStore.execute(query)
            }
            
            await MainActor.run {
                self.todaySteps = result
            }
        } catch {
            print("Steps fetch error: \(error)")
        }
    }
    
    // MARK: - Heart Rate
    
    func fetchHeartRate() async {
        guard let heartType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let (start, end) = dayDateRange()
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: heartType, quantitySamplePredicate: createPredicate(start: start, end: end), options: .discreteAverage) { _, stats, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        let value = stats?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                        cont.resume(returning: value)
                    }
                }
                healthStore.execute(query)
            }
            
            await MainActor.run {
                self.todayHeartRate = result
            }
        } catch {
            print("HeartRate fetch error: \(error)")
        }
    }
    
    // MARK: - Sleep
    
    func fetchSleep() async {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let end = Date()
        let start = calendar.date(byAdding: .hour, value: -12, to: end)!
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let predicate = createPredicate(start: start, end: end)
                let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [.init(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        var totalSleep: Double = 0
                        let asleepStates: [HKCategoryValueSleepAnalysis] = [.asleepCore, .asleepDeep, .asleepREM, .asleepUnspecified]
                        for sample in samples as? [HKCategorySample] ?? [] {
                            if asleepStates.contains(where: { $0 == HKCategoryValueSleepAnalysis(rawValue: sample.value) }) {
                                totalSleep += sample.endDate.timeIntervalSince(sample.startDate) / 3600
                            }
                        }
                        cont.resume(returning: totalSleep)
                    }
                }
                self.healthStore.execute(query)
            }
            
            await MainActor.run {
                self.todaySleepHours = result
            }
        } catch {
            print("Sleep fetch error: \(error)")
        }
    }
    
    // MARK: - Water
    
    func fetchWater() async {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        let (start, end) = dayDateRange()
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: createPredicate(start: start, end: end), options: .cumulativeSum) { _, stats, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        // Convert mL to glasses (1 glass = 250mL)
                        let valueInML = stats?.sumQuantity()?.doubleValue(for: HKUnit.literUnit(with: .milli)) ?? 0
                        let value = valueInML / 250.0
                        cont.resume(returning: value)
                    }
                }
                self.healthStore.execute(query)
            }
            
            await MainActor.run {
                self.todayWaterGlasses = result
            }
        } catch {
            print("Water fetch error: \(error)")
        }
    }
    
    // MARK: - Meditation
    
    func fetchMeditation() async {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else { return }
        
        let (start, end) = dayDateRange()
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let predicate = createPredicate(start: start, end: end)
                let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [.init(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        var totalMinutes: Double = 0
                        for sample in samples as? [HKCategorySample] ?? [] {
                            // Mindful session sample value 0 = inProgress, 1 = end
                            if sample.value == 1 {
                                totalMinutes += sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                            }
                        }
                        cont.resume(returning: totalMinutes)
                    }
                }
                self.healthStore.execute(query)
            }
            
            await MainActor.run {
                self.todayMeditationMinutes = result
            }
        } catch {
            print("Meditation fetch error: \(error)")
        }
    }
    
    // MARK: - Active Calories
    
    func fetchActiveCalories() async {
        guard let calType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let (start, end) = dayDateRange()
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: calType, quantitySamplePredicate: createPredicate(start: start, end: end), options: .cumulativeSum) { _, stats, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        let value = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                        cont.resume(returning: value)
                    }
                }
                self.healthStore.execute(query)
            }
            
            await MainActor.run {
                self.activeCalories = result
            }
        } catch {
            print("Calories fetch error: \(error)")
        }
    }
    
    // MARK: - Distance
    
    func fetchDistance() async {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let (start, end) = dayDateRange()
        
        do {
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: createPredicate(start: start, end: end), options: .cumulativeSum) { _, stats, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        let value = stats?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                        cont.resume(returning: value)
                    }
                }
                self.healthStore.execute(query)
            }
            
            await MainActor.run {
                self.distance = result
            }
        } catch {
            print("Distance fetch error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func dayDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.startOfDay(for: now)
        let end = now
        return (start, end)
    }
    
    private func createPredicate(start: Date, end: Date) -> NSPredicate {
        HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
    }
}

enum HealthKitError: Error {
    case notAvailable
    case unauthorized
    case dataNotAvailable
}

extension HealthKitService {
    func createHealthCard(type: HealthDataType) -> HealthCard {
        let value: Double
        let maxValue: Double
        let unit: String
        
        switch type {
        case .steps:
            value = todaySteps
            maxValue = 10000
            unit = "steps"
        case .heartRate:
            value = todayHeartRate
            maxValue = 120
            unit = "BPM"
        case .sleep:
            value = todaySleepHours
            maxValue = 9
            unit = "hours"
        case .water:
            value = todayWaterGlasses
            maxValue = 8
            unit = "glasses"
        case .meditation:
            value = todayMeditationMinutes
            maxValue = 30
            unit = "min"
        case .calories:
            value = activeCalories
            maxValue = 500
            unit = "kcal"
        case .distance:
            value = distance / 1000
            maxValue = 10
            unit = "km"
        }
        
        return HealthCard(
            id: type.id,
            name: type.name,
            description: "Track your \(type.name.lowercased())",
            type: .health,
            rarity: type.rarity,
            icon: type.icon,
            color: type.color,
            currentValue: value,
            maxValue: maxValue,
            unit: unit,
            isCollected: true,
            isShiny: false,
            level: 1
        )
    }
}

enum HealthDataType: String, CaseIterable, Identifiable {
    case steps, heartRate, sleep, water, meditation, calories, distance
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .steps: return "Steps"
        case .heartRate: return "Heart Rate"
        case .sleep: return "Sleep"
        case .water: return "Hydration"
        case .meditation: return "Meditation"
        case .calories: return "Calories"
        case .distance: return "Distance"
        }
    }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .heartRate: return "heart.fill"
        case .sleep: return "moon.fill"
        case .water: return "drop.fill"
        case .meditation: return "brain.head.profile"
        case .calories: return "flame.fill"
        case .distance: return "map.fill"
        }
    }
    
    var color: String {
        switch self {
        case .steps: return "4ECDC4"
        case .heartRate: return "FF6B6B"
        case .sleep: return "9B59B6"
        case .water: return "3498DB"
        case .meditation: return "6B4EFF"
        case .calories: return "E74C3C"
        case .distance: return "2ECC71"
        }
    }
    
    var rarity: CardRarity {
        switch self {
        case .steps: return .rare
        case .heartRate: return .rare
        case .sleep: return .uncommon
        case .water: return .common
        case .meditation: return .uncommon
        case .calories: return .epic
        case .distance: return .epic
        }
    }
}