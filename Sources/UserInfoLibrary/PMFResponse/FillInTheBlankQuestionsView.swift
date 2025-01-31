//
//  FillInTheBlankQuestionsView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import SwiftUI

public struct FillInTheBlankQuestionsView: View {
    let onSubmitTapped: () -> Void
    @State private var mainBenefit: String = ""
    @State private var improvementSuggestions: String = ""
    @State private var showError: Bool = false
    @FocusState private var focusedField: FocusedField?

    public enum FocusedField {
        case mainBenefit, improvementSuggestions
    }

    public init(onSubmitTapped: @escaping () -> Void) {
        self.onSubmitTapped = onSubmitTapped
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("What is the main benefit you receive from the app?")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                    .padding(.horizontal, 16)

                TextEditorWrapper(placeholder: "Enter your answer here", text: $mainBenefit)
                    .frame(height: 120)
                    .padding(.horizontal, 40)
                    .focused($focusedField, equals: .mainBenefit)

                Text("How can we improve the app for you?")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .padding(.horizontal, 16)

                TextEditorWrapper(placeholder: "Enter your suggestions here", text: $improvementSuggestions)
                    .frame(height: 120)
                    .padding(.horizontal, 40)
                    .focused($focusedField, equals: .improvementSuggestions)

                if showError {
                    Text("Please complete both fields.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.bottom, 10)
                }

                Button(action: {
                    if mainBenefit.isEmpty || improvementSuggestions.isEmpty {
                        showError = true
                    } else {
                        showError = false
                        PMFManager.instance.storePMFResponse(mainBenefit: mainBenefit, improvementSuggestions: improvementSuggestions)
                        onSubmitTapped()
                    }
                }) {
                    Text("Submit")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 10)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil // Dismiss keyboard
                }
            }
        }
        .onTapGesture {
            focusedField = nil // Dismiss keyboard when tapping outside
        }
    }
}
