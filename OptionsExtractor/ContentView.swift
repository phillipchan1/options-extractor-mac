import SwiftUI
import Foundation

struct ContentView: View {
    @State private var imageData: Data?
    @State private var chartScreenshotData: Data?
    @State private var tradingPlan: String = ""
    @State private var entryNotes: String = ""

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("Screenshot of Trade")
                    .font(.headline)
                DropView(imageData: $imageData, onDrop: { urls in
                    guard let imageURL = urls.first else { return false }
                    do {
                        imageData = try Data(contentsOf: imageURL)
                        return true
                    } catch {
                        print("Error loading image: \(error)")
                        return false
                    }
                })
            }

            VStack {
                Text("Screenshot of Chart")
                    .font(.headline)
                DropView(imageData: $chartScreenshotData, onDrop: { urls in
                    guard let imageURL = urls.first else { return false }
                    do {
                        chartScreenshotData = try Data(contentsOf: imageURL)
                        return true
                    } catch {
                        print("Error loading chart screenshot: \(error)")
                        return false
                    }
                })
            }

            TextField("Trading Plan", text: $tradingPlan)
            TextField("Entry Notes", text: $entryNotes)

            Button(action: {
                uploadImage()
            }) {
                Text("Upload")
            }
        }
        .padding()
    }

    private func uploadImage() {
        guard let imageData = imageData else { return }
        uploadTrade(image: imageData, screenshot: chartScreenshotData, tradingPlan: tradingPlan, entryNotes: entryNotes)
    }
}

#Preview {
    ContentView()
}
