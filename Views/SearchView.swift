
import SwiftUI


// =========================================
// SEARCH VIEW
// ==========================================

//  PURPOSE:
// - Search feature foundation
// - Will be expanded later
// ==========================================

struct SearchView: View {

    @State private var searchText: String = ""

    var body: some View {

        VStack {

            TextField("Search...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()

            Spacer()

            Text("Search results will appear here")
                .foregroundColor(.gray)

            Spacer()
        }
        .navigationTitle("Search")
    }
}
