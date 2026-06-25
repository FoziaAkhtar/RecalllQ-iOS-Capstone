
import Foundation

// ==========================================
// Note.swift
// ==========================================

// Purpose:
// - Represents a single note object
// - Used in NotesView
// - Helps structure app data cleanly
// ==========================================

struct Note: Identifiable {

    // === Unique ID for each note ===
    let id = UUID()

    // === Title of note ===
    var title: String

    // === Content inside note ===
    var content: String
}
