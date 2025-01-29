//
//  PMFViewer.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//
import SwiftUI

public struct PMFViewer: View {
    @State private var pmfResponses: [PMFResponse] = []
    @State private var isLoading = true

    public init() {}

    public var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading PMF Data...")
                } else if pmfResponses.isEmpty {
                    Text("No PMF Data Found")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    List(pmfResponses, id: \.sessionID) { response in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Session ID: \(response.sessionID)")
                                .font(.headline)

                            if let feedback = response.feedback {
                                Text("Feedback: \(feedback)")
                                    .font(.subheadline)
                            }

                            if let mainBenefit = response.mainBenefit {
                                Text("Main Benefit: \(mainBenefit)")
                                    .font(.subheadline)
                            }

                            if let improvementSuggestions = response.improvementSuggestions {
                                Text("Suggestions: \(improvementSuggestions)")
                                    .font(.subheadline)
                            }

                            if let usageCount = response.usageCountAtSurvey {
                                Text("Usage Count: \(usageCount)")
                                    .font(.subheadline)
                            }

                            Text("Answered At: \(response.answeredAt.formatted())")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("PMF Responses")
            .task {
                await fetchPMFData()
            }
        }
    }

    private func fetchPMFData() async {
        isLoading = true
        let responses = await PMFDataManager.shared.fetchAllPMFData()
        DispatchQueue.main.async {
            self.pmfResponses = responses
            self.isLoading = false
        }
    }
}

// MARK: - Preview
#if DEBUG
struct PMFViewer_Previews: PreviewProvider {
    static var previews: some View {
        PMFViewer()
            .previewLayout(.sizeThatFits)
    }
}
#endif
