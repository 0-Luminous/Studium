//
//  MainView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import CoreData
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    // Вычисляемые свойства для адаптивной сетки
    private var gridColumns: [GridItem] {
        let spacing: CGFloat = 16
        let minItemWidth: CGFloat = 150

        return [
            GridItem(.adaptive(minimum: minItemWidth, maximum: 200), spacing: spacing),
        ]
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Заголовок с навигацией
                HStack {
                    if !viewModel.navigationPath.isEmpty {
                        Button(action: {
                            viewModel.navigateBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.navigationPath.last?.name ?? "Studium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if !viewModel.navigationPath.isEmpty {
                            Text(viewModel.breadcrumbText)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)

                    Spacer()
                }
                .background(.thinMaterial)
                

                // Сетка элементов
                if viewModel.currentItems.isEmpty {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: viewModel.currentFolderId == nil ? "square.stack.3d.up" : "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .opacity(0.6)

                        VStack(spacing: 8) {
                            Text(viewModel.currentFolderId == nil ? "Добро пожаловать!" : "Пустая папка")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Text(viewModel.currentFolderId == nil ? "Создайте свой первый модуль или папку" : "Добавьте модули или папки")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 20) {
                            ForEach(viewModel.currentItems) { item in
                                MainItemView(item: item) {
                                    // Действие при нажатии
                                    viewModel.handleItemTap(item)
                                } onDelete: {
                                    // Действие при удалении
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        viewModel.deleteItem(item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // Отступ для кнопки
                    }
                }
            }
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))

            // Кнопка добавления (теперь в отдельном слое ZStack)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.toggleAddOptions()
                    }) {
                        Image(systemName: viewModel.showingAddOptions ? "xmark" : "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(viewModel.showingAddOptions ? Color.red : Color.accentColor)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }

            // Меню добавления
            if viewModel.showingAddOptions {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            // Кнопка модуля
                            Button(action: {
                                viewModel.showAddModule()
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
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                            }

                            // Кнопка папки
                            Button(action: {
                                viewModel.showAddFolder()
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
        .onTapGesture {
            if viewModel.showingAddOptions {
                viewModel.hideAddOptions()
            }
        }
        .sheet(isPresented: $viewModel.showingAddModule) {
            AddModuleView(onCreateModuleWithIndex: { name, gradientIndex, description in
                viewModel.addModule(name: name, gradientIndex: gradientIndex, description: description)
            })
        }
        .sheet(isPresented: $viewModel.showingAddFolder) {
            AddFolderView { name in
                viewModel.addFolder(name: name)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingModuleView) {
            if let module = viewModel.selectedModule {
                ModuleView(module: module)
            }
        }
    }
}


#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
