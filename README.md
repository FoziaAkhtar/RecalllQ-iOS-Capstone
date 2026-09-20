# RecalllQ-iOS-Capstone

## 🧠 AI-Powered Academic Memory Assistant for Students

> **"Recall Less. Learn More. Think Smarter."**

RecalllQ is an AI-powered academic memory assistant designed to help students capture, organize, transform, and recall learning materials through personalized academic memory systems.

The application combines **SwiftUI, AI-powered memory generation, local AI Study Chat, Ollama, Llama 3.2 3B, OCR, personalized study recommendations, Flashcards, Quizzes, secure authentication, Apple Sign In, Google Sign-In, Guest Mode, and user-specific data management** into one academic learning environment.

---

# 🚀 Reimagining How Students Learn

Modern students consume enormous amounts of information every semester:

* Lecture notes
* Assignments
* Study resources
* Class discussions
* Research materials
* Learning content

The challenge is no longer simply accessing information.

**The challenge is remembering and understanding it.**

RecalllQ is designed to create an intelligent academic memory layer that helps students transform learning materials into structured knowledge and reusable study resources.

Instead of manually managing every piece of information, RecalllQ helps students organize academic content and convert it into memories, flashcards, quizzes, personalized study recommendations, and AI-powered study conversations.

---

# ✨ Why RecalllQ Exists

Students can experience:

* Information overload
* Disorganized study materials
* Difficulty retrieving previous learning
* Inefficient study sessions
* Difficulty identifying what to review
* Cognitive overload

RecalllQ addresses these challenges through:

**Artificial Intelligence + Academic Memory + Personalized Learning**

---

# ⚡ Core Features

## 🧠 AI Memory Engine

RecalllQ transforms academic notes into structured memories.

Features include:

* AI-generated memory creation
* Structured summaries
* Intelligent tags
* Confidence scoring
* Importance scoring
* Source information
* User ownership
* Local processing fallback
* FastAPI AI integration

### AI Memory Workflow

```text
Student Note
     ↓
AIService
     ↓
FastAPI /api/memory
     ↓
AI-Generated Memory
     ↓
RecalllQ Memory
```

---

# 💬 AI Study Chat

RecalllQ includes an AI-powered Study Chat that allows students to ask academic questions and receive dynamically generated answers and explanations.

The feature is integrated directly into the RecalllQ SwiftUI application and communicates with the RecalllQ FastAPI backend.

The current implementation uses **Ollama with the Llama 3.2 3B model** to generate AI responses locally.

This allows the core AI Study Chat functionality to operate without requiring OpenAI API credits.

## AI Study Chat Features

* 💬 Academic question and answer chat
* 🧠 Dynamic AI-generated responses
* 📚 Student-friendly explanations
* 📖 Definitions
* 📝 Summaries
* 🃏 Flashcard assistance
* 📝 Quiz assistance
* 🎯 Study guidance
* 🔄 Conversation history
* 🏷 Response type detection
* 🔎 Topic detection
* 📊 Visualization metadata
* ⚡ Local AI processing
* 🚫 No OpenAI API credits required

## AI Study Chat Architecture

```text
RecalllQ iOS
      ↓
ChatView
      ↓
ChatViewModel
      ↓
FastAPI /api/chat
      ↓
Ollama
      ↓
Llama 3.2 3B
      ↓
AI-Generated Response
      ↓
RecalllQ AI Study Chat
```

## Local AI Architecture

The RecalllQ Study Chat uses Ollama to run the AI model locally.

```text
Student Question
       ↓
RecalllQ
       ↓
ChatViewModel
       ↓
FastAPI Backend
       ↓
Ollama
       ↓
Llama 3.2 3B
       ↓
Generated Response
       ↓
RecalllQ
```

The local AI architecture removes the requirement for OpenAI API credits for the Study Chat feature.

## Conversation History

RecalllQ supports conversation history for follow-up questions.

```text
Student Question
       ↓
AI Response
       ↓
Conversation History
       ↓
Follow-Up Question
       ↓
FastAPI /api/chat
       ↓
Ollama
       ↓
Context-Aware AI Response
```

## AI Study Chat Testing

The AI Study Chat was tested with multiple academic topics.

### Database Normalization

The system successfully generated a detailed explanation of database normalization for a college student.

### Photosynthesis

The system successfully generated a detailed explanation of photosynthesis in simple terms.

