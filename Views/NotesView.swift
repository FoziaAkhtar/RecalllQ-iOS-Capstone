
import SwiftUI
import VisionKit

// =====================================================
// VIEW: NotesView
// =====================================================
// PURPOSE:
// Main study notes screen for RecalllQ.
//
// DESIGN:
// 🔵 Blue   = Learning / Primary Actions
// 🟠 Orange = Focus / Reminders / Scanning
// 🟣 Purple = Smart / OCR Features
// 🟢 Green  = Success / Processing
//
// FEATURES:
// - Search notes
// - Create notes manually
// - Set study reminders
// - Scan study material
// - OCR text extraction
// - Automatic Memory creation
// - Pin notes
// - Delete notes
// - Undo delete
// - Safe scanner availability handling
// =====================================================

struct NotesView: View {

    // =====================================================
    // GLOBAL APP STATE
    // =====================================================

    @EnvironmentObject var appState: AppState

    // =====================================================
    // MANUAL NOTE INPUT
    // =====================================================

    @State private var title = ""
    @State private var content = ""

    // =====================================================
    // KEYBOARD
    // =====================================================

    @FocusState private var isInputFocused: Bool

    // =====================================================
    // REMINDER
    // =====================================================

    @State private var addReminder = false

    @State private var reminderDate =
        Calendar.current.date(
            byAdding: .minute,
            value: 5,
            to: Date()
        ) ?? Date()

    // =====================================================
    // DELETE / UNDO
    // =====================================================

    @State private var showUndo = false

    // =====================================================
    // SCANNER
    // =====================================================

    @State private var showScanner = false

    // =====================================================
    // OCR
    // =====================================================

    @State private var isProcessingScan = false

    // =====================================================
    // SCANNED TEXT
    // =====================================================

    @State private var scannedText = ""

    // =====================================================
    // OCR REVIEW
    // =====================================================

    @State private var showScanReview = false

    // =====================================================
    // SCANNER ALERT
    // =====================================================

