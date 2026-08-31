import SwiftUI

/// A reusable dropdown for selecting a model from predefined options,
/// or providing a custom model string if "自定义…" is chosen.
struct ModelDropdownView: View {
    let title: String
    let subtitle: String?
    let predefinedModels: [String]
    let defaultModel: String
    
    @Binding var textDraft: String
    let onCommit: () -> Void
    let onReset: () -> Void
    
    @State private var isCustom: Bool = false
    @FocusState private var isEditingCustom: Bool
    
    private var effectiveSelection: Binding<String> {
        Binding(
            get: {
                if predefinedModels.contains(textDraft) && !isCustom {
                    return textDraft
                } else {
                    return "自定义…"
                }
            },
            set: { newValue in
                if newValue == "自定义…" {
                    isCustom = true
                    if predefinedModels.contains(textDraft) {
                        textDraft = ""
                    }
                } else {
                    isCustom = false
                    textDraft = newValue
                    onCommit()
                }
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
            
            HStack(spacing: 8) {
                Picker("", selection: effectiveSelection) {
                    ForEach(predefinedModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                    Divider()
                    Text("自定义…").tag("自定义…")
                }
                .labelsHidden()
                
                if effectiveSelection.wrappedValue == "自定义…" {
                    TextField(defaultModel, text: $textDraft)
                        .textFieldStyle(.roundedBorder)
                        .focused($isEditingCustom)
                        .onSubmit {
                            onCommit()
                        }
                        .onChange(of: isEditingCustom) { isEditing in
                            if !isEditing {
                                onCommit()
                            }
                        }
                }
                
                Button("重置为默认") {
                    isCustom = false
                    onReset()
                }
                .font(.caption)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            if !predefinedModels.contains(textDraft) && !textDraft.isEmpty {
                isCustom = true
            }
        }
        .onChange(of: textDraft) { newValue in
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                isCustom = !predefinedModels.contains(trimmed)
            }
        }
    }
}