### Conversation History

Follow-up requests successfully sent previous conversation history to the backend.

Backend verification confirmed successful requests:

```text
POST /api/chat HTTP/1.1
200 OK
```

Ollama successfully generated responses using:

```text
llama3.2:3b
```

### AI Study Chat Status

**Completed and tested.** ✅

---

# 🔐 Authentication, Social Sign-In & Guest Mode

RecalllQ supports multiple authentication methods so students can securely access their academic learning environment.

## Authentication

Users can:

* Log in
* Register an account
* Maintain their current account session
* Log out
* Switch between accounts
* Access user-specific academic data

---

## 🍎 Sign in with Apple

RecalllQ supports **Sign in with Apple** using Apple's native authentication framework.

The Apple authentication flow is integrated with the RecalllQ account architecture and `AppState`.

Features include:

* Apple Sign-In authentication
* Authentication state management
* Account/session handling
* Authentication cancellation handling
* Authentication error handling
* User-specific data integration
* Logout/session management

### Apple Sign-In Flow

```text
Student
   ↓
Sign in with Apple
   ↓
Apple Authentication
   ↓
Authenticated User
   ↓
AppState
   ↓
User Session
   ↓
User-Specific Academic Data
```

---

## 🔵 Google Sign-In

RecalllQ supports **Google Sign-In** using Google's iOS authentication SDK.

Google authentication is configured using the RecalllQ iOS OAuth Client ID and the required reversed client ID URL scheme.

### Google OAuth Configuration

The configured iOS Client ID is:

```text
217697447867-bmushce04a9ovrp8da62dej1qo0titjj.apps.googleusercontent.com
```

The corresponding reversed URL scheme is:

```text
com.googleusercontent.apps.217697447867-bmushce04a9ovrp8da62dej1qo0titjj
```

The Google configuration is integrated into the RecalllQ target through the application's Information Property List.

### Google Sign-In Features

* Google Sign-In authentication
* Google iOS OAuth configuration
* OAuth client configuration
* Google callback URL scheme
* Authentication state management
* Account/session handling
* Authentication error handling
* User-specific data integration
* Logout/session management

### Google Sign-In Flow

```text
Student
   ↓
Google Sign-In
   ↓
Google Authentication
   ↓
Google OAuth Callback
   ↓
Authenticated User
   ↓
AppState
   ↓
User Session
   ↓
User-Specific Academic Data
```

---

## 👤 Guest Mode

Students can also access RecalllQ through **Guest Mode** without creating a registered account.

Guest Mode provides a simple way to explore and use the application while keeping registered-user data separate from authenticated account data.

---

## 🔐 Authentication Architecture

RecalllQ integrates multiple authentication options into the central application state.

```text
                    RecalllQ Authentication
                              │
              ┌───────────────┼───────────────┐
              ↓               ↓               ↓
       Email / Password   Sign in with     Google Sign-In
                              Apple
              │               │               │
              └───────────────┼───────────────┘
                              ↓
                         AppState
                              ↓
                    Current User Session
                              ↓
                    User-Specific Data
                              ↓
       ┌──────────┬───────────┼───────────┬───────────┐
       ↓          ↓           ↓           ↓           ↓
     Notes     Memories   Flashcards    Quizzes   Progress
```

Authentication is connected to `AppState` so the active user determines which account-specific academic information is displayed and persisted.

---

# 👤 User-Specific Data Isolation

RecalllQ separates academic data by user account.

Each user's information is stored and retrieved independently.

User-specific data includes:

* Notes
* Memories
* Flashcards
* Quizzes
* Study sessions
* Learning progress

This prevents information belonging to one student account from being displayed when another student is using the application.

## Account-Aware Storage

The application includes dedicated storage functionality for user-specific persistence.

Implemented services include:

```text
NotesStorageService.swift
QuizStorageService.swift
KeychainService.swift
```

User identifiers are normalized to provide consistent account-based storage.

### User Data Flow

```text
Authenticated User
        ↓
AppState.currentUserEmail
        ↓
User-Specific Storage
        ↓
Notes
Memories
Flashcards
Quizzes
Study Sessions
Progress
```

---

# 📚 Smart Learning Workspace

RecalllQ provides a centralized academic workspace where students can manage their learning content.

The current learning workflow includes:

