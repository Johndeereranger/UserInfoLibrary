//
//  SwiftUIView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/30/25.
//
import SwiftUI
import FirebaseFirestore

import SwiftUI

public struct PMFStatusView: View {
    @StateObject private var viewModel = PMFStatusViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading PMF Data...")
                } else {
                    List {
                        Section(header: Text("🔹 User Info")) {
                            Text("User ID: \(viewModel.userID ?? "Not Found")")
                        }

                        Section(header: Text("📊 PMF Responses")) {
                            if let error = viewModel.pmfErrorMessage {
                                Text("⚠️ \(error)").foregroundColor(.red)
                            } else if viewModel.pmfResponses.isEmpty {
                                Text("No PMF responses found.")
                            } else {
                                ForEach(viewModel.pmfResponses, id: \.sessionID) { response in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("🆔 Session ID: \(response.sessionID)")
                                        if let feedback = response.feedback {
                                            Text("💬 Feedback: \(feedback)")
                                        }
                                        if let benefit = response.mainBenefit {
                                            Text("🏆 Main Benefit: \(benefit)")
                                        }
                                        if let suggestion = response.improvementSuggestions {
                                            Text("🔧 Improvement: \(suggestion)")
                                        }
                                        if let usage = response.usageCountAtSurvey {
                                            Text("📈 Usage Count: \(usage)")
                                        }
                                        Text("📅 Answered At: \(response.answeredAt)")
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }

                        Section(header: Text("💾 UserDefaults Data")) {
                            if viewModel.userDefaultsData.isEmpty {
                                Text("No stored UserDefaults data.")
                            } else {
                                ForEach(viewModel.userDefaultsData.keys.sorted(), id: \.self) { key in
                                    Text("\(key): \(String(describing: viewModel.userDefaultsData[key]!))")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("PMF Debug Info")
            .task {
                await viewModel.fetchPMFResponses()
            }
        }
    }
}

