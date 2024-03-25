//
//  FileUploader.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import Foundation
import UniformTypeIdentifiers


@MainActor
class DolbyIOViewModel: ObservableObject {
    
    private let service = DolbyIOService.shared
    @Published var isLoading = false
    @Published var token: String?
    @Published var uploadLink: String?
    @Published var uploadResponse: HTTPURLResponse?
    @Published var jobID: String?
    @Published var error: Error?
    @Published var fileURL: String?
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var isUploadCompleted = false
    @Published var previewStatus: String?
    @Published var previewURLs: [URL] = []




    
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
    
    func uploadMedia() {
        let localFilePath = fileURL
        guard let uploadLink = self.uploadLink else {
            self.error = NSError(domain: "UploadLinkNotAvailable", code: 0, userInfo: nil)
            return
        }
        
        Task {
            do {
                let httpResponse = try await service.uploadMedia(localFilePath: localFilePath ?? "", preSignedURL: uploadLink)
                
                self.uploadResponse = httpResponse
                print("DEBUG: filePath: \(localFilePath) uploadLink:  \(uploadLink)")
                print("DEBUG: response: \(httpResponse.statusCode)")
                
                self.alertTitle = "Upload is completed"
                self.showAlert = true
            } catch {
                self.error = error
                print("DEBUG Error in uploadMedia: \(error)") 
            }
            
        }
        
    }
    
    func createMasterPreview() {
            guard let token = self.token else {
                self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
                return
            }
            
            Task {
                do {
                    let result = try await service.createMasterPreview(apiToken: token)
                    self.jobID = result
                    print("JOB ID: \(result)")
                    
                    self.error = nil
                } catch {
                    self.error = error
                    print("DEBUG Error: \(error.localizedDescription)")
                }
            }
        }
        
        func getMasterPreviewJobStatus() {
            guard let token = self.token, let jobID = self.jobID else {
                self.error = NSError(domain: "TokenOrJobIDNotAvailable", code: 0, userInfo: nil)
                return
            }
            
            Task {
                do {
                    let result = try await service.getMasterPreviewJobStatus(apiToken: token, jobID: jobID)
                    print("Status: \(result)")
                    self.previewStatus = result
                    self.error = nil
                } catch {
                    self.error = error
                    print("DEBUG Error: \(error.localizedDescription)")
                }
            }
        }
    
    func downloadMasterPreview() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

            Task {
                do {
                    let result = try await service.downloadMasteredPreview(apiToken: token)
                    
                    print("DEBUG: Downloaded file: \(result)")
                    previewURLs.append(result)
                    print("DEBUG: Preview URL: \(previewURLs)")
                    self.error = nil
                } catch {
                    self.error = error
                    print("DEBUG Error: \(error.localizedDescription)")
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
    
    func masterMedia() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        Task {
            do {
                let result = try await service.createMasteredMedia(apiToken: token)
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
                let fileURL = try await service.downloadEnhancedMedia(apiToken: token)
                
                self.fileURL = String(describing: fileURL)
                
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }
    

}









