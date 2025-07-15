//
//  AddCardMenuView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct AddCardMenuView: View {
    let onAddShortCard: () -> Void
    let onAddRegularCard: () -> Void
    let onAddTestCard: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    // Кнопка короткой карточки
                    MenuButtonView(
                        icon: "text.alignleft",
                        title: "Карточка",
                        customIconColor: .kiwi,
                        action: onAddShortCard
                    )

                    // Кнопка обычной карточки
                    MenuButtonView(
                        icon: "doc.text",
                        title: "Мультикарточка",
                        customIconColor: .blue,
                        action: onAddRegularCard
                    )

                    // Кнопка тестовой карточки
                    MenuButtonView(
                        icon: "checklist",
                        title: "Квиз-карточка",
                        customIconColor: .watermelonRed,
                        action: onAddTestCard
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
    AddCardMenuView(
        onAddShortCard: { print("Add short card") },
        onAddRegularCard: { print("Add regular card") },
        onAddTestCard: { print("Add test card") }
    )
    .background(Color.black)
} 

            
