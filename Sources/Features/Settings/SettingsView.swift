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
                                    aiService.resetToDefaultProvider()
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
                                    if isProviderActive(provider) {
                                        Text("Active")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    } else {
                                        Text("Tap to configure")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if isProviderActive(provider) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Custom AI Providers")
                } footer: {
                    Text("10 AI providers available. Configure your own or activate a provider you've already set up.")
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

    // Custom providers: all except minimaxCn (minimaxGlobal + other 9)
    private var customProviders: [AIProviderType] {
        AIProviderType.allCases.filter { $0 != .minimaxCn }
    }

    private var isSystemPreConfigured: Bool {
        AIService.shared.currentProvider == .minimaxCn
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
    @State private var customModelInput: String = ""
    @State private var isUsingCustomModel: Bool = false
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var isActive = false

    var body: some View {
        Form {
            // Active Status
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

            // Base URL
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

            // API Key
            Section {
                SecureField("API Key *", text: $apiKey)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            } header: {
                Text("API Key *")
            } footer: {
                Text("Required — get your API key from \(provider.displayName) dashboard")
            }

            // Model
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
                if !isUsingCustomModel {
                    Text("Or toggle on to enter a custom model name")
                }
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
                
                if isActive {
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
                let tempProvider = AIService.shared.currentProvider
                let tempModel = AIService.shared.selectedModel
                let tempKey = AIService.shared.apiKey

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
                    // Try to load app icon from Asset Catalog
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

// MARK: - App Icon View (cross-platform asset loading)

struct AppIconView: View {
    var body: some View {
        if let uiImage = UIImage(named: "AppIcon") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else if let uiImage = UIImage(named: "AppIcon60@3x") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            // Fallback: show app's actual icon from main bundle
            IconFromBundleView()
        }
    }
}

struct IconFromBundleView: View {
    var body: some View {
        if let icon = Bundle.main.infoDictionary?["CFBundleIconFiles"] as? [String],
           let firstIcon = icon.first,
           let uiImage = UIImage(named: firstIcon) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameState())
}