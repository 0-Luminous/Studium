//
//  AddCardTypeView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct AddCardTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCardType: CardType? = nil
    @State private var isShowingCardEditor = false
    
    let onCreateCard: (CardType, String, String, Bool) -> Void
    
    // Модификатор для кнопок
    private struct ButtonModifier: ViewModifier {
        let isSelected: Bool
        let isDisabled: Bool
        let color: Color

        init(isSelected: Bool = false, isDisabled: Bool = false, color: Color = .accentColor) {
            self.isSelected = isSelected
            self.isDisabled = isDisabled
            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, weight: .medium))
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .foregroundColor(isDisabled ? .gray : .white)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isDisabled ? Color.gray.opacity(0.3) : color
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? color.opacity(0.7) : Color.clear,
                            lineWidth: isSelected ? 1.5 : 0
                        )
                )
                .shadow(
                    color: isSelected ? color.opacity(0.3) : .black.opacity(0.1),
                    radius: 3, x: 0, y: 1
                )
                .opacity(isDisabled ? 0.6 : 1)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Создать карточку")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Выберите тип карточки для изучения")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                
                // Список типов карточек
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Типы карточек")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        ForEach(CardType.allCases, id: \.self) { cardType in
                            CardTypeRow(
                                cardType: cardType,
                                isSelected: selectedCardType == cardType
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCardType = cardType
                                }
                                
                                // Тактильная обратная связь
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Кнопки
                HStack(spacing: 16) {
                    Button(action: {
                        // Тактильная обратная связь
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()

                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 18))
                            Text("Отмена")
                        }
                    }
                    .modifier(ButtonModifier(color: .red))

                    Button(action: {
                        // Тактильная обратная связь
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()

                        if selectedCardType != nil {
                            isShowingCardEditor = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18))
                            Text("Продолжить")
                        }
                    }
                    .modifier(ButtonModifier(isDisabled: selectedCardType == nil, color: .accentColor))
                    .disabled(selectedCardType == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingCardEditor) {
            if let cardType = selectedCardType {
                if cardType == .test {
                    TestCardView { title, content, isBothSides in
                        onCreateCard(cardType, title, content, isBothSides)
                        dismiss()
                    }
                } else {
                    ShortCardView(cardType: cardType) { title, content, isBothSides in
                        onCreateCard(cardType, title, content, isBothSides)
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    AddCardTypeView { cardType, title, content, isBothSides in
        print("Created \(cardType.displayName): \(title), both sides: \(isBothSides)")
    }
}
