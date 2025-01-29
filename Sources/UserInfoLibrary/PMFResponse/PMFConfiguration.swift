//
//  PMFConfiguration.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import SwiftUI

/// A protocol that apps must implement to provide a custom image for PMF.
public protocol PMFConfiguration {
    /// The image name or SwiftUI `Image` the app wants to display.
    static var productMarketFitImage: Image { get }
}

import SwiftUI

/// A provider that stores and retrieves the app’s PMF configuration.
@MainActor
public class PMFConfigurationProvider {
    /// The app-defined PMF configuration.
    public static var configuration: PMFConfiguration.Type?

    /// Retrieves the image from the registered app configuration.
    public static var image: Image {
        return configuration?.productMarketFitImage ?? Image(systemName: "questionmark.circle")
    }
}
