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
                    .font(.system(size: 16))
                    .foregroundColor(isBoldActive ? .white : .primary)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(isBoldActive ? Color.accentColor : Color(red: 0.184, green: 0.184, blue: 0.184))
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
            
            // Italic button
            Button(action: {
                toggleItalic()
            }) {
                Image(systemName: "italic")
                    .font(.system(size: 16))
                    .foregroundColor(isItalicActive ? .white : .primary)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(isItalicActive ? Color.accentColor : Color(red: 0.184, green: 0.184, blue: 0.184))
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
            
            // Underline button
            Button(action: {
                toggleUnderline()
            }) {
                Image(systemName: "underline")
                    .font(.system(size: 16))
                    .foregroundColor(isUnderlineActive ? .white : .primary)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(isUnderlineActive ? Color.accentColor : Color(red: 0.184, green: 0.184, blue: 0.184))
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
            
            // Strikethrough button
            Button(action: {
                toggleStrikethrough()
            }) {
                Image(systemName: "strikethrough")
                    .font(.system(size: 16))
                    .foregroundColor(isStrikethroughActive ? .white : .primary)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(isStrikethroughActive ? Color.accentColor : Color(red: 0.184, green: 0.184, blue: 0.184))
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
            
            // Header button
            Button(action: {
                toggleHeader()
            }) {
                Text("H")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isHeaderActive ? .white : .primary)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(isHeaderActive ? Color.accentColor : Color(red: 0.184, green: 0.184, blue: 0.184))
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
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
