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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Заголовок с навигацией
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
                    Rectangle()
                        .fill(module.gradient)
                        .overlay(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        )
                        .ignoresSafeArea(.all, edges: .top)
                )
                
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
                    // Используем отдельную структуру для сетки
                    EnhancedCardGrid(tasks: viewModel.tasks, viewModel: viewModel)
                }
            }
            .background(Color.graphite)
            
            // Нижняя панель с кнопками
            VStack {
                Spacer()
                
                DockBar(
                    hasCards: !viewModel.tasks.isEmpty,
                    onStudyCards: {
                        viewModel.startStudyingCards()
                    },
                    onAddCard: {
                        viewModel.toggleAddCardMenu()
                    },
                    showingAddMenu: viewModel.showingAddCardMenu
                )
            }
            
            // Меню добавления карточек
            if viewModel.showingAddCardMenu {
                AddCardMenuView(
                    onAddShortCard: {
                        viewModel.showAddShortCard()
                    },
                    onAddRegularCard: {
                        viewModel.showAddRegularCard()
                    },
                    onAddTestCard: {
                        viewModel.showAddTestCard()
                    }
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showingAddCardMenu)
            }
        }
        .onTapGesture {
            if viewModel.showingAddCardMenu {
                viewModel.hideAddCardMenu()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddShortCard) {
            ShortCardView(cardType: .short) { title, content, isBothSides in
                viewModel.addCard(type: .short, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddRegularCard) {
            ShortCardView(cardType: .regular) { title, content, isBothSides in
                viewModel.addCard(type: .regular, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddTestCard) {
            AddTestCardView { title, content, isBothSides in
                viewModel.addCard(type: .test, title: title, content: content, isBothSides: isBothSides)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingEditCardType) {
            if let editingCard = viewModel.editingCard {
                if editingCard.cardType == .test {
                    EditTestCardView(card: editingCard) { title, content, isBothSides in
                        viewModel.editCard(cardId: editingCard.id, type: editingCard.cardType, title: title, content: content, isBothSides: isBothSides)
                    }
                } else {
                    EditShortCardView(card: editingCard) { title, content, isBothSides in
                        viewModel.editCard(cardId: editingCard.id, type: editingCard.cardType, title: title, content: content, isBothSides: isBothSides)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingStudyCards) {
            StudyModeView(tasks: viewModel.tasks)
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


