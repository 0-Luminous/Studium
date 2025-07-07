//
//  moduleView.swift
//  Studium
//
//  Created by Yan on 4/7/25.
//

import SwiftUI

struct ModuleView: View {
    let module: MainItem
    @StateObject private var viewModel: ModuleViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Инициализатор
    init(module: MainItem) {
        self.module = module
        self._viewModel = StateObject(wrappedValue: ModuleViewModel(module: module))
    }
    
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
                // Заголовок с навигацией (используем градиент модуля вместо thinMaterial)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Название модуля вместо "Studium"
                        Text(module.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "tray.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Модуль")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if !viewModel.tasks.isEmpty {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(viewModel.completedTasks.count)/\(viewModel.tasks.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
                    
                    Spacer()
                }
                .background(
                    // Используем градиент модуля вместо .thinMaterial
                    Rectangle()
                        .fill(module.gradient)
                        .overlay(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        )
                        .ignoresSafeArea(.all, edges: .top)
                )

                
                // Прогресс-бар
                // if !viewModel.tasks.isEmpty {
                //     VStack(spacing: 8) {
                //         HStack {
                //             Text("Прогресс")
                //                 .font(.subheadline)
                //                 .fontWeight(.medium)
                //                 .foregroundColor(.white)
                //             Spacer()
                //             Text("\(Int(viewModel.progressPercentage * 100))%")
                //                 .font(.subheadline)
                //                 .fontWeight(.medium)
                //                 .foregroundColor(.white)
                //         }
                        
                //         ProgressView(value: viewModel.progressPercentage)
                //             .progressViewStyle(LinearProgressViewStyle(tint: .white))
                //             .scaleEffect(y: 1.5)
                //     }
                //     .padding(.horizontal, 20)
                //     .padding(.vertical, 12)
                //     .background(Color.black.opacity(0.2))
                // }
                
                // Контент модуля
                if viewModel.tasks.isEmpty {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .opacity(0.6)
                        
                        VStack(spacing: 8) {
                            Text("Пустой модуль")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Добавьте задачи или материалы для изучения")
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
                            ForEach(viewModel.tasks) { task in
                                ModuleTaskView(task: task) {
                                    viewModel.toggleTaskCompletion(task)
                                } onDelete: {
                                    viewModel.deleteTask(task)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // Отступ для кнопок
                    }
                }
            }
            .background(Color(red: 0.098, green: 0.098, blue: 0.098))
            
            // Нижняя панель с кнопками
            VStack {
                Spacer()
                
                // Панель с кнопками
                HStack(spacing: 16) {
                    // Пустое пространство слева для баланса
                    Spacer()
                    
                    // Кнопка "Учить карточки" - показываем только если есть карточки
                    if !viewModel.tasks.isEmpty {
                        Button(action: {
                            viewModel.startStudyingCards()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "brain.head.profile")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Учить карточки")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentColor)
                            )
                        }
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    
                    // Кнопка добавления
                    Button(action: {
                        viewModel.showAddCardType()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.gray.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $viewModel.showingAddCardType) {
            AddCardTypeView { cardType, title, content, isBothSides in
                viewModel.addCard(type: cardType, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .sheet(isPresented: $viewModel.showingStudyCards) {
            // Здесь будет view для изучения карточек
            StudyCardsView(tasks: viewModel.tasks)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    let sampleModule = MainItem(
        name: "Swift Programming",
        type: .module,
        gradient: LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        createdAt: Date(),
        parentId: nil
    )
    
    ModuleView(module: sampleModule)
}
