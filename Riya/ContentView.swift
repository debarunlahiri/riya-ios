//
//  ContentView.swift
//  Riya
//
//  Created by Debarun Lahiri on 18/05/24.
//

import SwiftUI

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var imageUrl: String? = nil

    var body: some View {
        VStack {
            // Header with cursive text "Riya"
            Text("Riya")
                .font(.custom("HelveticaNeue-Italic", size: 36))
                .foregroundColor(.black)
                .padding(.top, 16)

            List {
                ForEach(messages, id: \.id) { message in
                    MessageView(message: message)
                }
                if isTyping {
                    TypingIndicatorView()
                }
            }
            .background(Color.white)

            HStack {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Image(systemName: "paperclip")
                        .padding()
                        .foregroundColor(.black)
                }
                .sheet(isPresented: $showImagePicker, onDismiss: uploadImage) {
                    ImagePicker(selectedImage: $selectedImage)
                }

                TextField("Type a message", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)

                Button(action: sendMessage) {
                    Text("Send")
                }
                .padding()
                .foregroundColor(.black)
            }
            .background(Color.white)
            .padding(.bottom, 16)
        }
        .background(Color.white)
    }

    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let userMessage = Message(role: "user", content: inputText)
        messages.append(userMessage)
        inputText = ""
        fetchResponse(message: userMessage.content, imageUrl: imageUrl)
    }

    func fetchResponse(message: String, imageUrl: String?) {
        isTyping = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer OPEN_API_KEY", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var content = message
            if let imageUrl = imageUrl {
                content += "\nImage URL: \(imageUrl)"
            }

            let chatRequest = ChatRequest(
                model: "gpt-4",
                messages: [Message(role: "user", content: content)]
            )

            do {
                let requestBody = try JSONEncoder().encode(chatRequest)
                request.httpBody = requestBody
            } catch {
                print("Failed to encode request: \(error)")
                isTyping = false
                return
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        isTyping = false
                    }
                    return
                }

                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async {
                        isTyping = false
                    }
                    return
                }

                do {
                    let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                    if let reply = chatResponse.choices.first?.message.content {
                        DispatchQueue.main.async {
                            let botMessage = Message(role: "bot", content: reply)
                            messages.append(botMessage)
                            isTyping = false
                        }
                    }
                } catch {
                    print("Failed to decode response: \(error)")
                    DispatchQueue.main.async {
                        isTyping = false
                    }
                }
            }

            task.resume()
        }
    }

    func uploadImage() {
        guard let selectedImage = selectedImage else { return }

        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "https://your-image-upload-api.com/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add image data
        let filename = "image.jpg"
        let mimeType = "image/jpeg"
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)
        }

        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = data

        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }

            guard let data = data else {
                print("No data received from image upload")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let url = json["url"] as? String {
                    DispatchQueue.main.async {
                        self.imageUrl = url
                    }
                }
            } catch {
                print("Failed to parse image upload response: \(error)")
            }
        }

        task.resume()
    }
}

struct MessageView: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                Spacer()
            }
        }
    }
}

struct TypingIndicatorView: View {
    @State private var dots = "..."

    var body: some View {
        HStack {
            Text("Bot is typing")
            Text(dots)
                .onAppear {
                    startAnimation()
                }
        }
        .padding()
    }

    func startAnimation() {
        var i = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if i < 3 {
                dots = String(repeating: ".", count: i + 1)
                i += 1
            } else {
                i = 0
                dots = "."
            }
        }
    }
}

struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
}

struct Message: Codable, Identifiable {
    let id = UUID()
    let role: String
    let content: String
}

struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onDismiss: (() -> Void)?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.onDismiss?()
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onDismiss?()
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ContentView()
}

