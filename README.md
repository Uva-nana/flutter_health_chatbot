# Health Chatbot - AI Powered Health & Nutrition Assistant

A Flutter application that provides personalized health and nutrition guidance using AI. Users can ask health questions, get meal recommendations, and analyze food menus based on their dietary needs.

## Features

- AI-powered health and nutrition chatbot
- Real-time responses using Groq AI (LLaMA 3.3)
- Food menu analysis — paste any menu and get healthy meal suggestions
- Supports dietary conditions like diabetes, high blood pressure, allergies
- Clean and intuitive chat UI
- Cross-platform — Web, Android, iOS

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| AI | Groq API (LLaMA 3.3 70B) |
| State Management | setState |
| HTTP | http package |
| Environment | flutter_dotenv |

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/
│   └── message.dart           # Message data model
├── screens/
│   └── chat_screen.dart       # Main chat UI screen
├── services/
│   └── gemini_service.dart    # Groq AI API integration
└── widgets/
    └── message_bubble.dart    # Chat bubble widget
```

## Getting Started

### Prerequisites
- Flutter SDK
- Groq API key (free at console.groq.com)

### Setup

1. Clone the repository
```bash
git clone https://github.com/Uva-nana/flutter_health_chatbot.git
cd flutter_health_chatbot
```

2. Install dependencies
```bash
flutter pub get
```

3. Create a `.env` file in the root folder
```
GEMINI_API_KEY=your_groq_api_key_here
```

4. Run the app
```bash
flutter run -d chrome
```

## How It Works

```
User types question
      ↓
Flutter app sends it to Groq AI API
      ↓
LLaMA 3.3 model generates health response
      ↓
Answer displayed in chat
```

## Screenshots

Coming soon.

## Future Features

- Health profile (save your conditions and goals)
- Daily meal tracker
- Indian food calorie calculator
- Local restaurant menu analysis
- Tamil/regional language support

## Author

Developed by Yuva Rani
