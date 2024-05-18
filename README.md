# Riya Chat Application

Riya is a simple SwiftUI-based chat application that allows users to send messages and images, and receive responses from an AI chatbot. This project demonstrates the use of SwiftUI, image uploading, and integrating with OpenAI's GPT-4 API for generating chatbot responses.

![Riya Chat Application](https://drive.google.com/uc?export=view&id=1xZuK9er1B4D7zhNM4HdFnxFufUZYyCfK)

## Features

- Send and receive text messages.
- Upload and send images.
- Receive AI-generated responses using OpenAI's GPT-4 API.
- Typing indicator to show when the bot is responding.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/riya-chat-app.git
    cd riya-chat-app
    ```

2. Open the project in Xcode:

    ```bash
    open Riya.xcodeproj
    ```

3. Add your OpenAI API key:
   - Open `ContentView.swift`.
   - Replace `"YOUR_OPENAI_API_KEY"` with your actual OpenAI API key.

    ```swift
    request.setValue("Bearer YOUR_OPENAI_API_KEY", forHTTPHeaderField: "Authorization")
    ```

4. Build and run the project on your simulator or device.

## Usage

1. Type a message in the input field and press "Send".
2. To send an image, click the paperclip icon, select an image, and press "Send".
3. The bot will respond to your messages using the GPT-4 API.

## Project Structure

- `ContentView.swift`: Main view of the chat application.
- `MessageView.swift`: Custom view for displaying messages.
- `TypingIndicatorView.swift`: View for displaying the typing indicator.
- `ImagePicker.swift`: Utility for picking images from the photo library.
- `Models.swift`: Data models for messages and API requests.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- [OpenAI](https://openai.com/) for the GPT-4 API.
- SwiftUI and iOS development resources.

---

Feel free to reach out if you have any questions or need further assistance.

---

![Riya Chat Application](https://drive.google.com/uc?export=view&id=1xZuK9er1B4D7zhNM4HdFnxFufUZYyCfK)