* Notes
* Memories
* Flashcards
* Quizzes
* Study sessions
* Progress
* Study recommendations
* AI Study Chat

The application is designed to transform individual notes into multiple learning resources while also providing direct AI-powered study assistance.

---

# 📷 OCR Note Scanning

RecalllQ includes OCR-based academic note scanning using Apple's Vision framework.

Students can:

1. Scan academic material.
2. Extract text from the scanned content.
3. Create a RecalllQ note from the extracted text.
4. Continue through the normal Note → Memory workflow.

The OCR service is implemented through:

```text
OCRServices.swift
```

## OCR Workflow

```text
Academic Material
        ↓
Camera / Scan
        ↓
OCR Text Recognition
        ↓
RecalllQ Note
        ↓
AI Memory Generation
        ↓
Structured Memory
```

---

# 🧠 Memories

Memories are the core knowledge objects within RecalllQ.

A memory can contain:

* Summary
* Tags
* Confidence
* Importance
* Source
* User ownership

Memories provide the foundation for additional learning features such as Flashcards and Quizzes.

---

# 🃏 Flashcards

RecalllQ allows students to create Flashcards from academic memories.

The learning flow is:

```text
Note
 ↓
Memory
 ↓
Flashcard
```

Flashcards provide an additional way for students to review and reinforce academic knowledge.

Flashcards are also associated with the appropriate user account through the application's user-specific data architecture.

---

# 📝 Quiz System

RecalllQ includes an integrated quiz system for active learning and knowledge reinforcement.

Implemented functionality includes:

* Quiz generation
* Memory-based quiz questions
* Multiple-choice questions
* Answer selection
* Answer submission
* Correct/incorrect result display
* Score calculation
* Next-question progression
* Quiz completion
* Quiz persistence
* User-specific quiz storage

## Quiz Learning Flow

```text
Memory
      ↓
Quiz Generation
      ↓
Quiz Questions
      ↓
Student Answers
      ↓
Score
      ↓
Study Progress
```

The quiz system is designed to help students actively recall information instead of only reading their notes.

---

# 🎯 Personalized Study Recommendations

RecalllQ includes a personalized study recommendation system.

Five recommendation categories were implemented to help students determine what to study next.

Recommendations can encourage students to:

* Review important memories
* Focus on weaker learning areas
* Continue unfinished activities
* Practice using Flashcards
* Reinforce knowledge through Quizzes

## Recommendation Flow

```text
Student Learning Data
        ↓
RecalllQ Analysis
        ↓
Study Recommendations
        ↓
Personalized Learning Actions
```

---

# 🔑 Secure Keychain Support

RecalllQ includes `KeychainService.swift` to provide secure storage support for sensitive information.

The Keychain service improves the application's security architecture by providing a secure mechanism for storing sensitive information rather than relying only on standard application preferences.

Security-related functionality includes:

* Keychain storage
* Secure authentication support
* User session management
* User-specific data isolation
* Account-aware persistence
* OAuth authentication support

---

# 🏗 Application Architecture

RecalllQ uses `AppState` as the central source of truth for application-wide state.

The application architecture supports:

* Authentication state
* Apple Sign In
* Google Sign-In
* Guest state
* Current user
* Account switching
* User-specific data
* Notes
* Memories
* Flashcards
* Quizzes
* Study sessions
* Learning progress
* AI services
* AI Study Chat
* OCR services
* Study recommendations

## Architecture

```text
SwiftUI Views
      ↓
AppState / ViewModels
      ↓
Services
      ↓
 ┌───────────────┬────────────────┬────────────────┐
 ↓               ↓                ↓
AI Services   OCR Services    Storage Services
 ↓               ↓                ↓
AI Memory      OCR Notes       User Data
Generation     Processing       Persistence
 ↓
AI Study Chat
 ↓
FastAPI
 ↓
Ollama
 ↓
Llama 3.2 3B
      └───────────────┬────────────────┘
                      ↓
              RecalllQ Learning System
```

---

# 🔄 Current Learning Flow

