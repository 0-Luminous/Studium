//
//  AddMenuView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct AddMenuView: View {
    let onAddModule: () -> Void
    let onAddFolder: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    // Кнопка модуля
                    MenuButtonView(
                        icon: "tray.fill",
                        title: "Модуль",
                        customIconColor: .neonPink,
                        action: onAddModule
                    )

                    // Кнопка папки
                    MenuButtonView(
                        icon: "plus.rectangle.on.folder.fill",
                        title: "Папка",
                        customIconColor: .amber,
                        action: onAddFolder
                    )
                }
                .frame(width: 220) // Увеличил ширину для MenuButtonView
                .padding(.trailing, 20)
                .padding(.bottom, 90)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
            removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.8))
        ))
    }
}

#Preview {
    AddMenuView(
        onAddModule: { print("Add module") },
        onAddFolder: { print("Add folder") }
    )
    .background(Color.black)
}
