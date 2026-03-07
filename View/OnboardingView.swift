//
//  OnboardingView.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 3/7/26.
//

import SwiftUI
import SwiftData

// MARK: - Steps

private enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case theme
    case searchEngine
    case appearance
    case language
    case done
}

// MARK: - Main View

struct OnboardingView: View {
    var onFinish: () -> Void

    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @Environment(\.colorScheme) private var colorScheme
    @Query var generalSettings: [GeneralSetting]

    @State private var step: OnboardingStep = .welcome
    @State private var appeared = false

    // Local selections (committed on finish)
    @State private var chosenTheme: String = Theme.bluePurple.rawValue
    @State private var chosenEngine: String = "Google"
    @State private var chosenMode: String = "System"
    @State private var chosenLanguage: String = "English"

    private var currentGradient: LinearGradient {
        if let theme = Theme.allCases.first(where: { $0.rawValue == chosenTheme }) {
            return theme.gradient
        }
        return Theme.bluePurple.gradient
    }

    private var stepCount: Int { OnboardingStep.allCases.count }

    var body: some View {
        ZStack {
            // Background gradient
            currentGradient
                .opacity(0.15)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: chosenTheme)

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(OnboardingStep.allCases, id: \.rawValue) { s in
                        Circle()
                            .fill(s == step ? Color("UIText") : Color("UIText").opacity(0.15))
                            .frame(width: s == step ? 8 : 6, height: s == step ? 8 : 6)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                Spacer()

                // Content
                Group {
                    switch step {
                    case .welcome:
                        welcomeStep
                    case .theme:
                        themeStep
                    case .searchEngine:
                        searchEngineStep
                    case .appearance:
                        appearanceStep
                    case .language:
                        languageStep
                    case .done:
                        doneStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)

                Spacer()

                // Navigation buttons
                HStack(spacing: 12) {
                    if step != .welcome && step != .done {
                        Button(action: goBack) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Color("UIText").opacity(0.6))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("UIText").opacity(0.06))
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    if step == .done {
                        Button(action: finish) {
                            Text("Get Started")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 32)
                                .background(currentGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: goNext) {
                            HStack(spacing: 4) {
                                Text(step == .welcome ? "Let's Go" : "Next")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 24)
                            .background(currentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 28)
            }
        }
        .frame(width: 540, height: 520)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .onAppear {
            // Load existing settings if available
            if let s = generalSettings.first {
                chosenEngine = s.searchEngine
                chosenMode = s.screenMode
            }
            let lang = Locale.current.language.languageCode?.identifier ?? "en"
            chosenLanguage = languageNameForCode(lang)

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)

                currentGradient
                    .mask(
                        Image(systemName: "globe")
                            .font(.system(size: 34, weight: .medium))
                    )
                    .frame(width: 34, height: 34)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)

            Text("Welcome to AeroBrowser")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("UIText"))

            Text("Let's set things up just the way you like.")
                .font(.system(size: 14))
                .foregroundColor(Color("UIText").opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    private var themeStep: some View {
        VStack(spacing: 20) {
            stepHeader(icon: "paintpalette.fill", title: "Choose a Theme", subtitle: "Pick a color that feels right")

            // 2-row grid of theme swatches
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(Theme.allCases) { theme in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            chosenTheme = theme.rawValue
                        }
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(theme.gradient)
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(chosenTheme == theme.rawValue ? Color.white : .clear, lineWidth: 2.5)
                                    )
                                    .shadow(color: chosenTheme == theme.rawValue ? .black.opacity(0.2) : .clear, radius: 4, y: 2)

                                if chosenTheme == theme.rawValue {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                                }
                            }

                            Text(theme.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color("UIText").opacity(chosenTheme == theme.rawValue ? 1 : 0.5))
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 36)
        }
    }

    private var searchEngineStep: some View {
        VStack(spacing: 20) {
            stepHeader(icon: "magnifyingglass", title: "Default Search Engine", subtitle: "You can change this later in Settings")

            VStack(spacing: 6) {
                ForEach(SEARCH_ENGINE_LIST, id: \.name) { engine in
                    engineRow(engine)
                }
            }
            .padding(.horizontal, 56)
        }
    }

    private var appearanceStep: some View {
        VStack(spacing: 20) {
            stepHeader(icon: "circle.lefthalf.filled", title: "Appearance", subtitle: "Choose your preferred look")

            HStack(spacing: 16) {
                appearanceCard(mode: "Light", icon: "sun.max.fill", label: "Light")
                appearanceCard(mode: "Dark", icon: "moon.fill", label: "Dark")
                appearanceCard(mode: "System", icon: "laptopcomputer", label: "System")
            }
            .padding(.horizontal, 48)
        }
    }

    private var languageStep: some View {
        VStack(spacing: 20) {
            stepHeader(icon: "globe", title: "Language", subtitle: "Pick your preferred language")

            VStack(spacing: 4) {
                ForEach(languageOptions, id: \.code) { lang in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) { chosenLanguage = lang.name }
                    }) {
                        HStack(spacing: 10) {
                            Text(lang.flag)
                                .font(.system(size: 18))
                                .frame(width: 24)

                            Text(lang.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("UIText"))

                            Spacer()

                            if chosenLanguage == lang.name {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("Point"))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(chosenLanguage == lang.name ? Color("UIText").opacity(0.06) : .clear)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 56)
        }
    }

    private var doneStep: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)

                currentGradient
                    .mask(
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 34, weight: .medium))
                    )
                    .frame(width: 34, height: 34)
            }

            Text("You're All Set!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("UIText"))

            Text("You can always change these in Settings.")
                .font(.system(size: 14))
                .foregroundColor(Color("UIText").opacity(0.5))
                .multilineTextAlignment(.center)

            // Summary
            VStack(spacing: 8) {
                summaryRow(icon: "paintpalette.fill", label: "Theme", value: chosenTheme)
                summaryRow(icon: "magnifyingglass", label: "Search", value: chosenEngine)
                summaryRow(icon: "circle.lefthalf.filled", label: "Appearance", value: chosenMode)
                summaryRow(icon: "globe", label: "Language", value: chosenLanguage)
            }
            .padding(.horizontal, 80)
            .padding(.top, 8)
        }
    }

    // MARK: - Reusable Components

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            currentGradient
                .mask(
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                )
                .frame(width: 28, height: 28)

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("UIText"))

            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(Color("UIText").opacity(0.45))
        }
    }

    private func engineRow(_ engine: SearchEngine) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) { chosenEngine = engine.name }
        }) {
            HStack(spacing: 12) {
                // Favicon
                if let img = decodeBase64(colorScheme == .dark ? engine.faviconWhite : engine.favicon) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundColor(Color("Icon"))
                        .frame(width: 20, height: 20)
                }

                Text(engine.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("UIText"))

                Spacer()

                ZStack {
                    Circle()
                        .stroke(chosenEngine == engine.name ? Color("Point") : Color("UIBorder").opacity(0.5), lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if chosenEngine == engine.name {
                        Circle()
                            .fill(Color("Point"))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(chosenEngine == engine.name ? Color("UIText").opacity(0.05) : Color("UIText").opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(chosenEngine == engine.name ? Color("Point").opacity(0.3) : Color("UIBorder").opacity(0.2), lineWidth: 0.5)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func appearanceCard(mode: String, icon: String, label: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) { chosenMode = mode }
        }) {
            VStack(spacing: 10) {
                // Preview card
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(mode == "Dark" ? Color(nsColor: NSColor(white: 0.12, alpha: 1)) :
                              mode == "Light" ? Color.white :
                              colorScheme == .dark ? Color(nsColor: NSColor(white: 0.12, alpha: 1)) : Color.white)
                        .frame(height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(chosenMode == mode ? Color("Point") : Color("UIBorder").opacity(0.3), lineWidth: chosenMode == mode ? 2 : 0.5)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(mode == "Dark" ? .white.opacity(0.8) :
                                         mode == "Light" ? Color(nsColor: NSColor(white: 0.15, alpha: 1)) :
                                         Color("UIText").opacity(0.6))
                }

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(chosenMode == mode ? Color("UIText") : Color("UIText").opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color("UIText").opacity(0.4))
                .frame(width: 16)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color("UIText").opacity(0.5))

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("UIText"))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Navigation

    private func goNext() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let next = OnboardingStep(rawValue: step.rawValue + 1) {
                step = next
            }
        }
    }

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let prev = OnboardingStep(rawValue: step.rawValue - 1) {
                step = prev
            }
        }
    }

    private func finish() {
        // Apply all choices
        selectedTheme = chosenTheme
        SettingsManager.setSearchEngine(chosenEngine)
        SettingsManager.setScreenMode(chosenMode)

        let code = languageCodeForName(chosenLanguage)
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onFinish()
    }

    // MARK: - Helpers

    private func decodeBase64(_ base64: String) -> NSImage? {
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
        return NSImage(data: data)
    }

    private struct LanguageOption {
        let code: String
        let name: String
        let flag: String
    }

    private let languageOptions: [LanguageOption] = [
        .init(code: "en", name: "English", flag: "🇬🇧"),
        .init(code: "de", name: "Deutsch", flag: "🇩🇪"),
        .init(code: "es", name: "Español", flag: "🇪🇸"),
        .init(code: "fr", name: "Français", flag: "🇫🇷"),
        .init(code: "hi", name: "हिन्दी", flag: "🇮🇳"),
        .init(code: "ja", name: "日本語", flag: "🇯🇵"),
        .init(code: "ko", name: "한국어", flag: "🇰🇷"),
        .init(code: "nb", name: "Norsk", flag: "🇳🇴"),
        .init(code: "zh", name: "中文", flag: "🇨🇳"),
    ]

    private func languageNameForCode(_ code: String) -> String {
        languageOptions.first(where: { $0.code == code })?.name ?? "English"
    }

    private func languageCodeForName(_ name: String) -> String {
        languageOptions.first(where: { $0.name == name })?.code ?? "en"
    }
}
