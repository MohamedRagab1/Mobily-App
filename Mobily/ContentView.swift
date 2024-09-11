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
                        
                        // User is signed in, show sign-out button
                        Button("Sign Out") {
                            signOut()
                        }
                        
                    } else {
                        
                        //                        Button(action: {
                        //                            if let authorizationURL = viewModel.getAuthorizationURL() {
                        //                                UIApplication.shared.open(authorizationURL, options: [:], completionHandler: nil)
                        //                            }
                        //                        }) {
                        //                            Text("Sign in with Google")
                        //                        }
                        //
                        GoogleSignInButton {
                            GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController() ) { signInResult, error in
                                // check `error`; do something with `signInResult`
                                if let error = error {
                                    print("Google Sign-In Error: \(error.localizedDescription)")
                                    return
                                }
                                guard let user = signInResult else {
                                    print("Google Sign-In User Error")
                                    return
                                }
                                // Extract the authentication object and tokens
                                let accessToken = user.user.accessToken.tokenString
                                print("accessToken : \(accessToken)")
                                
                                
                                self.isSignedIn = true
                                
                                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                                UserDefaults.standard.set(isSignedIn, forKey: "isSignedIn")
                                
                            }
                        }
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
        .onAppear {
            // Check if user is already signed in
            isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
        }
        
    }
    
    private func signOut() {
        GIDSignIn.sharedInstance.signOut()
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.set(false, forKey: "isSignedIn")
        self.isSignedIn = false
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
