import SwiftUI

struct ThemesSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @AppStorage("customThemes") private var customThemesData: Data = Data()
    @ObservedObject var browser: Browser
    
    @State private var isCreatingCustom = false
    @State private var editingTheme: CustomTheme?
    @State private var customName = ""
    @State private var customColor1 = Color.blue
    @State private var customColor2 = Color.purple
    @State private var customBlur: Double = 0
    @State private var customNoise: Double = 0
    @State private var customOpacity: Double = 1.0
    
    private var customThemes: [CustomTheme] {
        (try? JSONDecoder().decode([CustomTheme].self, from: customThemesData)) ?? []
    }
    
    private var currentEffects: ThemeEffects {
        ThemeEffects.resolve(selectedTheme: selectedTheme, customThemesData: customThemesData)
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Themes")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color("UIText"))
            
            // ── Live Preview ──
            livePreview
            
            // ── Built-in Themes ──
            themeSection(title: "Built-in Themes") {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Theme.allCases) { theme in
                        ThemeCard(
                            gradient: theme.gradient,
                            name: theme.rawValue,
                            isSelected: selectedTheme == theme.rawValue
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTheme = theme.rawValue
                            }
                        }
                    }
                }
            }
            
            // ── Custom Themes ──
            themeSection(title: "Custom Themes") {
                HStack {
                    Spacer()
                    Button(action: { beginCreating() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12))
                            Text("New")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, -28) // overlay on section header line
                
                if customThemes.isEmpty && !isCreatingCustom {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Image(systemName: "paintpalette")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("Create a custom theme with your own colors, blur, and noise")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 16)
                        Spacer()
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(customThemes) { theme in
                            ThemeCard(
                                gradient: theme.gradient,
                                name: theme.name,
                                isSelected: selectedTheme == theme.id.uuidString,
                                hasEffects: theme.blurRadius > 0 || theme.noiseOpacity > 0 || theme.chromeOpacity < 1.0
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTheme = theme.id.uuidString
                                }
                            }
                            .contextMenu {
                                Button("Edit") { beginEditing(theme) }
                                Divider()
                                Button("Delete", role: .destructive) { deleteCustomTheme(theme) }
                            }
                        }
                    }
                }
            }
            
            // ── Custom Theme Editor ──
            if isCreatingCustom {
                customThemeEditor
            }
            
            Spacer()
        }
    }
    
    // MARK: - Live Preview
    
    private var livePreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Preview")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            ZStack {
                // Background layers (same as MainView)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(currentEffects.gradient)
                    .opacity(currentEffects.chromeOpacity)
                
                if currentEffects.blurRadius > 0 {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(min(currentEffects.blurRadius / 30.0, 0.6))
                }
                
                if currentEffects.noiseOpacity > 0.001 {
                    NoiseTexture(opacity: currentEffects.noiseOpacity)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                // Mini browser mockup
                VStack(spacing: 0) {
                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle().fill(.white.opacity(0.3)).frame(width: 8, height: 8)
                        }
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.12))
                            .frame(width: 140, height: 16)
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        }
    }
    
    // MARK: - Custom Theme Editor
    
    private var customThemeEditor: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(editingTheme == nil ? "New Custom Theme" : "Edit \"\(customName)\"")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("UIText"))
                Spacer()
                Button(action: { isCreatingCustom = false; editingTheme = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Divider().opacity(0.3)
            
            VStack(spacing: 16) {
                // ── Inline preview ──
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(colors: [customColor1, customColor2],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .opacity(customOpacity)
                    
                    if customBlur > 0 {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(min(customBlur / 30.0, 0.6))
                    }
                    
                    if customNoise > 0.001 {
                        NoiseTexture(opacity: customNoise)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    
                    // Mini tab bar
                    VStack(spacing: 0) {
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle().fill(.white.opacity(0.25)).frame(width: 6, height: 6)
                            }
                            Spacer()
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white.opacity(0.1))
                                .frame(width: 80, height: 12)
                            Spacer()
                            Color.clear.frame(width: 18)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(.white.opacity(0.82))
                            .padding(.horizontal, 6)
                            .padding(.bottom, 6)
                    }
                }
                .frame(height: 70)
                
                // ── Name ──
                HStack(spacing: 10) {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 70, alignment: .leading)
                    TextField("My Theme", text: $customName)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                }
                
                // ── Colors ──
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Text("Start")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, alignment: .leading)
                        ColorPicker("", selection: $customColor1, supportsOpacity: false)
                            .labelsHidden()
                    }
                    HStack(spacing: 8) {
                        Text("End")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, alignment: .leading)
                        ColorPicker("", selection: $customColor2, supportsOpacity: false)
                            .labelsHidden()
                    }
                    Spacer()
                }
                
                Divider().opacity(0.2)
                
                // ── Effects ──
                VStack(spacing: 12) {
                    Text("Effects")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    effectSlider(
                        icon: "drop.fill",
                        label: "Frosted Glass",
                        value: $customBlur,
                        range: 0...30,
                        format: { String(format: "%.0f", $0) }
                    )
                    
                    effectSlider(
                        icon: "sparkles",
                        label: "Noise Texture",
                        value: $customNoise,
                        range: 0...0.3,
                        format: { String(format: "%.0f%%", $0 * 100) }
                    )
                    
                    effectSlider(
                        icon: "circle.lefthalf.filled",
                        label: "Transparency",
                        value: $customOpacity,
                        range: 0.3...1.0,
                        format: { String(format: "%.0f%%", $0 * 100) }
                    )
                }
                
                // ── Actions ──
                HStack(spacing: 10) {
                    Spacer()
                    
                    Button("Cancel") {
                        isCreatingCustom = false
                        editingTheme = nil
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    
                    Button(editingTheme == nil ? "Create Theme" : "Save") {
                        saveCustomTheme()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("InputBG").opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color("UIBorder").opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Effect Slider
    
    private func effectSlider(
        icon: String,
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        format: @escaping (Double) -> String
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 14)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("UIText").opacity(0.7))
                .frame(width: 90, alignment: .leading)
            
            Slider(value: value, in: range)
                .controlSize(.small)
            
            Text(format(value.wrappedValue))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
    
    // MARK: - Section helper
    
    private func themeSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("UIText").opacity(0.7))
            
            content()
        }
    }
    
    // MARK: - Actions
    
    private func beginCreating() {
        customName = ""
        customColor1 = .blue
        customColor2 = .purple
        customBlur = 0
        customNoise = 0
        customOpacity = 1.0
        editingTheme = nil
        isCreatingCustom = true
    }
    
    private func beginEditing(_ theme: CustomTheme) {
        editingTheme = theme
        customName = theme.name
        customColor1 = Color(hex: theme.color1Hex)
        customColor2 = Color(hex: theme.color2Hex)
        customBlur = theme.blurRadius
        customNoise = theme.noiseOpacity
        customOpacity = theme.chromeOpacity
        isCreatingCustom = true
    }
    
    private func saveCustomTheme() {
        var themes = customThemes
        let hex1 = customColor1.toHex()
        let hex2 = customColor2.toHex()
        let name = customName.trimmingCharacters(in: .whitespaces)
        
        if let editing = editingTheme, let index = themes.firstIndex(where: { $0.id == editing.id }) {
            themes[index] = CustomTheme(
                id: editing.id, name: name,
                color1Hex: hex1, color2Hex: hex2,
                blurRadius: customBlur, noiseOpacity: customNoise, chromeOpacity: customOpacity
            )
        } else {
            let newTheme = CustomTheme(
                id: UUID(), name: name,
                color1Hex: hex1, color2Hex: hex2,
                blurRadius: customBlur, noiseOpacity: customNoise, chromeOpacity: customOpacity
            )
            themes.append(newTheme)
            selectedTheme = newTheme.id.uuidString
        }
        
        if let data = try? JSONEncoder().encode(themes) {
            customThemesData = data
        }
        isCreatingCustom = false
        editingTheme = nil
    }
    
    private func deleteCustomTheme(_ theme: CustomTheme) {
        var themes = customThemes
        themes.removeAll { $0.id == theme.id }
        if selectedTheme == theme.id.uuidString {
            selectedTheme = Theme.bluePurple.rawValue
        }
        if let data = try? JSONEncoder().encode(themes) {
            customThemesData = data
        }
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    let gradient: LinearGradient
    let name: String
    let isSelected: Bool
    var hasEffects: Bool = false
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(gradient)
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(isSelected ? Color.accentColor : .white.opacity(0.15), lineWidth: isSelected ? 2 : 0.5)
                        )
                        .shadow(color: .black.opacity(isHovered ? 0.14 : 0.06), radius: isHovered ? 5 : 2, y: 2)
                    
                    HStack(spacing: 3) {
                        if hasEffects {
                            Image(systemName: "sparkles")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(3)
                        }
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                    }
                    .padding(5)
                }
                
                Text(name)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(Color("UIText"))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.04 : 1.0)
        .animation(.easeOut(duration: 0.12), value: isHovered)
        .onHover { isHovered = $0 }
    }
}
