import SwiftUI
import LoggerPackage

@MainActor
struct SettingsView: View {
    @State private var selectedDataBase: StorageType = .swiftData
    @State private var token: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    authorRow
                }
                
                Section {
                    storageRow
                    tokenRow
                }
            }
            .navigationTitle("Настройки")
            .background(AppColors.backPrimary)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 56)
        }
        .task {
            token = SettingsManager.shared.token
            selectedDataBase = SettingsManager.shared.storage
        }
    }
    
    private var authorRow: some View {
        HStack(spacing: 16) {
            Image("icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 64)
                .clipShape(.rect(cornerRadius: 12))
                .shadow(color: .gray.opacity(0.4), radius: 4)
            
            VStack(alignment: .listRowSeparatorLeading, spacing: 0) {
                Text("ToDo App")
                    .font(.title2)
                Text("by trofim petyanov.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .offset(y: -2)
        }
    }
    
    private var storageRow: some View {
        NavigationLink {
            List(StorageType.allCases) { dataBaseType in
                HStack {
                    settingRow(dataBaseType.title, systemName: dataBaseType.imageName, color: dataBaseType.color)
                    
                    Spacer()
                    
                    if dataBaseType == selectedDataBase {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    SettingsManager.shared.storage = dataBaseType
                    selectedDataBase = SettingsManager.shared.storage
                    
                    Logger.logInfo("Storage set to \(selectedDataBase).")
                }
            }
            .navigationTitle("Хранилище")
            .toolbarTitleDisplayMode(.inline)
            .background(AppColors.backPrimary)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 56)
        } label: {
            settingRow("Хранилище", systemName: "externaldrive.fill", color: .blue)
        }
    }
    
    private var tokenRow: some View {
        NavigationLink {
            List {
                Section {
                    TextField("Токен", text: $token)
                        .onAppear {
                            UITextField.appearance().clearButtonMode = .whileEditing
                        }
                        .onChange(of: token) {
                            Task {
                                SettingsManager.shared.token = token
                                
                                Logger.logInfo("Token has changed.")
                            }
                        }
                } footer: {
                    Text("Не забудьте обновить список (свайп сверху вниз).")
                }
            }
            .navigationTitle("Токен")
            .toolbarTitleDisplayMode(.inline)
            .background(AppColors.backPrimary)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 56)
        } label: {
            settingRow("Токен", systemName: "key.fill", color: .green)
        }

    }
    
    private func settingRow(_ titleKey: String, systemName: String, color: Color) -> some View {
        Label(
            title: { Text(titleKey) },
            icon: {
                Rectangle()
                    .foregroundStyle(color)
                    .clipShape(.rect(cornerRadius: 8))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: systemName)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
            }
        )
    }
}

#Preview {
    SettingsView()
}
