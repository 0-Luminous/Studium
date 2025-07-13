import SwiftUI

// MARK: - AddCardNavigationBar

struct AddCardNavigationBar: View {
    let onCancel: () -> Void
    let onCreate: () -> Void
    let isCreateEnabled: Bool
    let createButtonColor: Color
    
    var body: some View {
        HStack {
            cancelButton
            
            Spacer()
            
            createButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Cancel Button
    
    private var cancelButton: some View {
        Button(action: onCancel) {
            Text("Отмена")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Create Button
    
    private var createButton: some View {
        Button(action: onCreate) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .medium))

                Text("Создать")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(createButtonBackground)
            .shadow(
                color: isCreateEnabled ? createButtonColor.opacity(0.4) : .clear,
                radius: 6,
                x: 0,
                y: 2
            )
        }
        .disabled(!isCreateEnabled)
        .scaleEffect(isCreateEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isCreateEnabled)
    }
    
    // MARK: - Helper Views
    
    private var createButtonBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                isCreateEnabled
                    ? LinearGradient(
                        gradient: Gradient(colors: [createButtonColor, createButtonColor.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
    }
}

// MARK: - Preview

#Preview {
    AddCardNavigationBar(
        onCancel: { print("Cancel") },
        onCreate: { print("Create") },
        isCreateEnabled: true,
        createButtonColor: .blue
    )
    .background(Color.graphite)
} 