```text
                 ┌─────────────────┐
                 │   Student/User  │
                 └────────┬────────┘
                          ↓
              ┌────────────────────────┐
              │ Login / Apple / Google │
              │     / Guest Mode       │
              └───────────┬────────────┘
                          ↓
                    ┌───────────┐
                    │   Notes   │
                    └─────┬─────┘
                          ↓
                  ┌───────────────┐
                  │ AI Memory     │
                  │ Generation    │
                  └───────┬───────┘
                          ↓
                    ┌───────────┐
                    │  Memories │
                    └─────┬─────┘
                          ↓
              ┌───────────┴───────────┐
              ↓                       ↓
        ┌────────────┐          ┌────────────┐
        │ Flashcards │          │    Quiz    │
        └─────┬──────┘          └──────┬─────┘
              │                        │
              └───────────┬────────────┘
                          ↓
                 ┌─────────────────┐
                 │ Study Progress  │
                 └────────┬────────┘
                          ↓
                ┌──────────────────┐
                │ Recommendations  │
                └──────────────────┘

                 ┌──────────────────┐
                 │   AI Study Chat  │
                 └────────┬─────────┘
                          ↓
                       Ollama
                          ↓
                    Llama 3.2 3B
```

---

# 🧭 Application Navigation

The current application provides access to the major learning areas through the main RecalllQ interface.

```text
Welcome
   ↓
Login / Register / Apple / Google / Guest Mode
   ↓
Dashboard
   │
   ├── Notes
   │     ├── Add Note
   │     ├── Edit Note
   │     ├── OCR Scan
   │     └── Generate Memory
   │
   ├── Memories
   │
   ├── Flashcards
   │
   ├── Quiz
   │
   ├── AI Chat
   │
   └── Settings
```

---

# 🗂 Current Project Structure

```text
RecalllQ
│
├── Models
│   ├── Note.swift
│   ├── Memory.swift
│   ├── Flashcard.swift
│   ├── Quiz.swift
│   ├── QuizQuestion.swift
│   └── StudySession.swift
│
├── ViewModels
│   ├── NotesViewModel.swift
│   ├── MemoryViewModel.swift
│   ├── FlashcardViewModel.swift
│   ├── QuizViewModel.swift
│   └── DashboardViewModel.swift
│
├── Views
│   ├── Welcome
│   ├── Dashboard
│   ├── Notes
│   ├── Memories
│   ├── Flashcards
│   ├── Quiz
│   ├── Chat
│   ├── Settings
│   └── Components
│
├── Services
│   ├── AIService.swift
│   ├── OCRServices.swift
│   ├── NotesStorageService.swift
│   ├── QuizStorageService.swift
│   └── PersistenceService.swift
│
├── AI
│   └── MemoryEngine.swift
│
├── Chat
│   ├── ChatMessage.swift
│   ├── ChatViewModel.swift
│   └── ChatView.swift
│
├── KeychainService.swift
│
├── AppState
│
└── RecalllQApp.swift
```

---

# 🛠 Technology Stack

## Frontend

* Swift
* SwiftUI
* Xcode

## Authentication

* Sign in with Apple
* Google Sign-In
* iOS Authentication Services
* Google iOS OAuth
* Guest Mode
* Account/session management

## Artificial Intelligence

RecalllQ uses AI throughout the academic learning workflow.

Implemented AI functionality includes:

* AI-powered memory generation
* AI Study Chat
* FastAPI backend integration
* `/api/memory` endpoint
* `/api/chat` endpoint
* Structured AI responses
* Ollama local AI processing
* Llama 3.2 3B model
* Conversation history
* Topic detection
* Response type detection
* Personalized study recommendations

### AI Architecture

```text
RecalllQ iOS
      │
      ├── AI Memory Generation
      │       ↓
      │   FastAPI /api/memory
      │
      └── AI Study Chat
              ↓
          FastAPI /api/chat
              ↓
            Ollama
              ↓
         Llama 3.2 3B
```

## Computer Vision

* Apple Vision framework
* OCR-based note scanning

## Security

* Apple Keychain services
* `KeychainService.swift`
* User-specific data isolation
* Account-aware persistence
* Secure authentication support
* OAuth authentication configuration

## Development & Version Control

* Xcode
* Swift
* Git
* GitHub
* FastAPI
* Python
* Ollama

---

# 🧪 Testing & Verification

The completed application was tested through the primary RecalllQ workflows.

## Authentication Testing

Testing included:

* Guest access
* Email/password login
* Account registration
* Account switching
* Logout
* Sign in with Apple
* Google Sign-In
* Authentication state management
* Authentication callback handling
* Authentication cancellation handling
* Authentication error handling
* User-specific account access

## Learning System Testing

