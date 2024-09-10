//
//  MobilyApp.swift
//  Mobily
//
//  Created by Mohamed Ragab on 06/09/2024.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct MobilyApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = BugSubmissionViewModel()

    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)

                .onOpenURL { url in
                    viewModel.handleAuthorizationRedirect(url: url)
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
