import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var aiService = AIService.shared
    
    @State private var selectedProvider: AIProviderType = .minimax
    @State private var selectedModel: String = "claude-opus-4.8"
    @State private var apiKey: String = ""
    @State private var showingProviderPicker = false
    @State private var showingModelPicker = false
    @State private var showingApiKeyInput = false
    @State private var testResult: String?
    @State private var isTesting = false
    
    var body: some View {
        NavigationStack {
            List {
                // AI Provider Section
                Section {
                    // Provider Selection
                    Button {
                        showingProviderPicker = true
                    } label: {
                        HStack {
                            Label(selectedProvider.displayName, systemImage: selectedProvider.iconName)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    // Model Selection
                    Button {
                        showingModelPicker = true
                    } label: {
                        HStack {
                            Label("Model", systemImage: "cpu")
                            Spacer()
                            Text(selectedModel)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    // API Key
                    Button {
                        showingApiKeyInput = true
                    } label: {
                        HStack {
                            Label("API Key", systemImage: "key")
                            Spacer()
                            if apiKey.isEmpty {
                                Text("Not Set")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(String(repeating: "•", count: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text("AI Assistant Configuration")
                } footer: {
                    Text("Select your AI service provider and enter API Key")
                }
                
                // Test Connection Section
                Section {
                    Button {
                        testAIConnection()
                    } label: {
                        HStack {
                            Label("Test Connection", systemImage: "wifi")
                            Spacer()
                            if isTesting {
                                ProgressView()
                            } else if let result = testResult {
                                Text(result)
                                    .foregroundColor(result == "Success" ? .green : .red)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    .disabled(isTesting || apiKey.isEmpty)
                } header: {
                    Text("Connection Test")
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
            .sheet(isPresented: $showingProviderPicker) {
                ProviderPickerView(selectedProvider: $selectedProvider)
            }
            .sheet(isPresented: $showingModelPicker) {
                ModelPickerView(selectedProvider: selectedProvider, selectedModel: $selectedModel)
            }
            .sheet(isPresented: $showingApiKeyInput) {
                ApiKeyInputView(apiKey: $apiKey)
            }
            .onAppear {
                loadCurrentSettings()
            }
            .onChange(of: selectedProvider) { _, newValue in
                updateProvider(newValue)
            }
        }
    }
    
    private func loadCurrentSettings() {
        selectedProvider = aiService.currentProvider
        selectedModel = aiService.selectedModel
        apiKey = aiService.apiKey
    }
    
    private func updateProvider(_ provider: AIProviderType) {
        aiService.selectProvider(provider)
        selectedModel = provider.defaultModel
    }
    
    private func testAIConnection() {
        isTesting = true
        testResult = nil
        
        Task {
            do {
                let response = try await aiService.sendMessage("Hello", history: [])
                await MainActor.run {
                    testResult = "Success"
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "Failed: \(error.localizedDescription)"
                    isTesting = false
                }
            }
        }
    }
}

// MARK: - Provider Picker

struct ProviderPickerView: View {
    @Binding var selectedProvider: AIProviderType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(AIProviderType.allCases) { provider in
                Button {
                    selectedProvider = provider
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: provider.iconName)
                            .frame(width: 30)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(provider.displayName)
                                .foregroundColor(.primary)
                            Text("\(provider.supportedModels.count) models available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedProvider == provider {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select AI Provider")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Model Picker

struct ModelPickerView: View {
    let selectedProvider: AIProviderType
    @Binding var selectedModel: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(selectedProvider.supportedModels, id: \.self) { model in
                Button {
                    selectedModel = model
                    AIService.shared.selectedModel = model
                    dismiss()
                } label: {
                    HStack {
                        Text(model)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedModel == model {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - API Key Input

struct ApiKeyInputView: View {
    @Binding var apiKey: String
    @Environment(\.dismiss) private var dismiss
    @State private var inputKey: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Enter API Key", text: $inputKey)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Your API Key will be securely stored on your device")
                }
                
                Section {
                    Button("Save") {
                        apiKey = inputKey
                        AIService.shared.configure(
                            provider: AIService.shared.currentProvider,
                            model: AIService.shared.selectedModel,
                            apiKey: inputKey
                        )
                        dismiss()
                    }
                    .disabled(inputKey.isEmpty)
                }
            }
            .navigationTitle("Enter API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                inputKey = apiKey
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
