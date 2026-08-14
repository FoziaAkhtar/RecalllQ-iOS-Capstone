
import SwiftUI
import VisionKit

// =====================================================
// VIEW: NotesView
// =====================================================
// PURPOSE:
// Main notes screen for RecalllQ.
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
//
// SCANNING FLOW:
//
// Scan Study Notes
//       ↓
// Check Scanner Availability
//       ↓
// Document Scanner
//       ↓
// OCRService
//       ↓
// Extracted Text
//       ↓
// Review Text
//       ↓
// Create Note
//       ↓
// MemoryEngine
//       ↓
// New Memory
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

        VStack(spacing: 12) {

            // =================================================
            // SEARCH BAR
            // =================================================

            TextField(
                "Search notes...",
                text: $appState.notesViewModel.searchText
            )
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)

            // =================================================
            // MANUAL NOTE INPUT
            // =================================================

            VStack(spacing: 10) {

                TextField(
                    "Enter title",
                    text: $title
                )
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)

                TextField(
                    "Enter content",
                    text: $content
                )
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)

                // =================================================
                // REMINDER TOGGLE
                // =================================================

                Toggle(
                    isOn: $addReminder
                ) {

                    Label(
                        "Set Study Reminder",
                        systemImage: "bell.fill"
                    )
                }
                .tint(.orange)

                // =================================================
                // DATE + TIME PICKER
                // =================================================

                if addReminder {

                    DatePicker(
                        "Reminder",
                        selection: $reminderDate,
                        in: Date()...,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )
                    .datePickerStyle(.compact)
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal)

            // =================================================
            // ADD NOTE BUTTON
            // =================================================

            Button {

                addManualNote()

            } label: {

                Label(
                    "Add Note",
                    systemImage: "plus.circle.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // =================================================
            // SCAN STUDY NOTES BUTTON
            // =================================================

            Button {

                openScanner()

            } label: {

                HStack(spacing: 10) {

                    Image(
                        systemName: "doc.viewfinder"
                    )
                    .font(.title3)

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text("Scan Study Notes")
                            .font(.headline)

                        Text("Use your camera with OCR")
                            .font(.caption)
                            .opacity(0.9)
                    }

                    Spacer()

                    Image(
                        systemName: "camera.fill"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // =================================================
            // SCANNING STATUS
            // =================================================

            if isProcessingScan {

                HStack(spacing: 10) {

                    ProgressView()

                    Text(
                        "Reading your study material..."
                    )
                    .foregroundColor(.secondary)
                }
                .padding()
            }

            // =================================================
            // NOTES LIST
            // =================================================

            List {

                if appState
                    .notesViewModel
                    .filteredNotes
                    .isEmpty {

                    Text("No notes found")
                        .foregroundColor(.gray)
                        .frame(
                            maxWidth: .infinity
                        )
                }

                ForEach(
                    appState
                        .notesViewModel
                        .filteredNotes
                ) { note in

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        // -----------------------------------------
                        // TITLE
                        // -----------------------------------------

                        HStack {

                            Text(note.title)
                                .font(.headline)

                            Spacer()

                            if note.reminderDate != nil {

                                Image(
                                    systemName:
                                    "bell.fill"
                                )
                                .foregroundColor(.orange)
                            }

                            Image(
                                systemName:
                                note.isPinned
                                ? "pin.fill"
                                : "pin"
                            )
                            .foregroundColor(.orange)
                        }

                        // -----------------------------------------
                        // CONTENT
                        // -----------------------------------------

                        Text(note.content)
                            .foregroundColor(.gray)
                            .lineLimit(3)

                        // -----------------------------------------
                        // REMINDER INFORMATION
                        // -----------------------------------------

                        if let reminder =
                            note.formattedReminder {

                            Label(
                                reminder,
                                systemImage: "clock.fill"
                            )
                            .font(.caption)
                            .foregroundColor(.orange)
                        }
                    }

                    .padding(.vertical, 4)

                    // ---------------------------------------------
                    // SWIPE ACTIONS
                    // ---------------------------------------------

                    .swipeActions {

                        // -----------------------------------------
                        // DELETE
                        // -----------------------------------------

                        Button(role: .destructive) {

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
                                systemImage: "trash"
                            )
                        }

                        // -----------------------------------------
                        // PIN
                        // -----------------------------------------

                        Button {

                            appState
                                .notesViewModel
                                .togglePin(
                                    id: note.id
                                )

                        } label: {

                            Label(
                                "Pin",
                                systemImage: "pin"
                            )
                        }
                        .tint(.orange)
                    }
                }
            }

            // =================================================
            // UNDO BAR
            // =================================================

            if showUndo {

                HStack {

                    Image(
                        systemName: "trash"
                    )

                    Text("Note deleted")

                    Spacer()

                    Button("Undo") {

                        appState
                            .notesViewModel
                            .undoDelete()

                        showUndo = false
                    }
                    .bold()
                }
                .padding()
                .background(
                    Color.gray.opacity(0.1)
                )
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }

        // =====================================================
        // NAVIGATION TITLE
        // =====================================================

        .navigationTitle("Study Notes")

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
        // SCANNER UNAVAILABLE ALERT
        // =====================================================

        .alert(
            "Camera Scanner Unavailable",
            isPresented: $showScannerUnavailable
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
    // OPEN SCANNER
    // =====================================================

    private func openScanner() {

        guard VNDocumentCameraViewController.isSupported else {

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

        // =================================================
        // ADD NOTE WITH OPTIONAL REMINDER
        // =================================================

        appState.notesViewModel.addNote(
            title: cleanTitle,
            content: cleanContent,
            reminderDate:
                addReminder
                ? reminderDate
                : nil
        )

        // =================================================
        // RESET INPUT
        // =================================================

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

        // =================================================
        // OCR EACH PAGE
        // =================================================

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

        // =================================================
        // WAIT FOR ALL PAGES
        // =================================================

        group.notify(
            queue: .main
        ) {

            isProcessingScan = false

            scannedText = results.joined(
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

        // =================================================
        // AUTOMATIC TITLE
        // =================================================

        let title =
            "Scanned Study Notes"

        // =================================================
        // SAVE THROUGH VIEWMODEL
        // =================================================

        appState.notesViewModel.addNote(
            title: title,
            content: cleanText
        )

        // =================================================
        // CLEAR SCANNER STATE
        // =================================================

        scannedText = ""
    }
}
