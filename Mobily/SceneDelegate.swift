//
//  SceneDelegate.swift
//  Mobily
//
//  Created by mac on 08/09/2024.
//

//
//import GoogleSignIn
//import SwiftUI
//import AuthenticationServices
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        if url.absoluteString.starts(with: "com.googleusercontent.apps.835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v.apps.googleusercontent.com:/oauth2redirect") {
//            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
//            if let queryItems = components?.queryItems {
//                if let code = queryItems.first(where: { $0.name == "code" })?.value {
//                    exchangeCodeForToken(code: code)
//                }
//            }
//        }
//    }
//    
//    func exchangeCodeForToken(code: String) {
//        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
//        var request = URLRequest(url: tokenURL)
//        request.httpMethod = "POST"
//        
//        // client id    835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v.apps.googleusercontent.com
//        // client secret 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
//        let parameters = [
//            "code": code,
//            "client_id": "835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v.apps.googleusercontent.com",
//            "client_secret": "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",
//            "redirect_uri": "com.googleusercontent.apps.835428604547-4ai1b21v87uc88or1n783a6gjtlbvv3v.apps.googleusercontent.com:/oauth2redirect",
//            "grant_type": "authorization_code"
//        ]
//        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print("Token Response: \(response)")
//                    // Handle the response, e.g., store the access token
//                }
//            }
//        }
//        task.resume()
//    }
//}




//import UIKit
//import GoogleSignIn
//import SwiftUI
//class AppDelegate: NSObject, UIApplicationDelegate {
//    
////    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
////        GIDSignIn.sharedInstance.handle(url)
////        
////        // Notify the SwiftUI environment about the URL
////        NotificationCenter.default.post(name: .oauthRedirectReceived, object: url)
////        return true
////    }
//    
//    var window: UIWindow?
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//            // Handle the URL and pass it to the view model
//            if url.absoluteString.starts(with: "com.googleusercontent.apps") {
//                if let rootVC = window?.rootViewController as? UIHostingController<ContentView> {
//                    rootVC.rootView.viewModel.handleAuthorizationRedirect(url: url)
//                }
//                return true
//            }
//            return false
//        }
//    
//}
//
//
//
//import Foundation
//import FirebaseCore
//import FirebaseAuth
//import CryptoKit
//import AuthenticationServices
//import GoogleSignIn
//
//class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate  {
//  
//  // Password account sign in...
//
//  // Apple sign in...
//
//  func googleSignIn() {
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: clientID)
//        
//        // As you’re not using view controllers to retrieve the presentingViewController, access it through
//        // the shared instance of the UIApplication
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
//
//        // Start the sign in flow!
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { [unowned self] user, error in
//
//          if let error = error {
//              print("Error doing Google Sign-In, \(error)")
//              return
//          }
//
//          guard
//            let authentication = user?.authentication,
//            let idToken = authentication.idToken
//          else {
//            print("Error during Google Sign-In authentication, \(error)")
//            return
//          }
//
//          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                         accessToken: authentication.accessToken)
//            
//            
//            // Authenticate with Firebase
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let e = error {
//                    print(e.localizedDescription)
//                }
//               
//                print("Signed in with Google")
//            }
//        }
//    }
//}


//import UIKit
//import GoogleSignIn
//import FirebaseCore
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var window: UIWindow?
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        GIDSignIn.sharedInstance.handle(url)
//        return true
//    }
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        FirebaseApp.configure()
////        GIDSignIn.sharedInstance.clientID = FirebaseApp.app()?.options.clientID
//        return true
//    }
//}
