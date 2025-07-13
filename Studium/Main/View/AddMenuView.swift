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
                    Button(action: onAddModule) {
                        HStack {
                            Image(systemName: "tray.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 24)
                            Text("Модуль")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }

                    // Кнопка папки
                    Button(action: onAddFolder) {
                        HStack {
                            Image(systemName: "plus.rectangle.on.folder.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 24)
                            Text("Папка")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                }
                .frame(width: 140)
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
