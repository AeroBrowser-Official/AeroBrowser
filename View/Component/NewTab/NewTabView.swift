import SwiftUI
import SwiftData

struct NewTabView: View {
  @Query(sort: \Favorite.createDate, order: .forward) var favorites: [Favorite]
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var service: Service

  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab

  @State private var showEditDialog = false
  @State private var editingFavorite: Favorite?
  @State private var showContextMenu: Favorite?

  @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue

  private let maxFavorites = 6

  private var currentTheme: Theme {
    Theme(rawValue: selectedTheme) ?? .bluePurple
  }

  var body: some View {
    VStack(spacing: 20) {
      Spacer()

      Image("MainLogo")
        .resizable()
        .frame(width: 130, height: 130)

      FavoriteGrid(
        favorites: favorites,
        browser: browser,
        tab: tab,
        editingFavorite: $editingFavorite,
        showEditDialog: $showEditDialog,
        showContextMenu: $showContextMenu,
        maxFavorites: maxFavorites,
        containerWidth: NSScreen.main?.frame.width ?? 800
      )

      Spacer()
    }
    .padding(.vertical, 40)
    .padding(.horizontal, 32)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.black.opacity(0.08))
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    )
    .cornerRadius(20)
    .padding([.leading, .trailing, .bottom], 10)
    .shadow(radius: 5)
    .overlay(
      Group {
        if showEditDialog {
          Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
              showEditDialog = false
              editingFavorite = nil
            }

          FavoriteEditDialog(
            isPresented: $showEditDialog,
            editingFavorite: $editingFavorite
          )
        }
      }
    )
  }
}
