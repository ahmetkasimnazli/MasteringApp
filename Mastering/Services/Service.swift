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
        // API anahtarını ve uygulama gizli anahtarını oku
        let (appKey, appSecret) = try readAPIKey()
        
        // API anahtarını ve uygulama gizli anahtarını base64 kodla
        let credentials = "\(appKey):\(appSecret)"
        guard let data = credentials.data(using: .utf8) else {
            throw NSError(domain: "ErrorEncodingCredentials", code: 0, userInfo: nil)
        }
        let base64EncodedCredentials = data.base64EncodedString()
        
        // Token alma isteği oluştur
        let urlString = "https://api.dolby.io/v1/auth/token"
        let parameters = "grant_type=client_credentials&expires_in=1800"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64EncodedCredentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.data(using: .utf8)
        
        // Token alma isteğini gönder ve yanıtı al
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let responseData = data // Burada isteğe bağlı bir kontrol gerek yok, çünkü 'data' zaten 'Data' türünde
            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let token = json["access_token"] as? String {
                // Token başarıyla alındı
                print("Token: \(token)")
                return token
            }
            throw NSError(domain: "ErrorParsingToken", code: 0, userInfo: nil)
        } catch {
            throw error
        }
    }


    
    func uploadMediaInput(token: String, id: UUID) async throws -> String {
        let headers = [
            "accept": "application/json",
            "content-type": "application/json",
            "authorization": "Bearer \(token)"
        ]
        
        let parameters = ["url": "dlb://in/file-\(id).wav"]
        
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
    
    func createMasterPreview(apiToken: String, selectedPreset: String, selectedTime: Int, id: UUID) async throws -> String {
        let urlString = "https://api.dolby.com/media/master/preview"
        let sourceURL = "dlb://in/file-\(id).wav"
        let startSegment = selectedTime
        let durationSegment = 30
        
        let parameters: [String: Any] = [
            "inputs": [
                ["source": sourceURL, "segment": ["start": startSegment, "duration": durationSegment]]
            ],
            "outputs": [
                [
                    "destination": "dlb://out/example-\(id)-master-preview-\(selectedPreset).wav",
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
    
    func downloadMasteredPreview(apiToken: String, selectedPreset: String, id: UUID) async throws -> URL {
        let urlString = "https://api.dolby.com/media/output?url=dlb://out/example-\(id)-master-preview-\(selectedPreset).wav"
        
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
                    let fileURL = tempDirectoryURL.appendingPathComponent("example-mastered-\(UUID()).wav")
                    
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
    
    func createMasteredMedia(apiToken: String, selectedPreset: String, id: UUID) async throws -> String {
        let urlString = "https://api.dolby.com/media/master"
        let sourceURL = "dlb://in/file-\(id).wav"
        let destinationURL = "dlb://out/example-\(id)-master.wav"
        
        let parameters: [String: Any] = [
            "inputs": [["source": sourceURL]],
            "outputs": [
                [
                    "destination": destinationURL,
                    "master": ["dynamic_eq": ["preset": selectedPreset]]
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
    
    func enhanceMedia(apiToken: String, id: UUID) async throws -> String {
        let urlString = "https://api.dolby.com/media/enhance"
        
        let parameters: [String: Any] = [
            "input": "dlb://in/file-\(id).wav",
            "output": "dlb://out/example-\(id)-enhance.wav"
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
    
    func downloadMedia(apiToken: String, selectedAction: String, id: UUID) async throws -> URL {
        let urlString = "https://api.dolby.com/media/output?url=dlb://out/example-\(id)-\(selectedAction).wav"
                                                            //  dlb://out/example-\(id)-enhance.mp3
        
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
                    let fileURL = tempDirectoryURL.appendingPathComponent("example-\(id)-\(selectedAction).wav")
                    
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
    
    private func readAPIKey() throws -> (appKey: String, appSecret: String) {
        // JSON dosyasının yolu
        guard let url = Bundle.main.url(forResource: "API_KEY", withExtension: "json") else {
            throw NSError(domain: "FileNotFound", code: 0, userInfo: nil)
        }
        
        // JSON dosyasını veri olarak oku
        let data = try Data(contentsOf: url)
        
        // JSON verisini decode et
        let decoder = JSONDecoder()
        let apiKey = try decoder.decode(APIKey.self, from: data)
        
        return (appKey: apiKey.appKey, appSecret: apiKey.appSecret)
    }

}
