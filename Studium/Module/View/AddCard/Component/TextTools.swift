import SwiftUI

struct TextTools: View {
    @Binding var selectedText: String
    @State private var isBoldActive = false
    @State private var isItalicActive = false
    @State private var isUnderlineActive = false
    @State private var isStrikethroughActive = false
    @State private var isHeaderActive = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Bold button
            Button(action: {
                toggleBold()
            }) {
                Image(systemName: "bold")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isBoldActive ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(isBoldActive ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(6)
            }
            
            // Italic button
            Button(action: {
                toggleItalic()
            }) {
                Image(systemName: "italic")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isItalicActive ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(isItalicActive ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(6)
            }
            
            // Underline button
            Button(action: {
                toggleUnderline()
            }) {
                Image(systemName: "underline")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isUnderlineActive ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(isUnderlineActive ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(6)
            }
            
            // Strikethrough button
            Button(action: {
                toggleStrikethrough()
            }) {
                Image(systemName: "strikethrough")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isStrikethroughActive ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(isStrikethroughActive ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(6)
            }
            
            // Header button
            Button(action: {
                toggleHeader()
            }) {
                Text("H")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isHeaderActive ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(isHeaderActive ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        // .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Formatting Functions
    
    private func toggleBold() {
        isBoldActive.toggle()
        if isBoldActive {
            selectedText = "**\(selectedText)**"
        } else {
            selectedText = selectedText.replacingOccurrences(of: "**", with: "")
        }
    }
    
    private func toggleItalic() {
        isItalicActive.toggle()
        if isItalicActive {
            selectedText = "*\(selectedText)*"
        } else {
            selectedText = selectedText.replacingOccurrences(of: "*", with: "")
        }
    }
    
    private func toggleUnderline() {
        isUnderlineActive.toggle()
        if isUnderlineActive {
            selectedText = "<u>\(selectedText)</u>"
        } else {
            selectedText = selectedText.replacingOccurrences(of: "<u>", with: "").replacingOccurrences(of: "</u>", with: "")
        }
    }
    
    private func toggleStrikethrough() {
        isStrikethroughActive.toggle()
        if isStrikethroughActive {
            selectedText = "~~\(selectedText)~~"
        } else {
            selectedText = selectedText.replacingOccurrences(of: "~~", with: "")
        }
    }
    
    private func toggleHeader() {
        isHeaderActive.toggle()
        if isHeaderActive {
            selectedText = "# \(selectedText)"
        } else {
            selectedText = selectedText.replacingOccurrences(of: "# ", with: "")
        }
    }
}

// MARK: - Preview
struct TextTools_Previews: PreviewProvider {
    static var previews: some View {
        TextTools(selectedText: .constant("Sample text"))
            .padding()
    }
}
