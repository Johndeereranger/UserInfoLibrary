//
//  PMFResponseListViewModel.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/6/25.
//

import Foundation


@MainActor
class PMFResponseListViewModel: ObservableObject {
    @Published var responses: [PMFResponse] = []
    @Published var isLoading = true

    func fetchResponses() async {
        isLoading = true
        let fetchedResponses = await PMFDataManager.shared.fetchAllPMFData()
        DispatchQueue.main.async {
            self.responses = fetchedResponses
            self.isLoading = false
        }
    }

    func deleteResponse(sessionID: String) async {
        guard let userID = PMFConfigurationProvider.userID else { return }
        await PMFDataManager.shared.deletePMFResponse(userID: userID, sessionID: sessionID)

        // Update UI after deletion
        await fetchResponses()
    }
}
