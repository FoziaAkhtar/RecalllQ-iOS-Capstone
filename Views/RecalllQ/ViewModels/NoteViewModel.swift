
import Foundation
import SwiftUI


// ==========================================
// NOTES VIEWMODEL (LOGIC LAYER)
// ==========================================

 // PURPOSE:
 // - Handles all CRUD operations
 // - Keeps Views clean
 // - Stores notes data
// =====================================================

class NotesViewModel: ObservableObject {

    // Published means UI auto-updates when data changes
    @Published var notes: [Note] = []

    // =====================================================
    // CREATE NOTE
    // =====================================================
    func addNote(title: String, content: String) {

        let newNote = Note(title: title, content: content)
        notes.append(newNote)
    }

    // =====================================================
    // DELETE NOTE
    // =====================================================
    func deleteNote(at offsets: IndexSet) {

        notes.remove(atOffsets: offsets)
    }
}
