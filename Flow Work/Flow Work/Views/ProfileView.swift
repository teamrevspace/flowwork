//
//  ProfileView.swift
//  Flow Work
//
//  Created by Allen Lin on 10/22/23.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var displayName: String = ""
    @State private var image: NSImage? = nil
    @State private var showingImagePicker: Bool = false
    @State private var inputImage: NSImage? = nil
    @State private var updatedPhoto: Bool = false
    @State private var updatedName: Bool = false
    @State private var authMethodImages: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            if (viewModel.authState.isSignedIn) {
                Group {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack {
                                if let nsImage = inputImage {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                } else {
                                    PlaceholderAvatar()
                                }
                                Button("Change Photo") {
                                    viewModel.selectPhoto() { selectedImage in
                                        if selectedImage != nil {
                                            self.inputImage = selectedImage
                                            self.updatedPhoto = true
                                        }
                                    }
                                }
                            }
                        }
                        HStack {
                            TextField("Display Name", text: $displayName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: self.displayName) { _ in
                                    self.updatedName = true
                                }
                        }
                        HStack {
                            if let emailAddress = viewModel.authState.currentUser?.emailAddress {
                                Text(emailAddress)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                HStack(spacing: 5) {
                                    ForEach(self.authMethodImages, id: \.self) { authMethodImage in
                                        SmallIcon(image: authMethodImage)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
            HStack(spacing: 10) {
                FButton(text: "Back") {
                     viewModel.returnToHome()
                }
                FButton(text: "Save") {
                    if let inputImage = self.inputImage,
                       let imageData = inputImage.tiffRepresentation, updatedPhoto {
                        self.viewModel.updateProfilePicture(imageData: imageData)
                    }
                    if !self.displayName.isEmpty, updatedName {
                        viewModel.updateDisplayName(name: self.displayName)
                    }
                     viewModel.returnToHome()
                }
            }
        }
        .padding()
        .standardFrame()
        .onAppear {
            self.updatedPhoto = false
            self.updatedName = false
            if let name = viewModel.authState.currentUser?.name {
                self.displayName = name
            }
            if let avatarURL = viewModel.authState.currentUser?.avatarURL {
                DispatchQueue.global(qos: .background).async {
                    if let image = NSImage(contentsOf: avatarURL) {
                        DispatchQueue.main.async {
                            self.inputImage = image
                        }
                    }
                }
            }
            self.authMethodImages = viewModel.getAuthImages()
        }
    }
}
