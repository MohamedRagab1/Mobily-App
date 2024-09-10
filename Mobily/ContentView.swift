//
//  ContentView.swift
//  Mobily
//
//  Created by Mohamed Ragab on 06/09/2024.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn

struct ContentView: View {
    
    @State var showSplash : Bool = true
    //    @State private var imageOffset: CGFloat = -UIScreen.main.bounds.height / 2 // Start above the screen
    @State private var imageSize: CGFloat = 10 // Starting size for both width and height
    
    @StateObject private var viewModel = BugSubmissionViewModel()
    @State private var isSignedIn = false
    
    // Define the scope you need.
    let driveScope = "https://www.googleapis.com/auth/drive.readonly"

    
    
    var body: some View {
        
        ZStack {
            if #available(iOS 17.0, *) {
                Color(ColorsEnum.Bg.color).ignoresSafeArea()
            } else {
                // Fallback on earlier versions
            }
            
            NavigationView {
                VStack {
                    
                    if isSignedIn {
                        NavigationLink(destination: BugSubmissionView()) {
                            Text("Submit a Bug")
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(ColorsEnum.Main.color).cornerRadius(10)
                                .foregroundColor(.white)
                                .font(.custom(FontsEnum.Bold.font, size: 18))
                                .padding()
                        }
                    } else {
                        
                        Button(action: {
                            if let authorizationURL = viewModel.getAuthorizationURL() {
                                UIApplication.shared.open(authorizationURL, options: [:], completionHandler: nil)
                            }
                        }) {
                            Text("Sign in with Google")
                        }
                        
//                        GoogleSignInButton {
////                            viewModel.openAuthorizationURL()
//
//                            GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController() ) { signInResult, error in
//                                // check `error`; do something with `signInResult`
//                                
//                                if let error = error {
//                                    print("Google Sign-In Error: \(error.localizedDescription)")
//                                    return
//                                }
//                                
//                                guard let user = signInResult else {
//                                    print("Google Sign-In User Error")
//                                    return
//                                }
//                                
//                                // Extract the authentication object and tokens
//                                let accessToken = user.user.accessToken.tokenString
//                                print("accessToken : \(accessToken)")
//                                print("code : \(user.user.idToken?.tokenString)")
//
//
//                                UserDefaults.standard.set(accessToken, forKey: "accessToken")
//                                UserDefaults.standard.set(isSignedIn, forKey: "isSignedIn")
//                                
////                                viewModel.exchangeAuthorizationCodeForToken(code: "4")
//
//                                self.isSignedIn = true
//
//                            }
//                        }
                    }
                }
                .navigationTitle("Bug Tracker")
                .padding()
                .onReceive(NotificationCenter.default.publisher(for: .oauthRedirectReceived)) { notification in
                    if let url = notification.object as? URL {
                        viewModel.handleAuthorizationRedirect(url: url)
                    }
                }                
            }
            
            if showSplash {
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize , height: imageSize)
                    //                        .offset(y: imageOffset) // Set the offset of the image
                        .onAppear{
                            // Animate the image to move from top to center after a short delay
                            withAnimation(.easeInOut(duration: 3.0)) {
                                //                                imageOffset = 0 // Move image to the center (offset is 0)
                                imageSize = 300
                            }
                            
                            // Hide the image after 5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4 , execute: {
                                showSplash = false
                            })
                            
                        }
                }
                .frame(maxWidth: .infinity , maxHeight: .infinity)
                .background(ColorsEnum.Bg.color)
                
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

#Preview {
    ContentView()
}
