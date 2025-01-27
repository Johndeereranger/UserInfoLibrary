//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//

import SwiftUI

import SwiftUI

// Password Reset Light Grey Button Style
public struct PasswordResetLightGreyButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(.black) // Text color
            .font(.headline) // Uses the system's headline font
            .padding(.vertical, 10)
            .padding(.horizontal, 20) // Adjust padding as needed
            .background(Color(red: 229/255, green: 229/255, blue: 234/255)) // Custom light grey background
            .cornerRadius(10) // Rounded corners
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Slight scale down when pressed
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Action Button Blue Button Style
public struct ActionButtonBlueButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 20) // Adjust padding as needed
            .contentShape(Rectangle())
            .background(Color(red: 39/255, green: 68/255, blue: 114/255)) // Custom blue background
            .foregroundColor(.white) // Text color
            .font(.headline)
            .cornerRadius(10) // Rounded corners
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Slight scale down when pressed
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

//
//extension View {
//
//    
//    public func actionButtonBlueButtonStyle() -> some View {
//         self.modifier(ActionButtonBlueButtonStyle())
//     }
//    
//    public func resetPasswordLightGreyButtonStyle() -> some View {
//        self.modifier(PasswordResetLightGreyButtonStyle())
//    }
//}
//
//public struct PasswordResetLightGreyButtonStyle: ViewModifier {
//    public init() {}
//    public func body(content: Content) -> some View {
//        content
//            .frame(maxWidth: .infinity)
//            .foregroundColor(.black) // Text color
//            .font(.headline) // Uses the system's headline font
//            .padding(.vertical, 10)
//            
//            .padding(.horizontal, 20) // Adjust padding as needed
//            .background(Color(red: 229/255, green: 229/255, blue: 234/255)) // Custom green background
//            .cornerRadius(10) // Rounded corners
//            //.scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Optional: Slight scale down when pressed
//    }
//}
//
//public struct ActionButtonBlueButtonStyle: ViewModifier {
//    public init() {}
//    public func body(content: Content) -> some View {
//        content
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 10)
//            .padding(.horizontal, 20) // Adjust padding as needed
//            .contentShape(Rectangle())
//            .background(Color(red: 39/255, green: 68/255, blue: 114/255)) // Custom green background
//            .foregroundColor(.white) // Text color
//            .font(.headline)
//            .cornerRadius(10) // Rounded corners
//            //.scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Optional: Slight scale down when pressed
//    }
//}