Testing also included:

* User-specific notes
* Memory generation
* AI memory integration
* OCR note scanning
* Flashcard creation
* Quiz generation
* Quiz answering
* Quiz scoring
* Quiz progression
* Study recommendations
* Persistent data storage

## AI Study Chat Testing

The AI Study Chat was independently tested through the FastAPI backend and the RecalllQ application.

Tested academic questions included:

```text
What is database normalization?
Explain it in simple terms for a college student.
```

and:

```text
Explain how photosynthesis works in simple terms.
```

The backend successfully generated dynamic AI responses.

### Backend Verification

```text
POST /api/chat HTTP/1.1
200 OK
```

### Ollama Verification

```text
Model: llama3.2:3b
🧠 OLLAMA RESPONSE GENERATED
```

### Conversation History Verification

Follow-up requests successfully included previous conversation history:

```text
Conversation history messages: 1
```

The local AI Study Chat was confirmed to communicate successfully between the iOS application, FastAPI backend, Ollama, and Llama 3.2 3B.

## Google Sign-In Configuration Testing

Google Sign-In configuration was verified using:

```text
GIDClientID:
217697447867-bmushce04a9ovrp8da62dej1qo0titjj.apps.googleusercontent.com
```

Google callback URL scheme:

```text
com.googleusercontent.apps.217697447867-bmushce04a9ovrp8da62dej1qo0titjj
```

## Apple Sign-In Testing

Apple Sign-In functionality was tested as part of the RecalllQ authentication workflow.

Testing included:

* Authentication launch
* Successful authentication
* Authentication cancellation
* Authentication error handling
* Session management
* Logout
* User-specific account integration

The project structure was also reviewed and cleaned before the final milestone commit.

---

# 🧹 Final Project Cleanup

The project received a final structural cleanup.

Completed cleanup included:

* Removed unused `EditNoteViewswift`.
* Corrected the OCR service filename:

```text
0CRServices.swift
        ↓
OCRServices.swift
```

* Corrected the AI folder name that contained an accidental trailing space.
* Reviewed the project for stray or incorrectly named files.
* Improved service organization.
* Verified the final project structure.
* Confirmed the working tree was clean before the final push.

---

# 📌 Version 1.2

## Authentication, User Isolation & Study Recommendations

Version 1.2 represents a major expansion of RecalllQ.

The application includes:

* Guest Mode
* Authentication
* Account switching
* User-specific data isolation
* Persistent storage
* AI Memory Generation
* FastAPI integration
* Local AI fallback
* OCR note scanning
* Flashcards
* Quiz generation and scoring
* Study recommendations
* Keychain support
* Improved project organization

---

# 📌 Version 1.3

## 🍎 Apple Sign In, 🔵 Google Sign-In & Authentication Enhancement

Version 1.3 expands RecalllQ's authentication system with additional authentication providers and improved account integration.

### Added

* 🍎 Sign in with Apple
* 🔵 Google Sign-In
* 🔐 Multi-provider authentication architecture
* 🔑 Google iOS OAuth Client configuration
* 🔗 Google reversed client ID URL scheme
* 👤 Authentication integration with `AppState`
* 🔒 User-specific authentication and data isolation
* 🚪 Authentication session and logout handling
* 🧪 Authentication testing and verification
* 👥 Improved account/session management

### Authentication Flow

```text
Student
   ↓
RecalllQ Authentication
   │
   ├── Email / Password
   │
   ├── Sign in with Apple
   │
   ├── Google Sign-In
   │
   └── Guest Mode
          ↓
      AppState
          ↓
   Current User Session
          ↓
   User-Specific Data
          ↓
 Notes / Memories / Flashcards / Quizzes / Progress
```

The authentication architecture provides students with multiple access options while maintaining separation of user-specific academic information.

---

# 📌 Version 1.4

## 💬 AI Study Chat & Local AI Integration

Version 1.4 introduces the completed RecalllQ AI Study Chat feature and local AI processing architecture.

### Added

* 💬 AI Study Chat
* 🧠 Dynamic AI-generated academic responses
* 🦙 Ollama local AI integration
* 🤖 Llama 3.2 3B model
* 🔗 FastAPI `/api/chat` endpoint
* 🔄 Conversation history
* 📚 Academic explanations
* 📖 Definitions
* 📝 Summaries
* 🃏 Flashcard assistance
* 📝 Quiz assistance
* 🎯 Study guidance
* 🏷 Response type detection
* 🔎 Topic detection
* 📊 Visualization metadata
* 🚫 No OpenAI API credits required