    @State private var showScannerUnavailable = false

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        VStack(spacing: 0) {

            // =================================================
            // SEARCH BAR
            // =================================================

            HStack(spacing: 10) {

                Image(systemName: "magnifyingglass")
                    .foregroundColor(
                        RecalllQTheme.primary
                    )

                TextField(
                    "Search your study notes...",
                    text: $appState.notesViewModel.searchText
                )

                if !appState
                    .notesViewModel
                    .searchText
                    .isEmpty {

                    Button {

                        appState
                            .notesViewModel
                            .searchText = ""

                    } label: {

                        Image(
                            systemName: "xmark.circle.fill"
                        )
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .fill(
                    RecalllQTheme.blueBackground
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        RecalllQTheme.mediumRadius
                )
                .stroke(
                    RecalllQTheme.primary.opacity(0.15),
                    lineWidth: 1
                )
            )
            .padding(.horizontal)
            .padding(.top, 10)

            // =================================================
            // MAIN CONTENT
            // =================================================

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 18
                ) {

                    // =============================================
                    // CREATE NOTE SECTION
                    // =============================================

                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        HStack {

                            ZStack {

                                Circle()
                                    .fill(
                                        RecalllQTheme.primary
                                            .opacity(0.12)
                                    )
                                    .frame(
                                        width: 42,
                                        height: 42
                                    )

                                Image(
                                    systemName:
                                        "note.text.badge.plus"
                                )
                                .foregroundColor(
                                    RecalllQTheme.primary
                                )
                                .font(.title3)
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {

                                Text("Create Study Note")
                                    .font(.headline)

                                Text(
                                    "Capture something you want to remember"
                                )
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                            }

                            Spacer()
                        }

                        // =========================================
                        // TITLE
                        // =========================================

                        TextField(
                            "Note title",
                            text: $title
                        )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.smallRadius
                            )
                            .fill(
                                RecalllQTheme.pageBackground
                            )
                        )
                        .focused(
                            $isInputFocused
                        )

                        // =========================================
                        // CONTENT
                        // =========================================

                        TextField(
                            "What did you learn?",
                            text: $content,
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.smallRadius
                            )
                            .fill(
                                RecalllQTheme.pageBackground
                            )
                        )
                        .focused(
                            $isInputFocused
                        )

                        // =========================================
                        // REMINDER
                        // =========================================

                        VStack(
                            alignment: .leading,
                            spacing: 10
                        ) {

                            Toggle(
                                isOn: $addReminder
                            ) {

                                HStack(spacing: 10) {

                                    Image(
                                        systemName:
                                            "bell.fill"
                                    )
                                    .foregroundColor(
                                        RecalllQTheme.secondary
                                    )

                                    VStack(
                                        alignment: .leading,
                                        spacing: 2
                                    ) {

                                        Text(
                                            "Set Study Reminder"
                                        )
                                        .font(.subheadline)
                                        .bold()

                                        Text(
                                            "Review this note later"
                                        )
                                        .font(.caption)
                                        .foregroundColor(
                                            RecalllQTheme.secondaryText
                                        )
                                    }
                                }
                            }
                            .tint(
                                RecalllQTheme.secondary
                            )

                            if addReminder {

                                DatePicker(
                                    "Review at",
                                    selection:
                                        $reminderDate,
                                    in: Date()...,
                                    displayedComponents: [
                                        .date,
                                        .hourAndMinute
                                    ]
                                )
                                .font(.subheadline)
                                .padding(
                                    .horizontal,
                                    8
                                )
                                .padding(
                                    .vertical,
                                    6
                                )
                                .background(
                                    RoundedRectangle(
                                        cornerRadius:
                                            RecalllQTheme.smallRadius
                                    )
                                    .fill(
                                        RecalllQTheme.orangeBackground
                                    )
                                )
                            }
                        }
                        .padding(
                            .vertical,
                            4
                        )

                        // =========================================
                        // ADD NOTE BUTTON
                        // =========================================

                        Button {

                            addManualNote()

                        } label: {

                            HStack {

                                Image(
                                    systemName:
                                        "plus.circle.fill"
                                )

                                Text("Add Note")
                                    .font(.headline)

                                Spacer()

                                Image(
                                    systemName:
                                        "arrow.right"
                                )
                            }
                            .padding()
                            .frame(
                                maxWidth: .infinity
                            )
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(
                                    cornerRadius:
                                        RecalllQTheme.buttonRadius
                                )
                                .fill(
                                    RecalllQTheme.primaryButton
                                )
                            )
                        }
                        .disabled(
                            title
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty &&
                            content
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty
                        )
                        .opacity(
                            title
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty &&
                            content
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty
                            ? 0.55
                            : 1.0
                        )
                    }
                    .padding(
                        RecalllQTheme.largePadding
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius:
                                RecalllQTheme.largeRadius
                        )
                        .fill(
                            RecalllQTheme.cardBackground
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(
                            RecalllQTheme.shadowOpacity
                        ),
                        radius:
                            RecalllQTheme.shadowRadius,
                        x: 0,
                        y: RecalllQTheme.shadowY
                    )

                    // =============================================
                    // SCAN STUDY MATERIAL
                    // =============================================

                    Button {

                        openScanner()

                    } label: {

                        HStack(spacing: 14) {

                            ZStack {

                                Circle()
                                    .fill(
                                        Color.white.opacity(0.18)
                                    )
                                    .frame(
                                        width: 48,
                                        height: 48
                                    )

                                Image(
                                    systemName:
                                        "doc.viewfinder"
                                )
                                .font(.title2)
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 3
                            ) {

                                Text(
                                    "Scan Study Material"
                                )
                                .font(.headline)

                                Text(
                                    "Use OCR to turn pages into notes"
                                )
                                .font(.caption)
                                .opacity(0.9)
                            }

                            Spacer()

                            Image(
                                systemName:
                                    "camera.fill"
                            )
                            .font(.title3)
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity
                        )
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.buttonRadius
                            )
                            .fill(
                                RecalllQTheme.secondaryButton
                            )
                        )
                    }

                    // =============================================
                    // OCR PROCESSING
                    // =============================================

                    if isProcessingScan {

                        HStack(spacing: 12) {

                            ProgressView()
                                .tint(
                                    RecalllQTheme.primary
                                )

                            VStack(
                                alignment: .leading,
                                spacing: 2
                            ) {

                                Text(
                                    "Reading study material..."
                                )
                                .font(.subheadline)
                                .bold()

                                Text(
                                    "RecalllQ is extracting the text"
                                )
                                .font(.caption)
                                .foregroundColor(
                                    RecalllQTheme.secondaryText
                                )
                            }

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.mediumRadius
                            )
                            .fill(
                                RecalllQTheme.blueBackground
                            )
                        )
                    }

                    // =============================================
                    // NOTES HEADER
                    // =============================================

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("My Study Notes")
                                .font(.title3)
                                .bold()

                            Text(
                                "\(appState.notesViewModel.filteredNotes.count) notes"
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                        }

                        Spacer()

                        Image(
                            systemName:
                                "books.vertical.fill"
                        )
                        .foregroundColor(
                            RecalllQTheme.primary
                        )
                    }

                    // =============================================
                    // EMPTY STATE
                    // =============================================

                    if appState
                        .notesViewModel
                        .filteredNotes
                        .isEmpty {

                        VStack(spacing: 14) {

                            ZStack {

                                Circle()
                                    .fill(
                                        RecalllQTheme.blueBackground
                                    )
                                    .frame(
                                        width: 76,
                                        height: 76
                                    )

                                Image(
                                    systemName:
                                        "note.text"
                                )
                                .font(.system(size: 30))
                                .foregroundColor(
                                    RecalllQTheme.primary
                                )
                            }

                            Text(
                                appState
                                    .notesViewModel
                                    .searchText
                                    .isEmpty
                                ? "No study notes yet"
                                : "No notes found"
                            )
                            .font(.headline)

                            Text(
                                appState
                                    .notesViewModel
                                    .searchText
                                    .isEmpty
                                ? "Create your first note and RecalllQ will turn it into a smart memory."
                                : "Try a different search term."
                            )
                            .font(.caption)
                            .foregroundColor(
                                RecalllQTheme.secondaryText
                            )
                            .multilineTextAlignment(
                                .center
                            )
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(28)
                        .background(
                            RoundedRectangle(
                                cornerRadius:
                                    RecalllQTheme.largeRadius
                            )
                            .fill(
                                RecalllQTheme.blueBackground
                            )
                        )

                    } else {

                        // =========================================
                        // NOTES
                        // =========================================

                        ForEach(
                            appState
                                .notesViewModel
                                .filteredNotes
                        ) { note in

                            noteCard(note)
                        }
                    }
                }
                .padding()
            }

            // =================================================
            // UNDO BAR
            // =================================================

            if showUndo {

                HStack(spacing: 10) {

                    Image(
                        systemName:
                            "trash.fill"
                    )
                    .foregroundColor(
                        .red
                    )

                    Text("Note deleted")
                        .font(.subheadline)
                        .bold()

                    Spacer()

                    Button("Undo") {

                        appState
                            .notesViewModel
                            .undoDelete()

                        showUndo = false
                    }
                    .foregroundColor(
                        RecalllQTheme.primary
                    )
                    .bold()
                }
                .padding()
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            RecalllQTheme.mediumRadius
                    )
                    .fill(
                        RecalllQTheme.cardBackground
                    )
                )
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 5,
                    y: 2
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }

        // =====================================================
        // NAVIGATION
        // =====================================================

        .navigationTitle("Study Notes")
        .navigationBarTitleDisplayMode(.inline)

        // =====================================================
        // DOCUMENT SCANNER
        // =====================================================

        .sheet(
            isPresented: $showScanner
        ) {

            DocumentScannerView {

                scannedImages in

                processScannedImages(
                    scannedImages
                )
            }
        }

        // =====================================================
        // OCR REVIEW
        // =====================================================

        .sheet(
            isPresented: $showScanReview
        ) {

            ScanReviewView(
                scannedText: scannedText
            ) { finalText in

                saveScannedNote(
                    text: finalText
                )
            }
        }

        // =====================================================
        // SCANNER ALERT
        // =====================================================

        .alert(
            "Camera Scanner Unavailable",
            isPresented:
                $showScannerUnavailable
        ) {

            Button("OK") {

                showScannerUnavailable = false
            }

        } message: {

            Text(
                "Document scanning requires a physical iPhone or iPad with a supported camera. You can continue using RecalllQ in the Simulator."
            )
        }
    }

    // =====================================================
    // NOTE CARD
    // =====================================================

    @ViewBuilder
    private func noteCard(
        _ note: Note
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            // =============================================
            // TITLE ROW
            // =============================================

            HStack {

                Image(
                    systemName:
                        note.isPinned
                        ? "pin.fill"
                        : "note.text"
                )
                .foregroundColor(
                    note.isPinned
                    ? RecalllQTheme.secondary
                    : RecalllQTheme.primary
                )

                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if note.reminderDate != nil {

                    Image(
                        systemName:
                            "bell.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.secondary
                    )
                }

                if note.isPinned {

                    Image(
                        systemName:
                            "pin.fill"
                    )
                    .foregroundColor(
                        RecalllQTheme.secondary
                    )
                }
            }

            // =============================================
            // CONTENT
            // =============================================

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(
                    RecalllQTheme.secondaryText
                )
                .lineLimit(3)

            // =============================================
            // REMINDER
            // =============================================

            if let reminder =
                note.formattedReminder {

                HStack(spacing: 6) {

                    Image(
                        systemName:
                            "clock.fill"
                    )

                    Text(reminder)
                }
                .font(.caption)
                .foregroundColor(
                    RecalllQTheme.secondary
                )
                .padding(
                    .horizontal,
                    8
                )
                .padding(
                    .vertical,
                    5
                )
                .background(
                    Capsule()
                        .fill(
                            RecalllQTheme.orangeBackground
                        )
                )
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.mediumRadius
            )
            .fill(
                RecalllQTheme.cardBackground
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    RecalllQTheme.mediumRadius
            )
            .stroke(
                note.isPinned
                ? RecalllQTheme.secondary.opacity(0.35)
                : RecalllQTheme.primary.opacity(0.08),
                lineWidth: 1
            )
        )
        .shadow(
            color: Color.black.opacity(
                RecalllQTheme.shadowOpacity
            ),
            radius:
                RecalllQTheme.shadowRadius,
            x: 0,
            y: RecalllQTheme.shadowY
        )
        .swipeActions {

            // =============================================
            // DELETE
            // =============================================

            Button(
                role: .destructive
            ) {

                appState
                    .notesViewModel
                    .deleteNote(
                        id: note.id
                    )

                showUndo = true

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 3
                ) {

                    showUndo = false
                }

            } label: {

                Label(
                    "Delete",
                    systemImage:
                        "trash"
                )
            }

            // =============================================
            // PIN
            // =============================================

            Button {

                appState
                    .notesViewModel
                    .togglePin(
                        id: note.id
                    )

            } label: {

                Label(
                    note.isPinned
                    ? "Unpin"
                    : "Pin",
                    systemImage:
                        note.isPinned
                        ? "pin.slash"
                        : "pin"
                )
            }
            .tint(
                RecalllQTheme.secondary
            )
        }
    }

    // =====================================================
    // OPEN SCANNER
    // =====================================================

    private func openScanner() {

        guard
            VNDocumentCameraViewController
                .isSupported
        else {

            showScannerUnavailable = true

            print(
                "⚠️ Document camera is not available on this device."
            )

            return
        }

        showScanner = true
    }

    // =====================================================
    // ADD MANUAL NOTE
    // =====================================================

    private func addManualNote() {

        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let cleanContent =
            content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard
            !cleanTitle.isEmpty ||
            !cleanContent.isEmpty
        else {
            return
        }

        // =============================================
        // SAVE NOTE
        // =============================================

        appState.notesViewModel.addNote(
            title: cleanTitle,
            content: cleanContent,
            reminderDate:
                addReminder
                ? reminderDate
                : nil
        )

        // =============================================
        // RESET
        // =============================================

        title = ""
        content = ""

        addReminder = false

        reminderDate =
            Calendar.current.date(
                byAdding: .minute,
                value: 5,
                to: Date()
            ) ?? Date()

        isInputFocused = false
    }

    // =====================================================
    // PROCESS SCANNED IMAGES
    // =====================================================

    private func processScannedImages(
        _ images: [UIImage]
    ) {

        guard !images.isEmpty else {
            return
        }

        isProcessingScan = true

        let ocrService = OCRService()

        var results: [String] = []

        let group = DispatchGroup()

        // =============================================
        // OCR EACH PAGE
        // =============================================

        for image in images {

            group.enter()

            ocrService.recognizeText(
                from: image
            ) { text in

                if !text.isEmpty {

                    results.append(text)
                }

                group.leave()
            }
        }

        // =============================================
        // WAIT FOR OCR
        // =============================================

        group.notify(
            queue: .main
        ) {

            isProcessingScan = false

            scannedText =
                results.joined(
                    separator: "\n\n"
                )

            if !scannedText.isEmpty {

                showScanReview = true

            } else {

                print(
                    "⚠️ No text could be extracted."
                )
            }
        }
    }

    // =====================================================
    // SAVE SCANNED NOTE
    // =====================================================

    private func saveScannedNote(
        text: String
    ) {

        let cleanText =
            text.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanText.isEmpty else {
            return
        }

        // =============================================
        // AUTOMATIC TITLE
        // =============================================

        let title =
            "Scanned Study Notes"

        // =============================================
        // SAVE NOTE
        // =============================================

        appState.notesViewModel.addNote(
            title: title,
            content: cleanText
        )

        // =============================================
        // CLEAR
        // =============================================

        scannedText = ""
    }
}
