//
//  ContentView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingAddOptions = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showingAddOptions.toggle()
                        }
                    }) {
                        Image(systemName: showingAddOptions ? "xmark" : "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(showingAddOptions ? Color.red : Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))
            
            // Custom menu overlay
            if showingAddOptions {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            // Module button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showingAddOptions = false
                                }
                                // TODO: Add module logic
                                print("Adding module")
                            }) {
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
                                        .fill(Color.blue)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                            }
                            
                            // Folder button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showingAddOptions = false
                                }
                                // TODO: Add folder logic
                                print("Adding folder")
                            }) {
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
                                        .fill(Color.orange)
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
                    insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(x: 20, y: 20)),
                    removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(x: 20, y: 20))
                ))
            }
        }
        .onTapGesture {
            if showingAddOptions {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showingAddOptions = false
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
