
import SwiftUI


 // ==========================================
 // NOTES VIEW
 // ==========================================

  // ** PURPOSE:
 // - Shows list of saved notes
 // - First data-driven screen
 // - Prepares for CRUD features later
// ============================================

struct NotesView: View {

    // === SAMPLE DATA (for now) ===
    @State private var notes: [Note] = [

        Note(title: "Welcome Note", content: "This is your first note in RecallQ")
    ]

    var body: some View {

        List(notes) { note in

            VStack(alignment: .leading, spacing: 5) {

                Text(note.title)
                    .font(.headline)

                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Notes")
    }
}
