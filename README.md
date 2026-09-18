# 🧠 RecalllQ-iOS-Capstone

## AI-Powered Academic Memory Assistant for Students

> **"Recall Less. Learn More. Think Smarter."**

RecalllQ is an AI-powered academic memory assistant designed to help students capture, organize, transform, and recall learning materials through personalized academic memory systems.

The application combines **SwiftUI, AI-powered memory generation, OCR, personalized study recommendations, Flashcards, Quizzes, authentication, and user-specific data management** into one academic learning environment.

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

Instead of manually managing every piece of information, RecalllQ helps students organize academic content and convert it into memories, flashcards, quizzes, and personalized study recommendations.

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
* Local processing fallback
* FastAPI AI integration

The AI memory workflow is:

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

# 🔐 Authentication & Guest Mode

RecalllQ supports multiple ways for students to access the application.

### Authentication

Users can:

* Log in
* Maintain their current account
* Log out
* Switch between accounts

### Guest Mode

Students can also access RecalllQ through **Guest Mode** without creating a registered account.

This provides a simple way to explore and use the application.

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

### Account-Aware Storage

The application includes dedicated storage functionality for user-specific persistence.

Implemented services include:

```text
NotesStorageService.swift
QuizStorageService.swift
KeychainService.swift
```

User identifiers are normalized to provide consistent account-based storage.

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

The application is designed to transform individual notes into multiple learning resources.

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

### OCR Workflow

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

### Quiz Learning Flow

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

### Recommendation Flow

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

---

# 🏗 Application Architecture

RecalllQ uses `AppState` as the central source of truth for application-wide state.

The application architecture supports:

* Authentication state
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
* OCR services
* Study recommendations

### Architecture

```text
SwiftUI Views
      ↓
AppState / ViewModels
      ↓
Services
      ↓
 ┌───────────────┬────────────────┬───────────────┐
 ↓               ↓                ↓
AI Services   OCR Services    Storage Services
 ↓               ↓                ↓
AI Memory      OCR Notes       User Data
Generation     Processing       Persistence
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
              ┌───────────────────────┐
              │ Login / Guest Mode    │
              └───────────┬───────────┘
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
```

---

# 🧭 Application Navigation

The current application provides access to the major learning areas through the main RecalllQ interface.

```text
Welcome
   ↓
Login / Register / Guest Mode
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

## Artificial Intelligence

* AI-powered memory generation
* FastAPI backend
* `/api/memory` endpoint
* Structured AI responses
* Local AI processing fallback
* Personalized study recommendations

## Computer Vision

* Apple Vision framework
* OCR-based note scanning

## Security

* Apple Keychain services
* User-specific data isolation
* Account-aware persistence

## Development & Version Control

* Xcode
* Git
* GitHub

---

# 🧪 Testing & Verification

The completed application was tested through the primary RecalllQ workflows.

Testing included:

* Guest access
* User login
* Account switching
* Logout
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

The application now includes:

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

# 📦 Final Git Commit

```text
Commit:
abbd2ef

Message:
Complete authentication, user isolation, recommendations, and final cleanup
```

The completed milestone was successfully committed and pushed to GitHub.

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
* Help students identify what they should study next

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
* AI Study Assistant
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

### Capstone Project

**iOS Development**

### Instructor

**Doug Jasper**

---

# 🧠 RecalllQ

> **Recall Less. Learn More. Think Smarter.**

RecalllQ transforms academic information into structured knowledge, reusable study resources, and personalized learning experiences.

**AI + Memory + Learning + Personalization**
