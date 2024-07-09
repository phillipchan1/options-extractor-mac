import SwiftUI

struct DropView: View {
    @Binding var imageData: Data?
    @State private var isDropTargeted = false
    @State private var droppedFileName: String? = nil
    var onDrop: ([URL]) -> Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(isDropTargeted ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)

                if let fileName = droppedFileName {
                    Text(fileName)
                        .foregroundColor(Color(NSColor.labelColor))
                } else {
                    Text("Drag and drop image here")
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onDrop(of: [.image, .fileURL], isTargeted: $isDropTargeted) { providers in
            var urls: [URL] = []

            let dispatchGroup = DispatchGroup()

            for provider in providers {
                if provider.canLoadObject(ofClass: URL.self) {
                    dispatchGroup.enter()
                    provider.loadObject(ofClass: URL.self) { url, error in
                        if let url = url {
                            urls.append(url)
                            self.droppedFileName = url.lastPathComponent
                        } else if let error = error {
                            print("Error loading URL: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                } else if provider.canLoadObject(ofClass: NSImage.self) {
                    dispatchGroup.enter()
                    provider.loadObject(ofClass: NSImage.self) { image, error in
                        if let image = image as? NSImage, let tiffData = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiffData), let pngData = bitmap.representation(using: .png, properties: [:]) {
                            self.imageData = pngData
                            self.droppedFileName = "Dropped Image"
                        } else if let error = error {
                            print("Error loading image: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                _ = self.onDrop(urls)
            }

            return true
        }
    }
}