### AI Study Chat Flow

```text
Student
   ↓
RecalllQ AI Chat
   ↓
ChatViewModel
   ↓
FastAPI /api/chat
   ↓
Ollama
   ↓
Llama 3.2 3B
   ↓
AI Response
   ↓
RecalllQ
```

### Testing

The AI Study Chat was tested with different academic questions, including:

* Database normalization
* Photosynthesis
* Follow-up questions using conversation history

The backend successfully returned:

```text
HTTP 200 OK
```

and Ollama successfully generated responses using:

```text
llama3.2:3b
```

### Status

**Completed and tested.** ✅

The core AI Study Chat feature is integrated into RecalllQ and the latest changes have been pushed to the GitHub `main` branch.

---

# 📦 Git Version Control

The RecalllQ project is maintained using Git and GitHub.

The project uses the `main` branch for the current application version.

## Repository

**GitHub:** `FoziaAkhtar/RecalllQ-iOS-Capstone`

## Current Git Status

The latest changes have been committed and pushed to GitHub.

The working tree has been verified as clean:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

The local project and GitHub repository are synchronized.

---

# 🎯 Project Objectives

The objectives of RecalllQ are to:

* Improve knowledge retention
* Reduce study friction
* Increase academic productivity
* Organize academic information
* Create personalized learning experiences
* Use AI to transform academic content into structured knowledge
* Support active learning through Flashcards and Quizzes
* Provide AI-powered academic study assistance
* Help students identify what they should study next
* Provide secure and flexible authentication
* Keep student academic information separated by account

---

# 🔮 Future Roadmap

The following features represent potential future development beyond the current implementation.

## Phase 1 — Academic Intelligence

* Advanced academic note management
* Enhanced AI memory generation
* Improved recall systems
* Expanded personalized recommendations

## Phase 2 — Advanced Learning

* Voice lecture processing
* Advanced AI Study Chat capabilities
* Advanced Flashcards
* Enhanced academic search
* More intelligent study planning

## Phase 3 — Intelligent Learning Platform

* Adaptive learning models
* Cross-platform synchronization
* Collaborative learning spaces
* Advanced predictive academic support

---

# 🌍 Target Audience

RecalllQ is designed for:

* College students
* University students
* Online learners
* Independent learners
* Lifelong learners
* Academic users

---

# 🌟 Long-Term Vision

RecalllQ aims to create an intelligent academic memory system that helps students spend:

**Less time searching.**

**Less time organizing.**

**More time understanding.**

**More time learning.**

The long-term vision is to create an AI-powered academic companion that learns with students, grows with students, and helps them remember what matters most.

---

# 👩‍💻 Developed By

**Fozia Akhtar**

## Capstone Project

**iOS Development**

## Instructor

**Doug Jasper**

---

# 🧠 RecalllQ

> **Recall Less. Learn More. Think Smarter.**

RecalllQ transforms academic information into structured knowledge, reusable study resources, AI-powered study assistance, and personalized learning experiences.

**AI + Memory + Learning + Personalization**

---

## 📱 Project Highlights

RecalllQ combines:

```text
                    ┌──────────────────────┐
                    │      RecalllQ        │
                    │ AI Academic Memory   │
                    │      Assistant       │
                    └──────────┬───────────┘
                               │
       ┌───────────────────────┼───────────────────────┐
       ↓                       ↓                       ↓
 Authentication          AI Learning              Academic Tools
       │                       │                       │
 ┌─────┼─────┐          ┌──────┼──────┐        ┌──────┼──────┐
 ↓     ↓     ↓          ↓      ↓      ↓        ↓      ↓      ↓
Apple Google Email     Memory  OCR  Recommend Notes Flash Quiz
 ↓     ↓     ↓          │      │      │
 └─────┼─────┘          └──────┼──────┘
       ↓                       ↓
    AppState              Learning System
       │                       │
       └───────────┬───────────┘
                   ↓
          User-Specific Academic
                 Experience
                   │
                   ↓
             AI Study Chat
                   │
                   ↓
                Ollama
                   │
                   ↓
            Llama 3.2 3B
```

**Recall Less. Learn More. Think Smarter.**
