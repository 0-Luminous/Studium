import SwiftUI

struct DockBar: View {
    let hasCards: Bool
    let onStudyCards: () -> Void
    let onAddCard: () -> Void

    var body: some View {
        ZStack {
            // Кнопка "Учить карточки" по центру
            if hasCards {
                HStack {
                    Spacer()
                    
                    Button(action: onStudyCards) {
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
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.accentColor)
                        ) 
                    }
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                }
            }
            
            // Кнопка добавления справа и выше по Z-стеку
            HStack {
                Spacer()
                
                Button(action: onAddCard) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.gray.opacity(0.8))
                        .clipShape(Circle())
                }
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
