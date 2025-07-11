import SwiftUI

// MARK: - CardView (Wrapper)

struct CardView: View {
    let task: ShortCardModel
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let isDeleting: Bool
    
    var body: some View {
        if task.cardType == .test {
            TestCardView(
                task: task,
                onToggle: onToggle,
                onDelete: onDelete,
                onEdit: onEdit,
                isDeleting: isDeleting
            )
        } else {
            RegularCardView(
                task: task,
                onToggle: onToggle,
                onDelete: onDelete,
                onEdit: onEdit,
                isDeleting: isDeleting
            )
        }
    }
}
