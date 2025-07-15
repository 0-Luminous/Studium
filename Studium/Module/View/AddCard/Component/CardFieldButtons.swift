import SwiftUI

struct CardFieldButtons: View {
    @Binding var text: String
    @State private var showingLinkAlert = false
    @State private var linkText = ""
    @State private var linkURL = ""
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                showingLinkAlert = true
            }) {
                Image(systemName: "link")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(Color(red: 0.184, green: 0.184, blue: 0.184))
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
            
            Button(action: {
                addAudio()
            }) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                    .padding(4)
                    .frame(width: 35, height: 35)
            }
            .background(
                Circle()
                    .fill(Color(red: 0.184, green: 0.184, blue: 0.184))
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
            
            Spacer()
        }
        .alert("Добавить ссылку", isPresented: $showingLinkAlert) {
            TextField("Текст ссылки", text: $linkText)
            TextField("URL", text: $linkURL)
            Button("Добавить") {
                addLink()
            }
            Button("Отмена", role: .cancel) {
                linkText = ""
                linkURL = ""
            }
        } message: {
            Text("Введите текст ссылки и URL")
        }
    }
    
    // MARK: - Helper Functions
    
    private func addLink() {
        guard !linkText.isEmpty && !linkURL.isEmpty else { return }
        
        let linkMarkdown = "[\(linkText)](\(linkURL))"
        
        if text.isEmpty {
            text = linkMarkdown
        } else {
            text = "\(text) \(linkMarkdown)"
        }
        
        // Очищаем поля после добавления
        linkText = ""
        linkURL = ""
    }
    
    private func addAudio() {
        let audioPlaceholder = "🔊 [Аудио]"
        
        if text.isEmpty {
            text = audioPlaceholder
        } else {
            text = "\(text) \(audioPlaceholder)"
        }
    }
}

// MARK: - Preview
struct CardFieldButtons_Previews: PreviewProvider {
    static var previews: some View {
        CardFieldButtons(text: .constant("Sample text"))
            .padding()
            .background(Color.graphite)
    }
}
