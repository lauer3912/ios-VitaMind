import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var aiService = AIService.shared
    
    @State private var selectedProvider: AIProviderType = .minimax
    @State private var selectedModel: String = "MiniMax-M2.7"
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
                                Text("未设置")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(String(repeating: "•", count: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text("AI 助手配置")
                } footer: {
                    Text("选择您的 AI 服务提供商并输入 API Key")
                }
                
                // Test Connection Section
                Section {
                    Button {
                        testAIConnection()
                    } label: {
                        HStack {
                            Label("测试连接", systemImage: "wifi")
                            Spacer()
                            if isTesting {
                                ProgressView()
                            } else if let result = testResult {
                                Text(result)
                                    .foregroundColor(result == "成功" ? .green : .red)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    .disabled(isTesting || apiKey.isEmpty)
                } header: {
                    Text("连接测试")
                }
                
                // App Info Section
                Section {
                    HStack {
                        Text("App 版本")
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
                        Label("关于 VitaMindGo", systemImage: "info.circle")
                    }
                } header: {
                    Text("App 信息")
                }
            }
            .navigationTitle("设置")
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
                    testResult = "成功"
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "失败: \(error.localizedDescription)"
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
                            Text("\(provider.supportedModels.count) 个模型可选")
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
            .navigationTitle("选择 AI 提供商")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
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
            .navigationTitle("选择模型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
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
                    SecureField("输入 API Key", text: $inputKey)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("API Key")
                } footer: {
                    Text("您的 API Key 将安全保存在本地设备上")
                }
                
                Section {
                    Button("保存") {
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
            .navigationTitle("输入 API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
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
                    
                    Text("版本 3.0.0")
                        .foregroundColor(.secondary)
                    
                    Text("您的 AI 健康助理")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
            
            Section {
                Link(destination: URL(string: "https://www.apple.com/privacy/")!) {
                    Label("隐私政策", systemImage: "hand.raised")
                }
                
                Link(destination: URL(string: "https://www.apple.com/legal/terms/")!) {
                    Label("服务条款", systemImage: "doc.text")
                }
            } header: {
                Text("法律信息")
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameState())
}