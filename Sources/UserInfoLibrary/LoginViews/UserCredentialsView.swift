//
//  UserCredentialsView.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 2/3/25.
//
import SwiftUI

public enum FieldType: String, CaseIterable {
    case firstName = "First Name"
    case lastName = "Last Name"
    case email = "Email"
    case password = "Password"
    case companyName = "Company Name"
    case dogName = "Dog Name"

    /// Determines which fields should be visible based on login mode
    public func isVisible(forLoginMode isLogin: Bool) -> Bool {
        switch self {
        case .email, .password:
            return true // Always shown
        case .firstName, .lastName, .companyName, .dogName:
            return !isLogin // Only shown during registration
        }
    }
}

import SwiftUI

public struct UserCredentialsView: View {
    @Binding var isLoginMode: Bool
    @Binding var fields: [FieldType: String]
    @Binding var hiddenPassword: Bool
    var fieldOrder: [FieldType] // Parent-defined order

    public init(
        isLoginMode: Binding<Bool>,
        fields: Binding<[FieldType: String]>,
        hiddenPassword: Binding<Bool>,
        fieldOrder: [FieldType] // New: Defines which fields & order
    ) {
        self._isLoginMode = isLoginMode
        self._fields = fields
        self._hiddenPassword = hiddenPassword
        self.fieldOrder = fieldOrder
    }

    public var body: some View {
        VStack {
            ForEach(fieldOrder.filter { $0.isVisible(forLoginMode: isLoginMode) }, id: \.self) { field in
                if let binding = binding(for: field) {
                    if field == .password {
                        SecureCustomTextField(
                            placeholder: field.rawValue,
                            text: binding,
                            isSecure: $hiddenPassword,
                            placeholderColor: UIColor.lightGray
                        )
                    } else {
                        CustomTextField(
                            placeholder: field.rawValue,
                            text: binding,
                            placeholderColor: UIColor.lightGray
                        )
                    }
                }
            }
        }
    }

    private func binding(for field: FieldType) -> Binding<String>? {
        return Binding(
            get: { fields[field] ?? "" },
            set: { fields[field] = $0 }
        )
    }
}



// MARK: - UserCredentialsView
struct UserCredentialsViewOld: View {
    @Binding var isLoginMode: Bool
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var hiddenPassword: Bool
    @Binding var companyName: String

    var body: some View {
        Group {
            if !isLoginMode {
                CustomTextField(
                    placeholder: "First Name",
                    text: $firstName,
                    isSecure: .constant(false),
                    placeholderColor: UIColor.lightGray
                )
                CustomTextField(
                    placeholder: "Last Name",
                    text: $lastName,
                    isSecure: .constant(false),
                    placeholderColor: UIColor.lightGray
                )
            }
            CustomTextField(
                placeholder: "Email",
                text: $email,
                isSecure: .constant(false),
                placeholderColor: UIColor.lightGray
            )
            SecureCustomTextField(
                placeholder: "Password",
                text: $password,
                isSecure: $hiddenPassword,
                placeholderColor: UIColor.lightGray
            )
        }
    }
}
