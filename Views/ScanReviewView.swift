
import SwiftUI

// =====================================================
// VIEW: ScanReviewView
// =====================================================
// PURPOSE:
// Allows the user to review and edit text extracted
// from scanned study material before saving it.
//
// FLOW:
//
// Scanned Document
//       ↓
// OCRService
//       ↓
// Extracted Text
//       ↓
// ScanReviewView
//       ↓
// User Reviews / Edits
//       ↓
// Save Note
//       ↓
// MemoryEngine
// =====================================================

struct ScanReviewView: View {

    // =====================================================
    // ENVIRONMENT
    // =====================================================

    @Environment(\.dismiss) private var dismiss

    // =====================================================
    // SCANNED TEXT
    // =====================================================

    @State private var text: String

    // =====================================================
    // COMPLETION HANDLER
    // =====================================================
    // Sends the final edited text back to NotesView.
    // =====================================================

    let onSave: (String) -> Void

    // =====================================================
    // INIT
    // =====================================================

    init(
        scannedText: String,
        onSave: @escaping (String) -> Void
    ) {

        _text = State(
            initialValue: scannedText
        )

        self.onSave = onSave
    }

    // =====================================================
    // BODY
    // =====================================================

    var body: some View {

        NavigationStack {

            VStack(
                alignment: .leading,
                spacing: 16
            ) {

                // =================================================
                // HEADER
                // =================================================

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Review Scanned Notes")
                        .font(.title2)
                        .bold()

                    Text(
                        "Check the extracted text before saving it."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                // =================================================
                // TEXT EDITOR
                // =================================================

                TextEditor(text: $text)
                    .padding(8)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            Color.gray.opacity(0.10)
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .stroke(
                            Color.gray.opacity(0.25)
                        )
                    )

                // =================================================
                // SAVE BUTTON
                // =================================================

                Button {

                    let cleanText =
                        text.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                    guard !cleanText.isEmpty else {
                        return
                    }

                    onSave(cleanText)

                    dismiss()

                } label: {

                    Label(
                        "Create Note & Memory",
                        systemImage: "brain.head.profile"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                // =================================================
                // CANCEL BUTTON
                // =================================================

                Button {

                    dismiss()

                } label: {

                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Scan Review")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
