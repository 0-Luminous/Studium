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
                    Button(action: onAddShortCard) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .font(.title3)
                                .foregroundColor(.kiwi)
                                .frame(width: 24)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            Text("Короткая карточка")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }

                    // Кнопка обычной карточки
                    Button(action: onAddRegularCard) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            Text("Карточка")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }

                    // Кнопка тестовой карточки
                    Button(action: onAddTestCard) {
                        HStack {
                            Image(systemName: "checklist")
                                .font(.title3)
                                .foregroundColor(.watermelonRed)
                                .frame(width: 24)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            Text("Карточка-тест")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .frame(width: 180)
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