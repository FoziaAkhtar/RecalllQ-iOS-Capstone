
import Foundation
import Vision
import UIKit

// =====================================================
// SERVICE: OCRService
// =====================================================
// PURPOSE:
// Converts scanned images into readable text.
//
// This service uses Apple's Vision framework to perform
// Optical Character Recognition (OCR).
//
// IMPORTANT:
// - No external API is required.
// - No internet connection is required.
// - Works with printed study material.
// - The extracted text can later be sent to
//   MemoryEngine for summary + tags + importance.
//
// FLOW:
//
// Scanned Document
//       ↓
// UIImage
//       ↓
// Vision OCR
//       ↓
// Extracted Text
//       ↓
// RecalllQ Note
//       ↓
// MemoryEngine
// =====================================================

final class OCRService {

    // =====================================================
    // PUBLIC API
    // =====================================================
    // Extracts text from a scanned image.
    //
    // completion:
    // Returns the extracted text.
    // =====================================================

    func recognizeText(
        from image: UIImage,
        completion: @escaping (String) -> Void
    ) {

        // =================================================
        // CONVERT UIImage → CGImage
        // =================================================

        guard let cgImage = image.cgImage else {

            print("❌ OCR ERROR: Unable to create CGImage")

            DispatchQueue.main.async {
                completion("")
            }

            return
        }

        // =================================================
        // CREATE OCR REQUEST
        // =================================================

        let request = VNRecognizeTextRequest {

            request,
            error in

            // -------------------------------------------------
            // HANDLE OCR ERROR
            // -------------------------------------------------

            if let error = error {

                print(
                    "❌ OCR ERROR:",
                    error.localizedDescription
                )

                DispatchQueue.main.async {
                    completion("")
                }

                return
            }

            // =================================================
            // GET OCR RESULTS
            // =================================================

            guard let observations =
                    request.results
                    as? [VNRecognizedTextObservation]
            else {

                print("⚠️ OCR: No text detected")

                DispatchQueue.main.async {
                    completion("")
                }

                return
            }

            // =================================================
            // EXTRACT TEXT
            // =================================================

            let extractedText = observations
                .compactMap { observation in

                    observation
                        .topCandidates(1)
                        .first?
                        .string
                }
                .joined(separator: "\n")

            // =================================================
            // RETURN RESULT
            // =================================================

            DispatchQueue.main.async {

                if extractedText.isEmpty {

                    print("⚠️ OCR: No readable text found")

                } else {

                    print("✅ OCR text extracted successfully")
                }

                completion(extractedText)
            }
        }

        // =====================================================
        // OCR CONFIGURATION
        // =====================================================

        // Accurate mode provides better recognition for
        // academic documents and study material.
        request.recognitionLevel = .accurate

        // Helps Vision correct common OCR mistakes.
        request.usesLanguageCorrection = true

        // =====================================================
        // CREATE IMAGE REQUEST HANDLER
        // =====================================================

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            options: [:]
        )

        // =====================================================
        // RUN OCR IN BACKGROUND
        // =====================================================
        // OCR can be CPU intensive, so we do not run it
        // directly on the main UI thread.
        // =====================================================

        DispatchQueue.global(
            qos: .userInitiated
        ).async {

            do {

                try handler.perform([request])

            } catch {

                print(
                    "❌ OCR PROCESSING ERROR:",
                    error.localizedDescription
                )

                DispatchQueue.main.async {
                    completion("")
                }
            }
        }
    }
}
