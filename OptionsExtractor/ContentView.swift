import SwiftUI
import Foundation

import SwiftUI
import Foundation

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
                    .frame(width: 150, alignment: .leading)
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
            .padding()
            .background(Color(NSColor.controlBackgroundColor)) // Set background color to match form input

            VStack {
                Text("Screenshot of Chart")
                    .font(.headline)
                    .frame(width: 150, alignment: .leading)
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
            .padding()
            .background(Color(NSColor.controlBackgroundColor)) // Set background color to match form input

            VStack(alignment: .leading) {
                Text("Trading Plan")
                    .font(.headline)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $tradingPlan)
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor)) // Match TextEditor background
                        .border(Color.gray, width: 1)
                }
                .frame(height: 50)
            }

            VStack(alignment: .leading) {
                Text("Entry Notes")
                    .font(.headline)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $entryNotes)
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor)) // Match TextEditor background
                        .border(Color.gray, width: 1)
                }
                .frame(height: 50)
            }

            HStack {
                Button(action: {
                    uploadImage()
                }) {
                    Text("Upload")
                }
                .keyboardShortcut(.return, modifiers: [])
                Text("(Press Enter to submit)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor)) // Set main container background to match window background
    }

    private func uploadImage() {
        guard let imageData = imageData else { return }
        uploadTrade(image: imageData, screenshot: chartScreenshotData, tradingPlan: tradingPlan, entryNotes: entryNotes)
    }
}

//#Preview {
//    ContentView()
//}

#Preview {
    ContentView()
}
