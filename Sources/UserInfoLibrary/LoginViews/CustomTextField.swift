//
//  SwiftUIView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//


import SwiftUI
import UIKit

public struct CustomTextField: UIViewRepresentable {
    public var placeholder: String
    public var text: Binding<String>
    public var placeholderColor: UIColor
    
    public init(
          placeholder: String,
          text: Binding<String>,
          placeholderColor: UIColor
      ) {
          self.placeholder = placeholder
          self.text = text
          self.placeholderColor = placeholderColor
      }

    public func makeUIView(context: Context) -> UITextField {
           let textField = UITextField(frame: .zero)
           textField.attributedPlaceholder = NSAttributedString(
               string: placeholder,
               attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
           )
        
           textField.backgroundColor = UIColor.secondarySystemBackground
            textField.textColor = UIColor(named: "TextFieldTextColor") ?? .label // Define this color in your asset catalog to adapt to dark mode
           textField.borderStyle = .roundedRect // Optional, for styling
           textField.autocapitalizationType = .none
        if placeholder == "Email" || placeholder == "Email Address" {
            textField.keyboardType = .emailAddress
        } else {
            textField.keyboardType = .default
        }
           
        
        textField.textContentType = getTextContentType(for: placeholder)
        print(#function,placeholder, textField.textContentType ?? .flightNumber)
           
           textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
           return textField
       }
    
    
//    func updateUIView(_ uiView: UITextField, context: Context) {
//        uiView.text = text.wrappedValue
//        uiView.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
//    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text.wrappedValue
        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        if placeholder == "Email" || placeholder == "Email Address" {
            uiView.keyboardType = .emailAddress
        } else {
            uiView.keyboardType = .default
        }

        // It's also a good idea to add or update other properties here if they should change with the state
        uiView.addTarget(context.coordinator, action: #selector(CustomTextFieldCoordinator.textFieldDidChange(_:)), for: .editingChanged)
    }


    public class CustomTextFieldCoordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
             self.text.wrappedValue = textField.text ?? ""
         }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }
    }

    public func makeCoordinator() -> CustomTextFieldCoordinator {
        return CustomTextFieldCoordinator(text: text)
    }
    
    private func getTextContentType(for placeholder: String) -> UITextContentType? {
        switch placeholder.lowercased() {
        case "first name":
            return .givenName // Suggests the user's first name
        case "last name":
            return .familyName // Suggests the user's last name
        case "email", "email address":
            return .emailAddress // Suggests stored email
        case "phone number":
            return .telephoneNumber // Suggests stored phone number
        case "company name":
            return .organizationName // Suggests stored company name
        default:
            return nil // No specific suggestion
        }
    }

}

