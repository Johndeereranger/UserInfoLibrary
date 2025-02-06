//
//  PMFResponseListViewModel.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/6/25.
//

import Foundation


@MainActor
public class PMFResponseListViewModel: ObservableObject {
    @Published public var responses: [PMFResponse] = []
    @Published public var isLoading = true

    public func fetchResponses() async {
        isLoading = true
        let fetchedResponses = await PMFDataManager.shared.fetchAllPMFData()
        DispatchQueue.main.async {
            self.responses = fetchedResponses
            self.isLoading = false
        }
    }

    public func deleteResponse(sessionID: String) async {
        guard let userID = PMFConfigurationProvider.userID else { return }
        await PMFDataManager.shared.deletePMFResponse(sessionID: sessionID)

        // Update UI after deletion
        await fetchResponses()
    }
}
