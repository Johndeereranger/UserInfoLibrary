//
//  PMFResponseListView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/6/25.
//

import SwiftUI
import SwiftUI

public struct PMFResponseListView: View {
    @StateObject private var viewModel = PMFResponseListViewModel()
    public init() {}
   public var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading PMF Data...")
                } else if viewModel.responses.isEmpty {
                    Text("No PMF Data Found")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    List {
                        ForEach(viewModel.responses, id: \.sessionID) { response in
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
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteResponse(sessionID: response.sessionID)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("PMF Responses")
            .task {
                await viewModel.fetchResponses()
            }
        }
    }
}
