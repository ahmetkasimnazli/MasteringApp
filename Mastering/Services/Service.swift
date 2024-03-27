//
//  Service.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import Foundation

class DolbyIOService {
    
    static let shared = DolbyIOService()
    
    private init() {}
    
    func getToken() async throws -> String {
        let headers = [
            "accept": "application/json",
            "Cache-Control": "no-cache",
            "Content-Type": "application/json",
            "authorization": "Basic dng3NkNZVVVEMk1XcXh6WlY1b1hJUT09OnBKUzZXOXVjZkdZMjhTMlNSYVJoQVNFZ1dDUm91VGF5QTB5QkNVcEF3U009"
        ]
        
        let request = createRequest(url: "https://api.dolby.io/v1/auth/token", method: "POST", headers: headers)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: nil)
        }
        
        guard let token = parseAccessToken(from: data) else {
            throw NSError(domain: "InvalidToken", code: 0, userInfo: nil)
        }
        print("Token: \(token)")
        return token
    }
    
    func uploadMediaInput(token: String) async throws -> String {
        let headers = [
            "accept": "application/json",
            "content-type": "application/json",
            "authorization": "Bearer \(token)"
        ]
        
        let parameters = ["url": "dlb://in/file.mp3"]
        
        let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        
        var request = URLRequest(url: URL(string: "https://api.dolby.com/media/input")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                 let uploadLink = json["url"] as? String else {
               throw NSError(domain: "InvalidData", code: 0, userInfo: nil)
           }
        print("UploadLink: \(uploadLink)")
        return uploadLink
    }
    
    func uploadMedia(localFilePath: String, preSignedURL: String) async throws -> HTTPURLResponse {
        guard let fileURL = URL(string: preSignedURL) else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: fileURL)
        request.httpMethod = "PUT"
        
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: localFilePath))
            let (data, response) = try await URLSession.shared.upload(for: request, from: fileData)
            print("Data received: \(data)")

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
            }

            print("response: \(httpResponse)")
            return httpResponse
        } catch {
            print("Error reading file data: \(error)")
            throw error
        }
    }
    
    func createMasterPreview(apiToken: String, selectedPreset: String, selectedTime: Int) async throws -> String {
        let urlString = "https://api.dolby.com/media/master/preview"
        let sourceURL = "dlb://in/file.mp3"
        let startSegment = selectedTime
        let durationSegment = 30
        
        let parameters: [String: Any] = [
            "inputs": [
                ["source": sourceURL, "segment": ["start": startSegment, "duration": durationSegment]]
            ],
            "outputs": [
                [
                    "destination": "dlb://out/example-master-preview-a.wav",
                    "master": ["dynamic_eq": ["preset":"\(selectedPreset)"]]
                ]
            ]
        ]
        
        let headers = [
            "Authorization": "Bearer \(apiToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error happened1")
            throw error
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Handle response
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let jobId = jsonObject["job_id"] as? String {
                // jobId değeri başarılı bir şekilde alındı
                print("Başarılı: job_id = \(jobId)")
                return jobId
            } else {
                print("Error happened1")
                throw NSError(domain: "InvalidData", code: 0, userInfo: nil)
            } } catch {
                print("Error happened1")
                throw error
        }
    }
    
    func getMasterPreviewJobStatus(apiToken: String, jobID: String) async throws -> String {
        let urlString = "https://api.dolby.com/media/master/preview?job_id=\(jobID)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return "Invalid URL"
        }
        
        let headers = [
            "Authorization": "Bearer \(apiToken)"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Handle response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response Data: \(jsonString)")
            }
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let status = jsonObject["status"] as? String else {
                throw NSError(domain: "InvalidData", code: 0, userInfo: nil)
                    }
                    return status
        } catch {
            // Handle error
            print("Error: \(error)")
            throw error
        }
    }
    
    func downloadMasteredPreview(apiToken: String) async throws -> URL {
        let urlString = "https://api.dolby.com/media/output?url=dlb://out/example-master-preview-a.wav"
        
        let headers = [
            "Authorization": "Bearer \(apiToken)"
        ]
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle response
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Dosyanın geçici olarak saklandığı bir URL oluştur
                    let tempDirectoryURL = FileManager.default.temporaryDirectory
                    let fileURL = tempDirectoryURL.appendingPathComponent("example-enhanced-\(UUID()).wav")
                    
                    // Dosyayı geçici dizine kaydet
                    try data.write(to: fileURL)
                    
                    return fileURL
                } else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                }
            } else {
                throw NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
            }
        } catch {
            throw error
        }
    }
    
    func createMasteredMedia(apiToken: String) async throws -> String {
        let urlString = "https://api.dolby.com/media/master"
        let sourceURL = "dlb://in/file.mp3"
        let destinationURL = "dlb://out/example-mastered.mp3"
        let preset = "c"
        
        let parameters: [String: Any] = [
            "inputs": [["source": sourceURL]],
            "outputs": [
                [
                    "destination": destinationURL,
                    "master": ["dynamic_eq": ["preset": preset]]
                ]
            ]
        ]
        
        let headers = [
            "Authorization": "Bearer \(apiToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let jobId = jsonObject["job_id"] as? String {
                    // jobId değeri başarılı bir şekilde alındı
                    print("Başarılı: job_id = \(jobId)")
                    return jobId
                } else {
                print("Error happened1")
                throw NSError(domain: "InvalidData", code: 0, userInfo: nil)
            }
        } catch {
            print("Error happened1")
            throw error
        }
    }
    
    func enhanceMedia(apiToken: String) async throws -> String {
        let urlString = "https://api.dolby.com/media/enhance"
        
        let parameters: [String: Any] = [
            "input": "dlb://in/file.mp3",
            "output": "dlb://out/file-enhanced.mp3"
        ]
        
        let headers = [
            "Authorization": "Bearer \(apiToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        var request = createRequest(url: urlString, method: "POST", headers: headers)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let jobId = jsonObject["job_id"] as? String {
                    // jobId değeri başarılı bir şekilde alındı
                    print("Başarılı: job_id = \(jobId)")
                    return jobId
                } else {
                print("Error happened1")
                throw NSError(domain: "InvalidData", code: 0, userInfo: nil)
            }
        } catch {
            print("Error happened1")
            throw error
        }
    }

    func getJobStatus(apiToken: String, jobID: String, selectedAction: String) async throws -> String {
        let urlString = "https://api.dolby.com/media/\(selectedAction)?job_id=\(jobID)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return "Invalid URL"
        }
        
        let headers = [
            "Authorization": "Bearer \(apiToken)"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Handle response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response Data: \(jsonString)")
            }
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let status = jsonObject["status"] as? String else {
                throw NSError(domain: "InvalidData", code: 0, userInfo: nil)
                    }
                    return status
        } catch {
            // Handle error
            print("Error: \(error)")
            throw error
        }
    }
    
    func downloadMedia(apiToken: String, selectedAction: String) async throws -> URL {
        let urlString = "https://api.dolby.com/media/output?url=dlb://out/example-\(selectedAction).mp3"
        
        let headers = [
            "Authorization": "Bearer \(apiToken)"
        ]
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle response
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Dosyanın geçici olarak saklandığı bir URL oluştur
                    let tempDirectoryURL = FileManager.default.temporaryDirectory
                    let fileURL = tempDirectoryURL.appendingPathComponent("example-enhanced-\(UUID()).mp3")
                    
                    // Dosyayı geçici dizine kaydet
                    try data.write(to: fileURL)
                    
                    // Dosyanın URL'sini döndür
                    return fileURL
                } else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                }
            } else {
                throw NSError(domain: "InvalidResponse", code: 0, userInfo: nil)
            }
        } catch {
            throw error
        }
    }




    private func createRequest(url: String, method: String, headers: [String: String]) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        return request
    }
    
    private func parseAccessToken(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return jsonObject?["access_token"] as? String
        } catch {
            print("Error parsing access token: \(error)")
            return nil
        }
    }
}
