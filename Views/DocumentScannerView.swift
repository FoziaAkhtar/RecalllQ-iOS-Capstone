
import SwiftUI
import VisionKit

// =====================================================
// VIEW: DocumentScannerView
// =====================================================
// PURPOSE:
// Opens Apple's built-in document scanner.
//
// IMPORTANT:
// The document scanner is only available on devices
// that support Apple's document camera.
//
// This view safely handles:
// - Supported iPhone/iPad
// - iOS Simulator
// - Camera unavailable
// - User cancellation
// - Scanner errors
//
// FLOW:
//
// Scan Button
//      ↓
// Check Camera Support
//      ↓
// Document Scanner
//      ↓
// Scanned Pages
//      ↓
// OCRService
// =====================================================

struct DocumentScannerView: UIViewControllerRepresentable {

    // =====================================================
    // COMPLETION HANDLER
    // =====================================================

    let onScanCompleted: ([UIImage]) -> Void

    // =====================================================
    // CREATE VIEW CONTROLLER
    // =====================================================

    func makeUIViewController(
        context: Context
    ) -> UIViewController {

        // =================================================
        // CHECK DOCUMENT CAMERA SUPPORT
        // =================================================

        guard VNDocumentCameraViewController.isSupported else {

            print("⚠️ Document camera is not available")

            return UIViewController()
        }

        // =================================================
        // CREATE SCANNER
        // =================================================

        let scanner =
            VNDocumentCameraViewController()

        scanner.delegate = context.coordinator

        return scanner
    }

    // =====================================================
    // UPDATE VIEW CONTROLLER
    // =====================================================

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {

        // No updates required.
    }

    // =====================================================
    // CREATE COORDINATOR
    // =====================================================

    func makeCoordinator() -> Coordinator {

        Coordinator(self)
    }

    // =====================================================
    // COORDINATOR
    // =====================================================
    // Connects UIKit scanner with SwiftUI.
    // =====================================================

    final class Coordinator:
        NSObject,
        VNDocumentCameraViewControllerDelegate {

        private let parent: DocumentScannerView

        init(
            _ parent: DocumentScannerView
        ) {

            self.parent = parent
        }

        // =================================================
        // SCAN COMPLETED
        // =================================================

        func documentCameraViewController(
            _ controller:
            VNDocumentCameraViewController,
            didFinishWith scan:
            VNDocumentCameraScan
        ) {

            var scannedImages: [UIImage] = []

            // ---------------------------------------------
            // GET ALL SCANNED PAGES
            // ---------------------------------------------

            for index in 0..<scan.pageCount {

                let image =
                    scan.imageOfPage(at: index)

                scannedImages.append(image)
            }

            // ---------------------------------------------
            // SEND IMAGES BACK
            // ---------------------------------------------

            parent.onScanCompleted(
                scannedImages
            )

            // ---------------------------------------------
            // CLOSE SCANNER
            // ---------------------------------------------

            controller.dismiss(
                animated: true
            )
        }

        // =================================================
        // USER CANCELLED
        // =================================================

        func documentCameraViewControllerDidCancel(
            _ controller:
            VNDocumentCameraViewController
        ) {

            controller.dismiss(
                animated: true
            )
        }

        // =================================================
        // SCANNER ERROR
        // =================================================

        func documentCameraViewController(
            _ controller:
            VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {

            print(
                "❌ DOCUMENT SCANNER ERROR:",
                error.localizedDescription
            )

            controller.dismiss(
                animated: true
            )
        }
    }
}
