//
//  FileUploader.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import Foundation
import Alamofire

class DolbyMediaViewModel {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func uploadMediaFile(filePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "url": "dlb://in/example.wav"
        ]
        
        AF.request("https://api.dolby.com/media/input", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Model.self) { (response) in
                switch response.result {
                case .success(let decodedResponse):
                    let url = decodedResponse.url // Assuming your response structure has a 'url' property
                    
                    print("Upload \(filePath) to \(url)")
                    let fileURL = URL(fileURLWithPath: filePath)
                    
                    AF.upload(fileURL, to: url, method: .put, headers: headers)
                        .uploadProgress { progress in
                            print("Upload Progress: \(progress.fractionCompleted)")
                        }
                        .response { response in
                            switch response.result {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// Kullanım örneği:
let apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9...." // API anahtarını buraya ekleyin
let viewModel = DolbyMediaViewModel(apiKey: apiKey)
let filePath = "path/to/your/file.wav" // Yüklemek istediğiniz dosyanın yolunu buraya ekleyin

viewModel.uploadMediaFile(filePath: filePath) { result in
    switch result {
    case .success:
        print("File uploaded successfully.")
    case .failure(let error):
        print("Error uploading file: \(error)")
    }
}
