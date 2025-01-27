//
//  SwiftUIView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//

import SwiftUI


public struct SecureCustomTextField: UIViewRepresentable {
    public var placeholder: String
    @Binding public var text: String
    @Binding public var isSecure: Bool
    public var placeholderColor: UIColor
    
    public init(
        placeholder: String,
        text: Binding<String>,
        isSecure: Binding<Bool>,
        placeholderColor: UIColor = .lightGray
    ) {
        self.placeholder = placeholder
        self._text = text
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
        textField.textColor = UIColor(named: "TextFieldTextColor") ?? .label
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = isSecure ? .default : .emailAddress
        textField.rightViewMode = .always
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.isSelected = isSecure // Initially set based on isSecure
        button.addTarget(context.coordinator, action: #selector(Coordinator.toggleSecureEntry), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        textField.rightView = button
        
        return textField
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = $text.wrappedValue
        uiView.isSecureTextEntry = isSecure
        // Update button state
        if let button = uiView.rightView as? UIButton {
            button.isSelected = isSecure
        }
        
        uiView.addTarget(context.coordinator, action: #selector(SecureCustomTextFieldCoordinator.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    public func makeCoordinator() -> SecureCustomTextFieldCoordinator {
        SecureCustomTextFieldCoordinator(text: $text, isSecure: $isSecure)
    }
    
    public class SecureCustomTextFieldCoordinator: NSObject, UITextFieldDelegate {
        public var text: Binding<String>
        public var isSecure: Binding<Bool>
        
        public init(text: Binding<String>, isSecure: Binding<Bool>) {
            self.text = text
            self.isSecure = isSecure
        }
        
        @objc public func textFieldDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
        }
        
        @objc public func toggleSecureEntry(button: UIButton) {
            self.isSecure.wrappedValue.toggle()
            button.isSelected = self.isSecure.wrappedValue
        }
    }
}

