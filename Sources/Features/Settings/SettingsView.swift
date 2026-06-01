import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var aiService = AIService.shared

    var body: some View {
        NavigationStack {
            List {
                // Section 1: System Pre-configured AI (read-only)
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .frame(width: 30)
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("MiniMax-CN")
                                .foregroundColor(.primary)
                            Text("Pre-configured")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Text("Ready")
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                } header: {
                    Text("System Pre-configured")
                } footer: {
                    Text("Default AI service, cannot be modified")
                }

                // Section 2: Custom AI Providers
                Section {
                    ForEach(customProviders, id: \.self) { provider in
                        NavigationLink {
                            CustomProviderConfigView(provider: provider)
                        } label: {
                            HStack {
                                Image(systemName: provider.iconName)
                                    .frame(width: 30)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(provider.displayName)
                                        .foregroundColor(.primary)
                                    Text("Tap to configure")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if isProviderActive(provider) {
                                    Text("Active")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Custom AI Providers")
                } footer: {
                    Text("10 AI providers available. Tap to configure with your own API Key")
                }

                // App Info Section
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("3.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About VitaMindGo", systemImage: "info.circle")
                    }
                } header: {
                    Text("App Info")
                }
            }
            .navigationTitle("Settings")
        }
    }

    // Custom providers: minimaxGlobal + other 9 (excluding minimaxCn)
    private var customProviders: [AIProviderType] {
        AIProviderType.allCases.filter { $0 != .minimaxCn }
    }

    private func isProviderActive(_ provider: AIProviderType) -> Bool {
        return AIService.shared.currentProvider == provider
    }
}

// MARK: - Custom Provider Configuration

struct CustomProviderConfigView: View {
    let provider: AIProviderType
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var baseURL: String = ""
    @State private var selectedModel: String = ""
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var isActive = false

    var body: some View {
        Form {
            // Provider Header
            Section {
                HStack {
                    Text("Provider")
                    Spacer()
                    Text(provider.displayName)
                        .foregroundColor(.secondary)
                }

                if isActive {
                    HStack {
                        Text("Status")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text(provider.displayName)
            }

            // Configuration
            Section {
                TextField("Base URL", text: $baseURL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .textContentType(.URL)

                SecureField("API Key", text: $apiKey)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                Picker("Model", selection: $selectedModel) {
                    ForEach(provider.supportedModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            } header: {
                Text("Configuration")
            } footer: {
                Text("Enter your \(provider.displayName) API credentials")
            }

            // Test Result
            if let result = testResult {
                Section {
                    HStack {
                        Text("Result")
                        Spacer()
                        if result == "Success" {
                            Text("Connection successful")
                                .foregroundColor(.green)
                        } else {
                            Text(result)
                                .foregroundColor(.red)
                                .lineLimit(2)
                        }
                    }
                }
            }

            // Actions
            Section {
                if isTesting {
                    HStack {
                        Text("Testing...")
                        Spacer()
                        ProgressView()
                    }
                } else {
                    Button("Test & Save") {
                        testAndSave()
                    }
                    .disabled(baseURL.isEmpty || apiKey.isEmpty)
                }
            }
        }
        .navigationTitle(provider.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedModel = provider.defaultModel
            baseURL = provider.baseURL
            isActive = AIService.shared.currentProvider == provider
        }
    }

    private func testAndSave() {
        guard !baseURL.isEmpty, !apiKey.isEmpty else { return }
        isTesting = true
        testResult = nil

        Task {
            do {
                let previousProvider = AIService.shared.currentProvider
                let previousModel = AIService.shared.selectedModel
                let previousKey = AIService.shared.apiKey

                AIService.shared.configureCustomProvider(provider, baseURL: baseURL, apiKey: apiKey, model: selectedModel)
                let _ = try await AIService.shared.sendMessage("Hi", history: [])

                await MainActor.run {
                    testResult = "Success"
                    isTesting = false
                    isActive = true
                }
            } catch {
                await MainActor.run {
                    testResult = error.localizedDescription
                    isTesting = false
                    isActive = false
                }
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text("VitaMindGo")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Version 3.0.0")
                        .foregroundColor(.secondary)

                    Text("Your AI Health Companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }

            Section {
                Link(destination: URL(string: "https://lauer3912.github.io/ios-VitaMind/docs/PrivacyPolicy.html")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }

                Link(destination: URL(string: "https://lauer3912.github.io/ios-VitaMind/docs/TermsOfService.html")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            } header: {
                Text("Legal")
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameState())
}