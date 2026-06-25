
import SwiftUI

  // =====================================
 // DASHBOARD VIEW
 // ======================================

   // PURPOSE:
  //  - Main control center of the app
 // - User lands here after Welcome screen
 // - Entry point to all features
// ======================================[

struct DashboardView: View {

    var body: some View {

        VStack(spacing: 20) {

            Text("Dashboard")
                .font(.largeTitle)
                .bold()

            Text("Welcome to RecallQ")
                .foregroundColor(.gray)

            Spacer()

            // ==========================
            // NAVIGATION TO NOTES MODULE
            // ==========================

            NavigationLink(destination: NotesView()) {

                Text("Go to Notes")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Home")
    }
}
