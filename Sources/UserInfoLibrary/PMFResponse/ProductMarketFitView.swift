//
//  ProductMarketFitView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//
import SwiftUI

public struct ProductMarketFitView: View {
    
    let onYesTapped: () -> Void
    let onNoTapped: () -> Void
    let imageName: String
    
    var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
    }
    
    public init(imageName: String, onYesTapped: @escaping () -> Void, onNoTapped: @escaping () -> Void) {
        self.imageName = imageName
        self.onYesTapped = onYesTapped
        self.onNoTapped = onNoTapped
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            PMFConfigurationProvider.image
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 50)
            
            Text("Pleeeeese! 🙏")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
            
            Text("Help us to improve \(appName) to help people like you")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("by answering a few simple questions")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Spacer()
            
            Button(action: onYesTapped) {
                Text("Yes, Happy to help!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onNoTapped) {
                Text("No, I Don't want to help")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(.bottom, 50)
            }
        }
    }
}
