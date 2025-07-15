//
//  MenuButtonView.swift
//  Studium
//
//  Created by Yan on [Date]
//

import SwiftUI

struct MenuButtonView: View {
    // MARK: - Properties
    let icon: String
    let title: String
    let action: () -> Void
    let customIconColor: Color?

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Cached Style Properties
    private struct StyleCache {
        let textColor: Color
        let iconColor: Color
        let iconBackground: Color
        let buttonBackground: AnyShapeStyle
        let shadowColor: Color
    }
    
    private var styleCache: StyleCache {
        let isDark = colorScheme == .dark
        return StyleCache(
            textColor: isDark ? .white : .black,
            iconColor: customIconColor ?? (isDark ? .white : .blue),
            iconBackground: isDark ? Color.graphite : Color.blue.opacity(0.1),
            buttonBackground: AnyShapeStyle(.ultraThinMaterial),
            shadowColor: isDark ? Color.black.opacity(0.3) : Color.gray.opacity(0.2)
        )
    }

    // MARK: - Initializers
    init(
        icon: String,
        title: String,
        customIconColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.customIconColor = customIconColor
        self.action = action
    }

    // MARK: - Body
    var body: some View {
        let cache = styleCache
        
        Button(action: action) {
            HStack {
                // Оптимизированная иконка
                IconView(
                    systemName: icon,
                    iconColor: cache.iconColor,
                    backgroundColor: cache.iconBackground,
                    shadowColor: cache.shadowColor
                )

                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(cache.textColor)
                    .lineLimit(1)
                    .padding(.leading, 6)

                Spacer()

            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(minWidth: 250)
            .background(
                ButtonBackground()
            )
        }
    }
}

// MARK: - Optimized Components

private struct IconView: View {
    let systemName: String
    let iconColor: Color
    let backgroundColor: Color
    let shadowColor: Color
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 20))
            .foregroundColor(iconColor)
            .padding(8)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(
                                Color.gray.opacity(0.5),
                                lineWidth: 1.0
                            )
                    )
            )
            .frame(width: 40, height: 40)
            .shadow(color: shadowColor, radius: 3, x: 0, y: 1)
            .padding(.leading, 16)
    }
}

private struct ButtonBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        MenuButtonView(
            icon: "gear",
            title: "Настройки"
        ) {
            print("Settings tapped")
        }

        MenuButtonView(
            icon: "trash",
            title: "Удалить",
            customIconColor: .red
        ) {
            print("Delete tapped")
        }

        MenuButtonView(
            icon: "text.alignleft",
            title: "Короткая карточка",
            customIconColor: .kiwi,
        ) {
            print("Short card tapped")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
