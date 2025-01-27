//
//  SwiftUIView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//
import SwiftUI

// MARK: - LoginView
public struct LoginView: View {
    public let didCompleteLoginProcess: () -> ()
    
    @StateObject private var loginViewModel = LoginViewModel.instance
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var hiddenPassword = true
    @Environment(\.colorScheme) var colorScheme
    @State private var shouldShowImagePicker = false
    @State private var image: UIImage?
    @State private var loginStatusMessage = ""

    public init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Picker for Login or Create Account
                    LoginPickerView(isLoginMode: $isLoginMode)
                    
                    // User Credential Inputs
                    UserCredentialsView(
                        isLoginMode: $isLoginMode,
                        firstName: $firstName,
                        lastName: $lastName,
                        email: $email,
                        password: $password,
                        hiddenPassword: $hiddenPassword
                    )
                    
                    // Action Button
                    ActionButtonView(isLoginMode: isLoginMode) {
                        handleAction()
                    }
                    
                    // Password Reset
                    if isLoginMode {
                        PasswordResetButtonView {
                            handlePasswordReset()
                        }
                    }
                    
                    // Status Message
                    Text(loginStatusMessage)
                        .foregroundColor(colorScheme == .dark ? .white : .red)
                    
                    // App Logo
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
//        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
//            ImagePicker(image: $image)
//        }
    }
    
    // MARK: - Actions
    private func handleAction() {
        loginStatusMessage = ""
        // Call ViewModel logic to handle login or account creation
        loginViewModel.handleAction(
            isLoginMode: isLoginMode,
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        ) { result in
            switch result {
            case .success:
                didCompleteLoginProcess()
            case .failure(let error):
                loginStatusMessage = error.localizedDescription
            }
        }
    }
    
    private func handlePasswordReset() {
        loginViewModel.resetPassword(email: email) { error in
            if let error = error {
                loginStatusMessage = error.localizedDescription
            } else {
                loginStatusMessage = "Password reset email sent successfully."
            }
        }
    }
}

// MARK: - LoginPickerView
struct LoginPickerView: View {
    @Binding var isLoginMode: Bool

    var body: some View {
        Picker(selection: $isLoginMode, label: Text("Picker here")) {
            Text("Login").tag(true)
            Text("Create Account").tag(false)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

// MARK: - UserCredentialsView
struct UserCredentialsView: View {
    @Binding var isLoginMode: Bool
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var hiddenPassword: Bool

    var body: some View {
        Group {
            if !isLoginMode {
                CustomTextField(
                    placeholder: "First Name",
                    text: $firstName,
                    isSecure: .constant(false),
                    placeholderColor: UIColor.lightGray
                )
                CustomTextField(
                    placeholder: "Last Name",
                    text: $lastName,
                    isSecure: .constant(false),
                    placeholderColor: UIColor.lightGray
                )
            }
            CustomTextField(
                placeholder: "Email",
                text: $email,
                isSecure: .constant(false),
                placeholderColor: UIColor.lightGray
            )
            SecureCustomTextField(
                placeholder: "Password",
                text: $password,
                isSecure: $hiddenPassword,
                placeholderColor: UIColor.lightGray
            )
        }
    }
}

// MARK: - ActionButtonView
struct ActionButtonView: View {
    var isLoginMode: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(isLoginMode ? "Log In" : "Create Account")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        }
        //.blueButtonStyle()
    }
}

// MARK: - PasswordResetButtonView
struct PasswordResetButtonView: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text("Email Password Reset")
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        }
        //.lightGreyButtonStyle()
    }
}
