//
//  FileUploader.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import Foundation
import UniformTypeIdentifiers
import RevenueCat
import SwiftUI


@MainActor
class DolbyIOViewModel: ObservableObject {

    private let service = DolbyIOService()
    @Published var selectedAction: ActionType?
    @Published var id: UUID?
    @Published var token: String?
    @Published var uploadLink: String?
    @Published var uploadResponse: HTTPURLResponse?
    @Published var previewjobID: String?
    @Published var jobID: String?
    @Published var error: Error?
    @Published var fileURL: String?
    @Published var previewStatus: String?
    @Published var previewURL: URL?
    @Published var jobStatus: String?
    @Published var downloadURL: URL?
    let masterPresets: [String:String] = [
        "a": "Pop",
        "b": "Club, EDM",
        "c": "Hip Hop(Big Bass, Tight Dynamics)",
        "d": "Hip Hop(Heavy Bass, Sub-Bass Presence)",
        "e": "Hip Hop, Trap",
        "f": "Lighter Electronic, EDM",
        "g": "Darker Electronic, EDM",
        "h": "Electronic, EDM",
        "i": "Pop, Rock, Country",
        "j": "Rock, Country",
        "k": "Pop",
        "l": "Vocal",
        "m": "Folk, Acoustic",
        "n": "Classical"
    ]
    @Published var selectedTranscode: Transcode = .mp3
    @Published var selectedPreset: String = "a"
    @Published var selectedTime = 0
    @Published var progressTitle = "Loading..."

    enum Destination: String, Hashable {
        case content,preview,result,analyzeResult,settings, store
    }

    @Published var path: [Destination] = []

    @AppStorage("credits") var credits: Int = 0

    @Published var analyzeResult: Analyze?

    @Published var products: [Package]?




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
        id = UUID()
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        Task {
            do {
                let receivedLink = try await service.uploadMediaInput(token: token, id: id)
                self.uploadLink = receivedLink
            } catch {
                self.error = error
            }
        }
    }

    func uploadMedia() {
        progressTitle = "Uploading..."
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
            } catch {
                self.error = error
                print("DEBUG Error in uploadMedia: \(error)")
            }

        }

    }

    func createMasterPreview() {
        progressTitle = "Creating..."
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        print(selectedTime,selectedPreset)
        Task {
            do {
                let result = try await service.createMasterPreview(apiToken: token, selectedPreset: selectedPreset, selectedTime: selectedTime, id: id)
                self.previewjobID = result
                print("JOB ID: \(result)")
                self.previewURL = nil
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }

    func getMasterPreviewJobStatus() {
        progressTitle = "Processing..."
        guard let token = self.token, let jobID = self.previewjobID else {
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
        progressTitle = "Successful."
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        Task {
            do {
                let fileURL = try await service.downloadMasteredPreview(apiToken: token, selectedPreset: selectedPreset, id: id)
                self.previewURL = fileURL
                print("DEBUG: Preview URL: \(String(describing: previewURL))")
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }

    }

    func masterMedia() {
        progressTitle = "Creating..."
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        Task {
            do {
                let result = try await service.createMasteredMedia(apiToken: token, selectedPreset: selectedPreset, id: id)
                self.jobID = result
                print("JOB ID: \(result)")
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
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        Task {
            do {
                let result = try await service.enhanceMedia(apiToken: token, id: id)
                self.jobID = result
                print("JOB ID: \(result)")
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }

    func transcodeMedia() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        let selectedType = self.selectedTranscode.rawValue
        Task {
            do {
                let result = try await service.transcodeMedia(apiToken: token, id: id, selectedType: selectedType)
                self.jobID = result
                print("JOB ID: \(result)")
                self.error = nil
                self.credits -= 50
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }

    func analyzeMedia() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        Task {
            do {
                let result = try await service.analyzeMedia(apiToken: token, id: id)
                self.jobID = result
                print("JOB ID: \(result)")
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }

    func getJobStatus(selectedAction: String) {
        progressTitle = "Processing..."
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
                let result = try await service.getJobStatus(apiToken: token, jobID: jobID, selectedAction: selectedAction)
                print("Status: \(result)")
                self.jobStatus = result
                self.error = nil
            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }

    func downloadMedia(selectedAction: String, fileType:String) {
        progressTitle = "Succesful!"
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }

        Task {
            do {
                let fileURL = try await service.downloadMedia(apiToken: token, selectedAction: selectedAction, id: id, fileType: fileType)
                self.downloadURL = fileURL
                self.fileURL = String(describing: fileURL)
                self.id = nil
                self.error = nil

            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }
    }

    func getAnalysisResult() {
        guard let token = self.token else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        guard let id = self.id else {
            self.error = NSError(domain: "TokenNotAvailable", code: 0, userInfo: nil)
            return
        }
        Task {
            do {
                let data = try await service.getAnalysisResult(apiToken: token, id: id)
                self.analyzeResult = data

            } catch {
                self.error = error
                print("DEBUG Error: \(error.localizedDescription)")
            }
        }

    }

    func fetchProducts() {
        Purchases.shared.getOfferings { (offerings, error) in
            if let coinOffering = offerings?["credits"] {
                self.products = coinOffering.availablePackages
            }
            if let error = error {
                print(error.localizedDescription)
            }
        }
        }

        func purchaseProduct(_ product: Package) {
            Purchases.shared.purchase(package: product) { (transaction, customerInfo, error, userCancelled) in
                if let error = error {
                    print("Purchase failed: \(error.localizedDescription)")
                } else if userCancelled {
                    print("Purchase cancelled")
                } else {
                    print("Purchase successful: \(product.identifier), \(product.storeProduct), \(product.localizedPriceString)")
                    switch product.identifier {
                    case "credits-100":
                        self.credits += 100
                    case "credits-200":
                        self.credits += 200
                    case "credits-500":
                        self.credits += 500
                    case "credits-1000":
                        self.credits += 1000
                    default:
                        print("something happened.")
                    }
                }
            }
        }

    }


extension DolbyIOViewModel {
    func reset() {
        token = nil
        uploadLink = nil
        uploadResponse = nil
        jobID = nil
        jobStatus = nil
        downloadURL = nil
        error = nil
        fileURL = nil
        previewStatus = nil
        previewURL = nil
        self.id = nil
        analyzeResult = nil
        products = nil
        print("viewModel reseted")
    }
    
    func selectAction(_ action: ActionType) {
            selectedAction = action
            print("DEBUG: Selected Action: \(selectedAction)")
        }
}







