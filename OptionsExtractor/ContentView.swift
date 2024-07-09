import SwiftUI
import Foundation

struct ContentView: View {
    @State private var imageData: Data?
    @State private var chartScreenshotData: Data?
    @State private var tradingPlan: String = ""
    @State private var entryNotes: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case tradingPlan, entryNotes
    }

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
                .disabled(isLoading)
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
                .disabled(isLoading)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor)) // Set background color to match form input
            
            VStack(alignment: .leading) {
                Text("Entry Notes")
                    .font(.headline)
                TextField("Enter entry notes", text: $entryNotes, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor)) // Match TextField background
                    .border(Color.gray, width: 1)
                    .focused($focusedField, equals: .entryNotes)
                    .disabled(isLoading)
            }
            
            VStack(alignment: .leading) {
                Text("Trading Plan")
                    .font(.headline)
                TextField("Enter trading plan", text: $tradingPlan, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor)) // Match TextField background
                    .border(Color.gray, width: 1)
                    .focused($focusedField, equals: .tradingPlan)
                    .disabled(isLoading)
            }

            HStack {
                Button(action: {
                    clearForm()
                }) {
                    Text("Clear")
                }
                .padding(.trailing, 10)
                .foregroundColor(.red)
                .disabled(isLoading)
                
                Button(action: {
                    uploadImage()
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Upload")
                    }
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(isLoading)
                
                Text("(Press Cmd + Enter to submit)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor)) // Set main container background to match window background
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // Check for Cmd + Enter
                if event.modifierFlags.contains(.command) && event.keyCode == 36 && !isLoading {
                    uploadImage()
                    return nil
                }
                return event
            }
        }
    }

    private func uploadImage() {
        guard let imageData = imageData else { return }
        isLoading = true
        uploadTrade(image: imageData, screenshot: chartScreenshotData, tradingPlan: tradingPlan, entryNotes: entryNotes)
        
        // Simulate successful API call by calling clearForm after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            clearForm()
            isLoading = false
        }
    }

    private func clearForm() {
        imageData = nil
        chartScreenshotData = nil
        tradingPlan = ""
        entryNotes = ""
        focusedField = .tradingPlan
    }
}

//#Preview {
//    ContentView()
//}

#Preview {
    ContentView()
}
