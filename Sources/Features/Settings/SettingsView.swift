import SwiftUI

struct AppIconView: View {
    var body: some View {
        if let uiImage = AppIconLoader.shared.iconImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(VitaTheme.Colors.textPrimary)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var aiService = AIService.shared

    @State private var switchError: String? = nil

    // Persisted appearance mode (mirrors VitaPocketApp's @AppStorage so the
    // Settings row reflects and updates the app-wide value).
    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Ready")
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                            if isSystemPreConfigured {
                                Text("Active")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Button("Use Default") {
                                    AIService.shared.resetToDefaultProvider()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(Color(.systemBackground))
                } header: {
                    Text("System Pre-configured")
                } footer: {
                    Text("Built-in AI service, ready to use")
                }

                Section {
                    HStack {
                        Text("Active: ")
                            .foregroundColor(.secondary)
                        Text(AIService.shared.currentProvider == .minimaxCn ? "System Pre-configured" : AIService.shared.currentProvider.displayName)
                            .foregroundColor(AIService.shared.currentProvider == .minimaxCn ? .green : .blue)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)

                    ForEach(customProviders, id: \.self) { provider in
                        if isProviderActive(provider) {
                            HStack {
                                Image(systemName: provider.iconName)
                                    .frame(width: 30)
                                    .foregroundColor(.green)
                                VStack(alignment: .leading) {
                                    Text(provider.displayName)
                                        .foregroundColor(.primary)
                                    Text("Active")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        } else if isProviderConfigured(provider) {
                            HStack {
                                Image(systemName: provider.iconName)
                                    .frame(width: 30)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(provider.displayName)
                                        .foregroundColor(.primary)
                                    Text("Configured — tap to switch")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    Task {
                                        let success = await AIService.shared.testAndSwitchProvider(provider)
                                        if !success {
                                            switchError = "Test failed. Please configure and test this provider first."
                                        }
                                    }
                                } label: {
                                    Text("Use")
                                        .font(.caption)
                                        .foregroundColor(VitaTheme.Colors.textPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                                if let err = switchError, !err.isEmpty {
                                    Text(err)
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        } else {
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
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Custom AI Providers")
                } footer: {
                    Text("Swipe right on a configured provider for quick switch, or tap to edit settings.")
                }

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

                Section {
                    ForEach(AppearanceMode.allCases) { mode in
                        Button {
                            appearanceModeRaw = mode.rawValue
                        } label: {
                            HStack {
                                Image(systemName: mode.iconName)
                                    .frame(width: 30)
                                    .foregroundColor(.blue)
                                Text(mode.displayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if appearanceModeRaw == mode.rawValue {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .accessibilityIdentifier("appearance_\(mode.rawValue)")
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose Light, Dark, or follow your system setting.")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var customProviders: [AIProviderType] {
        AIProviderType.allCases.filter { $0 != .minimaxCn }
    }

    private var isSystemPreConfigured: Bool {
        AIService.shared.currentProvider == .minimaxCn
    }

    private func isProviderActive(_ provider: AIProviderType) -> Bool {
        return AIService.shared.currentProvider == provider
    }

    private func isProviderConfigured(_ provider: AIProviderType) -> Bool {
        // Check if this provider has been configured with an API key
        // For now, check if it has a saved config with non-empty key
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "ai_service_config"),
           let config = try? JSONDecoder().decode([String: String].self, from: data),
           let savedProvider = config["provider"],
           savedProvider == provider.rawValue,
           let apiKey = config["apiKey"],
           !apiKey.isEmpty {
            return true
        }
        return false
    }
}

// MARK: - Custom Provider Configuration

struct CustomProviderConfigView: View {
    let provider: AIProviderType
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var baseURL: String = ""
    @State private var selectedModel: String = ""
    @State private var customModelInput: String = ""
    @State private var isUsingCustomModel: Bool = false
    @State private var isTesting: Bool = false
    @State private var testResult: String?
    @State private var isActive: Bool = false
    @State private var switchError: String? = nil

    var body: some View {
        Form {
            if isActive {
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Active")
                            .foregroundColor(.green)
                    }
                }
            }

            Section {
                HStack {
                    TextField("Base URL", text: $baseURL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .textContentType(.URL)
                    Button {
                        baseURL = provider.baseURL
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Base URL *")
            } footer: {
                Text("Default: \(provider.baseURL)")
            }

            Section {
                SecureField("API Key *", text: $apiKey)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            } header: {
                Text("API Key *")
            } footer: {
                Text("Required — get your API key from \(provider.displayName) dashboard")
            }

            Section {
                if isUsingCustomModel {
                    TextField("Custom model name", text: $customModelInput)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    Picker("Model", selection: $selectedModel) {
                        ForEach(provider.supportedModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Toggle(isUsingCustomModel ? "Custom Model" : "Use Custom Model", isOn: $isUsingCustomModel)
                    .onChange(of: isUsingCustomModel) { _, newValue in
                        if newValue {
                            customModelInput = selectedModel.contains("/")
                                ? String(selectedModel.split(separator: "/").last ?? "")
                                : selectedModel
                        } else {
                            selectedModel = provider.defaultModel
                        }
                    }
            } header: {
                Text("Model")
            } footer: {
                Text("Toggle to enter a custom model name, or select from the list")
            }

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

                // Only show switch button if test passed
                if isActive || testResult == "Success" {
                    Button("Switch to This Provider") {
                        AIService.shared.switchProvider(provider)
                        dismiss()
                    }
                    .foregroundColor(.blue)
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
        guard !baseURL.isEmpty || !apiKey.isEmpty else { return }
        isTesting = true
        testResult = nil

        let finalModel = isUsingCustomModel
            ? (provider.rawValue + "/" + customModelInput)
            : selectedModel

        Task {
            do {
                AIService.shared.configureCustomProvider(
                    provider,
                    baseURL: baseURL.isEmpty ? provider.baseURL : baseURL,
                    apiKey: apiKey,
                    model: finalModel
                )
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
                    isActive = (AIService.shared.currentProvider == provider)
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
                    AppIconView()
                        .frame(width: 100, height: 100)

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
                NavigationLink {
                    LegalDocumentView(document: .privacyPolicy)
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }

                NavigationLink {
                    LegalDocumentView(document: .termsOfService)
                } label: {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            } header: {
                Text("Legal")
            } footer: {
                Text("These documents are bundled with the app and available offline.")
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