//
//  BugSubmissionView.swift
//  Mobily
//
//  Created by Mohamed Ragab on 06/09/2024.
//

import SwiftUI

struct BugSubmissionView: View {
    
    @StateObject private var viewModel = BugSubmissionViewModel()
    @State private var showingImagePicker = false
    @State private var showSignInAlert = false
    
    
    var body: some View {
        
        ZStack {
            if #available(iOS 17.0, *) {
                Color(ColorsEnum.Bg.color).ignoresSafeArea()
            } else {
                // Fallback on earlier versions
            }
            
            ScrollView {
                
                VStack (spacing : 20){
                    Text("Submit Bug")
                        .font(.custom(FontsEnum.Bold.font, size: 22))
                        .foregroundColor(.black)
                    
                    VStack {
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Select Screenshot")
                                .foregroundColor(ColorsEnum.Main.color)
                            
                        }
                        .padding()
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(selectedImage: $viewModel.selectedImage)
                        }
                        
                        // Display selected image if available
                        if let selectedImage = viewModel.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .frame(maxWidth: 300 , maxHeight: 300)
                                .scaledToFit()
                                .cornerRadius(20)  // Apply corner radius
                                .clipped()         // Clip the image to its bounds
                                .padding()
                        } else {
                            Text("No Image Selected")
                                .padding()
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity , maxHeight: 320)
                    .background(.white)
                    .overlay(
                        RoundedCorners(radius: 20, corners: .allCorners)
                        //                                .stroke(Color(ColorsEnum.Second.color), lineWidth: 1)
                            .stroke(.gray , lineWidth: 1)
                        
                    )
                    
                    
                    
                    VStack {
                        ZStack(alignment: .topLeading) {
                            
                            TextEditor(text: $viewModel.description)
                                .font(.custom(FontsEnum.Regular.font, size: 18))
                                .padding(4)
                            
                            if viewModel.description.isEmpty {
                                Text("Enter your description here...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 10)
                            }
                            
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .background(.white)
                    .overlay(
                        RoundedCorners(radius: 10, corners: .allCorners)
                        //                                .stroke(Color(ColorsEnum.Second.color), lineWidth: 1)
                            .stroke(.gray , lineWidth: 1)
                        
                    )
                    
                    
                    Button(action: {
                        viewModel.submitBug()
                        
                        //                        if viewModel.isAuthorized {
                        //                            viewModel.submitBug()
                        //                        } else {
                        //                            showSignInAlert = true
                        //                        }
                        
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(ColorsEnum.Main.color).cornerRadius(10)
                            .foregroundColor(.white)
                            .font(.custom(FontsEnum.Bold.font, size: 18))
                            .padding()
                    }
                    .padding()
                    .alert(isPresented: $showSignInAlert) {
                        Alert(title: Text("Sign-In Required"), message: Text("You need to sign in to submit a bug."), dismissButton: .default(Text("OK")))
                    }
                    .disabled(viewModel.isSubmitting)
                    
                    if viewModel.isSubmitting {
                        ProgressView("Submitting...")
                            .padding()
                    }
                    
                    if let error = viewModel.submissionError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    if viewModel.submissionSuccess {
                        Text("Submission Successful!")
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .padding()
            }
        }
    }
}


#Preview {
    BugSubmissionView()
}
