//
//  MultipleChoiceQuestionView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//
import SwiftUI

public struct MultipleChoiceQuestionView: View {
    let onNextTapped: (String) -> Void
    @State private var selectedOption: String? = nil
    @State private var showError: Bool = false

    private let question = "How would you feel if you could no longer use our product?"
    private let options = ["Very Disappointed", "Somewhat Disappointed", "Not Disappointed"]

    public init(onNextTapped: @escaping (String) -> Void) {
        self.onNextTapped = onNextTapped
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(question)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding(.horizontal, 16)
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                    showError = false
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(selectedOption == option ? .white : .blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedOption == option ? Color.blue : Color.clear)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()

            if showError {
                Text("Please select an option before proceeding.")
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.bottom, 10)
            } else {
                Text("One More Slide")
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                if let feedback = selectedOption {
                    showError = false
                    PMFManager.instance.storePMFResponse(feedback: feedback)
                    onNextTapped(feedback)
                } else {
                    showError = true
                }
            }) {
                Text("Next")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct MultipleChoiceQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        MultipleChoiceQuestionView { selectedFeedback in
            print("User selected:", selectedFeedback)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
