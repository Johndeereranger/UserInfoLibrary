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
    @Binding public var isSecure: Bool
    public var placeholderColor: UIColor
    
    public init(
          placeholder: String,
          text: Binding<String>,
          isSecure: Binding<Bool>,
          placeholderColor: UIColor
      ) {
          self.placeholder = placeholder
          self.text = text
          self._isSecure = isSecure
          self.placeholderColor = placeholderColor
      }

    public func makeUIView(context: Context) -> UITextField {
           let textField = UITextField(frame: .zero)
           textField.isSecureTextEntry = isSecure
           textField.attributedPlaceholder = NSAttributedString(
               string: placeholder,
               attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
           )
        
           textField.backgroundColor = UIColor.secondarySystemBackground
            textField.textColor = UIColor(named: "TextFieldTextColor") ?? .label // Define this color in your asset catalog to adapt to dark mode
           textField.borderStyle = .roundedRect // Optional, for styling
           textField.autocapitalizationType = .none
           textField.keyboardType = isSecure ? .default : .emailAddress
           
           textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
           return textField
       }
    
    
//    func updateUIView(_ uiView: UITextField, context: Context) {
//        uiView.text = text.wrappedValue
//        uiView.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
//    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text.wrappedValue
        uiView.isSecureTextEntry = isSecure // Ensure this updates with the state
        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        uiView.keyboardType = isSecure ? .default : .emailAddress // Adjust keyboard type if necessary

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
}

