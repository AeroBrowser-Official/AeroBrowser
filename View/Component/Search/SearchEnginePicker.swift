//
//  SearchEnginePicker.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 3/7/26.
//

import SwiftUI
import SwiftData

struct SearchEnginePicker: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var generalSettings: [GeneralSetting]
    @Binding var isPresented: Bool

    private var currentEngine: String {
        generalSettings.first?.searchEngine ?? "Google"
    }

    func decodeBase64ToNSImage(base64: String) -> NSImage? {
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
        return NSImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Search with")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("UIText").opacity(0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 6)

            VStack(spacing: 2) {
                ForEach(SEARCH_ENGINE_LIST, id: \.name) { engine in
                    SearchEngineRow(
                        engine: engine,
                        isSelected: engine.name == currentEngine,
                        colorScheme: colorScheme,
                        decodeImage: decodeBase64ToNSImage
                    ) {
                        SettingsManager.setSearchEngine(engine.name)
                        isPresented = false
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .frame(width: 200)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct SearchEngineRow: View {
    let engine: SearchEngine
    let isSelected: Bool
    let colorScheme: ColorScheme
    let decodeImage: (String) -> NSImage?
    let onSelect: () -> Void

    @State private var isHover = false

    private var favicon: NSImage? {
        let b64 = colorScheme == .dark ? engine.faviconWhite : engine.favicon
        return decodeImage(b64)
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                if let img = favicon {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Icon"))
                        .frame(width: 16, height: 16)
                }

                Text(engine.name)
                    .font(.system(size: 13))
                    .foregroundColor(Color("UIText"))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("Point"))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHover ? Color("UIText").opacity(0.06) : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) { isHover = hovering }
        }
    }
}
