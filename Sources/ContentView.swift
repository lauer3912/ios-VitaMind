import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HealthDashboardView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                .tag(0)
                .accessibilityIdentifier("tab_health")

            HabitTrackingView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
                .tag(1)
                .accessibilityIdentifier("tab_habits")

            AIAssistantView()
                .tabItem {
                    Label("AI", systemImage: "brain.head.profile")
                }
                .tag(2)
                .accessibilityIdentifier("tab_ai")

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
                .accessibilityIdentifier("tab_settings")
        }
        .accessibilityIdentifier("main_tab_view")
    }
}

// MARK: - Health Dashboard View

struct HealthDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("VitaMind")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("health_title")

                    HStack(spacing: 20) {
                        HealthMetricCard(
                            title: "Heart Rate",
                            value: "72",
                            unit: "BPM",
                            icon: "heart.fill",
                            color: .red
                        )
                        .accessibilityIdentifier("metric_heart_rate")

                        HealthMetricCard(
                            title: "Steps",
                            value: "8,542",
                            unit: "steps",
                            icon: "figure.walk",
                            color: .green
                        )
                        .accessibilityIdentifier("metric_steps")
                    }

                    HStack(spacing: 20) {
                        HealthMetricCard(
                            title: "Sleep",
                            value: "7.5",
                            unit: "hours",
                            icon: "moon.fill",
                            color: .indigo
                        )
                        .accessibilityIdentifier("metric_sleep")

                        HealthMetricCard(
                            title: "Active",
                            value: "45",
                            unit: "min",
                            icon: "flame.fill",
                            color: .orange
                        )
                        .accessibilityIdentifier("metric_active")
                    }
                }
                .padding()
            }
            .navigationTitle("Health")
        }
        .accessibilityIdentifier("health_dashboard_view")
    }
}

struct HealthMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Habit Tracking View

struct HabitTrackingView: View {
    @State private var habits: [HabitItem] = [
        HabitItem(name: "Drink Water", icon: "drop.fill", count: 5, target: 8),
        HabitItem(name: "Meditation", icon: "brain.head.profile", count: 1, target: 1),
        HabitItem(name: "Exercise", icon: "figure.run", count: 1, target: 1),
        HabitItem(name: "Sleep Early", icon: "moon.stars.fill", count: 0, target: 1)
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                    HStack {
                        Image(systemName: habit.icon)
                            .foregroundColor(.blue)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text(habit.name)
                                .fontWeight(.medium)
                            Text("\(habit.count)/\(habit.target)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(action: { incrementHabit(at: index) }) {
                            Image(systemName: habit.count >= habit.target ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.count >= habit.target ? .green : .gray)
                        }
                        .accessibilityIdentifier("habit_check_\(index)")
                    }
                    .accessibilityIdentifier("habit_row_\(index)")
                }
            }
            .navigationTitle("Habits")
        }
        .accessibilityIdentifier("habit_tracking_view")
    }

    private func incrementHabit(at index: Int) {
        if habits[index].count < habits[index].target {
            habits[index].count += 1
        }
    }
}

struct HabitItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var count: Int
    let target: Int
}

// MARK: - AI Assistant View

struct AIAssistantView: View {
    @State private var userMessage = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your VitaMind AI assistant. How can I help you today?", isUser: false)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            ChatBubble(message: message)
                                .accessibilityIdentifier("chat_message_\(index)")
                        }
                    }
                    .padding()
                }
                .accessibilityIdentifier("chat_scroll_view")

                HStack {
                    TextField("Ask me anything...", text: $userMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("chat_input_field")

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityIdentifier("chat_send_button")
                }
                .padding()
            }
            .navigationTitle("AI Assistant")
        }
        .accessibilityIdentifier("ai_assistant_view")
    }

    private func sendMessage() {
        guard !userMessage.isEmpty else { return }
        messages.append(ChatMessage(text: userMessage, isUser: true))
        let query = userMessage
        userMessage = ""
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(ChatMessage(text: "Thanks for your question about '\(query)'. I'm here to help you track your health and build better habits!", isUser: false))
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Health") {
                    SettingsRow(icon: "heart.fill", title: "HealthKit", color: .red)
                        .accessibilityIdentifier("settings_healthkit")
                    SettingsRow(icon: "applewatch", title: "Apple Watch", color: .blue)
                        .accessibilityIdentifier("settings_watch")
                }

                Section("Notifications") {
                    SettingsRow(icon: "bell.fill", title: "Reminders", color: .orange)
                        .accessibilityIdentifier("settings_reminders")
                    SettingsRow(icon: "drop.fill", title: "Hydration", color: .blue)
                        .accessibilityIdentifier("settings_hydration")
                }

                Section("Privacy") {
                    SettingsRow(icon: "lock.fill", title: "Privacy Policy", color: .green)
                        .accessibilityIdentifier("settings_privacy")
                    SettingsRow(icon: "doc.fill", title: "Terms of Service", color: .gray)
                        .accessibilityIdentifier("settings_terms")
                }

                Section("About") {
                    SettingsRow(icon: "info.circle.fill", title: "Version 3.0.0", color: .gray)
                        .accessibilityIdentifier("settings_version")
                }
            }
            .navigationTitle("Settings")
        }
        .accessibilityIdentifier("settings_view")
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}