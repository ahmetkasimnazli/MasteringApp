//
//  FileUploader.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import Foundation


@MainActor
class DolbyIOViewModel: ObservableObject {
    
    private let service = DolbyIOService.shared
    @Published var token: String?
    @Published var uploadLink: String?
    @Published var uploadResponse: HTTPURLResponse?
    @Published var jobID: String?
    @Published var error: Error?
    
    func getToken() {
        Task {
            do {
                let receivedToken = try await service.getToken()
                self.token = receivedToken
            } catch {
                self.error = error
            }
        }
    }
    
    func uploadMediaInput() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        
        Task {
            do {
                let receivedLink = try await service.uploadMediaInput(token: token)
                self.uploadLink = receivedLink
            } catch {
                self.error = error
            }
        }
    }
    
    func uploadMedia(localFilePath: String) {
        guard let uploadLink = self.uploadLink else {
            self.error = NSError(domain: "UploadLinkNotAvailable", code: 0, userInfo: nil)
            return
        }
        
        Task {
            do {
                let httpResponse = try await service.uploadMedia(localFilePath: localFilePath, preSignedURL: uploadLink)
                
                self.uploadResponse = httpResponse
                print("DEBUG: filePath: \(localFilePath) uploadLink:  \(uploadLink)")
            } catch {
                self.error = error
            }
        }
    }
    
    func enhanceMedia() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
            Task {
                do {
                    let result = try await service.enhanceMedia(apiToken: token)
                    self.jobID = result
                    print("JOB ID: \(result)")
                    self.error = nil
                } catch {
                    self.error = error
                    print("DEBUG Error: \(error.localizedDescription)")
                }
            }
        }
    
    func getEnhanceJobStatus() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let jobID = self.jobID else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        Task {
            do {
                let result = try await service.getEnhanceJobStatus(apiToken: token, jobID: jobID)
                print("Status: \(result)")
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadEnhancedMedia() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        Task {
            do {
                let result = try await service.downloadEnhancedMedia(apiToken: token)
                print("Successfull")
                print("Result: \(result)")
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }
}








