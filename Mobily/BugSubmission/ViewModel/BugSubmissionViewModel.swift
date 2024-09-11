//
//  BugSubmissionViewModel.swift
//  Mobily
//
//  Created by Mohamed Ragab on 06/09/2024.
//

import Foundation
import SwiftUI
import Alamofire
import FirebaseStorage
import GoogleSignIn
import SafariServices
import FirebaseCore
import FirebaseAuth

class BugSubmissionViewModel: ObservableObject {
    
    @Published var description: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var isSubmitting: Bool = false
    @Published var submissionSuccess: Bool = false
    @Published var submissionError: String? = nil
    @Published var isAuthorized: Bool = false
    var accessToken: String?
    
    private var refreshToken: String?
    private let clientId     = "835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v.apps.googleusercontent.com"
    private let clientSecret = "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"
    private let redirectUri  = "com.googleusercontent.apps.835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v:/oauth2redirect"
    private let scopes       = "https://www.googleapis.com/auth/spreadsheets"

    
    
    // client id    835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v.apps.googleusercontent.com
    // client secret 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
    // urls schemes com.googleusercontent.apps.835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v
    
    
    
    
    init() {
        checkSignInStatus()
    }
    
//    func signInWithGoogle() {
//        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
//            return
//        }
//        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
//    }
    
//    func signInWithGoogle() {
//
//        let configuration = GIDConfiguration(clientID: clientId )
//        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: getRootViewController() ) { [weak self] user, error in
//            if let error = error {
//                print("Google Sign-In error: \(error.localizedDescription)")
//                self?.submissionError = "Sign-in failed: \(error.localizedDescription)"
//                return
//            }
//
//            guard let user = user else {
//                self?.submissionError = "No user returned from Google Sign-In."
//                return
//            }
//
//            self?.accessToken = user.authentication.accessToken
//            self?.isAuthorized = true
//        }
//    }
            
    
    func checkSignInStatus() {
        if let currentUser = GIDSignIn.sharedInstance.currentUser {
            self.accessToken = "\(currentUser.accessToken.tokenString)"
            print("accessToken in viewModel : \(accessToken ?? "")")
            self.isAuthorized = true
        } else {
            self.isAuthorized = false
        }
    }
    
    
    func getAuthorizationURL() -> URL? {
        var urlComponents = URLComponents(string: "https://accounts.google.com/o/oauth2/auth")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent") // Ensure we get a refresh token
        ]
        return urlComponents?.url
    }
    
    func openAuthorizationURL() {
        guard let authorizationURL = getAuthorizationURL() else { return }
        UIApplication.shared.open(authorizationURL, options: [:], completionHandler: nil)

//        guard let authorizationURL = getAuthorizationURL() else { return }
//        let safariVC = SFSafariViewController(url: authorizationURL)
//        UIApplication.shared.windows.first?.rootViewController?.present(safariVC, animated: true, completion: nil)
    }
    
    func handleAuthorizationRedirect(url: URL) {
        print("handleAuthorizationRedirect : \(url)")
        
        guard let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value else {
            print("Failed to get authorization code")
            return
        }
        
        exchangeAuthorizationCodeForToken(code: code)
    }
    
     func exchangeAuthorizationCodeForToken(code: String) {
        let tokenURL = "https://oauth2.googleapis.com/token"
        let parameters: [String: Any] = [
            "code": code,
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectUri,
            "grant_type": "authorization_code"
        ]
         
         let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
         
        
        AF.request(tokenURL, method: .post, parameters: parameters, encoding: URLEncoding.default , headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print("data : \(data)")                    
                    if let json = data as? [String: Any],
                       let accessToken = json["access_token"] as? String,
                       let refreshToken = json["refresh_token"] as? String {
                        // Save access and refresh tokens
                        self.accessToken = accessToken
                        self.refreshToken = refreshToken
                        self.isAuthorized = true
                        print("Access Token: \(accessToken)")
                        print("Refresh Token: \(refreshToken)")
                    }
                case .failure(let error):
                    print("Error exchanging code for token: \(error)")
                }
            }
    }
    
    
    func formattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"  // Format: day-month-year (last two digits)
        let formattedDate = dateFormatter.string(from: Date())
        return formattedDate
    }
    
    
    func submitBug() {
        guard !description.isEmpty else {
            submissionError = "Description cannot be empty."
            return
        }
        
        // Example: Convert image to Data
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else {
            submissionError = "Image could not be converted."
            return
        }
        
        // Perform the submission
        isSubmitting = true
        
        guard let image = selectedImage else {
            submissionError = "No image selected."
            return
        }
        
        // Step 1: Upload image and get URL
        uploadImage(image) { [weak self] imageUrl in
            guard let self = self else { return }
            
            guard let imageUrl = imageUrl else {
                self.submissionError = "Failed to upload image."
                self.isSubmitting = false
                return
            }
            
            // Step 2: Write to Google Sheets
            let values = [[imageUrl , self.description]]
            
            var formattedDate: String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yy"  // Format: day-month-year (last two digits)
                return dateFormatter.string(from: Date())
            }
            
            
            self.updateSheet(spreadsheetId: "10CUyGACHb1qeQVWOL0eZ1WfyKHdSqQaJTe448Jg7vDI", range: formattedDate , values: values, apiKey: "AIzaSyDRk0vpRdAvaAPVv7D0xmSVPQBMdQJD4e4")
        }
        
        
    }
    
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Create a reference to the Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Create a unique file name for the image
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("images/\(imageName).jpg")
        
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(nil)
            return
        }
        
        // Upload the image data
        let _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Get the download URL
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    completion(nil)
                    return
                }
                print("downloadURL : \(downloadURL)")
                completion(downloadURL)
                
                
            }
        }
    }
       
    private func updateSheet(spreadsheetId: String, range: String, values: [[String]], apiKey: String) {
        //&key=\(apiKey)
        // Construct the URL
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(range):append?valueInputOption=RAW&key=\(apiKey)"
        // Prepare parameters in the correct format
        print("url :: \(url)")
        let parameters: [String: Any] = [
            "values": values
        ]
        // Define headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json" ,
            "Authorization": "Bearer \(String(describing: accessToken))"
        ]
        // Make the request
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            // Handle the response
            self.isSubmitting = false
            switch response.result {
            case .success(let data):
                self.submissionSuccess = true
                print("Success: \(data)")
            case .failure(let error):
                self.submissionError = error.localizedDescription
                if let data = response.data {
                    // Log the raw response data for more details
                    let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                    print("Error: \(error), Response: \(responseString)")
                } else {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    
    
    private func getRootViewController() -> UIViewController {
        // Utility function to get the root view controller
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found.")
        }
        guard let rootViewController = window.rootViewController else {
            fatalError("No root view controller found.")
        }
        return rootViewController
    }
}

//https://docs.google.com/spreadsheets/d/e/2PACX-1vShq4ij45YOSTwMQTy7VIoHizydfIjTtxdmkO_10seZaFTNEVShX9eKwZQyQ8wMTjeTPzGjmOiNJmEI/pubhtml
