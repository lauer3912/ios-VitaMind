import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var aiService = AIService.shared

    var body: some View {
        NavigationStack {
            List {
                // Section 1: System Pre-configured AI (read-only, no provider name)
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Spacer()
                        Text("Ready")
                            .foregroundColor(.green)
                            .fontWeight(.medium)
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

    // Custom providers: all except minimaxCn (minimaxGlobal + other 9)
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
    @State private var customModelInput: String = ""
    @State private var isUsingCustomModel: Bool = false
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var isActive = false

    var body: some View {
        Form {
            // Status
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
                let previousProvider = AIService.shared.currentProvider
                let previousModel = AIService.shared.selectedModel
                let previousKey = AIService.shared.apiKey

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
                    // Use app's actual icon from Assets
                    if let appIcon = UIImage(named: "AppIcon") {
                        Image(uiImage: appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                    }
                    
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