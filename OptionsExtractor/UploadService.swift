//
//  UploadService.swift
//  OptionsExtractor
//
//  Created by Phil Chan on 7/8/24.
//

import Foundation

func uploadTrade(image: Data, screenshot: Data?, tradingPlan: String, entryNotes: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let url = URL(string: "https://options-extractor-middleware.azurewebsites.net/insert-option") else {
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    // Add image data (PNG)
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    body.append(image)
    body.append("\r\n".data(using: .utf8)!)

    // Add screenshot data (if available)
    if let screenshot = screenshot {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"screenshot\"; filename=\"screenshot.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(screenshot)
        body.append("\r\n".data(using: .utf8)!)
    }

    // Add other parameters
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"tradingPlan\"\r\n\r\n".data(using: .utf8)!)
    body.append(tradingPlan.data(using: .utf8)!)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"entryNotes\"\r\n\r\n".data(using: .utf8)!)
    body.append(entryNotes.data(using: .utf8)!)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    // Debug prints
    print("Uploading trade with image size: \(image.count) bytes")
    if let screenshot = screenshot {
        print("Uploading trade with screenshot size: \(screenshot.count) bytes")
    }
    print("Trading Plan: \(tradingPlan)")
    print("Entry Notes: \(entryNotes)")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error uploading trade: \(error)")
            completion(.failure(error))
        } else if let httpResponse = response as? HTTPURLResponse {
            print("Server response status code: \(httpResponse.statusCode)")
            if let data = data {
                print("Server response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(.success(()))
            case 400:
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Bad request"])))
            case 500:
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
            default:
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code: \(httpResponse.statusCode)"])))
            }
        } else {
            print("Failed to upload trade. Server response: \(String(describing: response))")
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
        }
    }
    task.resume()
}
