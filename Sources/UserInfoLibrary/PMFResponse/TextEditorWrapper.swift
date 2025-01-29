//
//  TextEditorWrapper.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/29/25.
//

import SwiftUI

public struct TextEditorWrapper: View {
    public let placeholder: String
    @Binding public var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
            }
            TextEditor(text: $text)
                .padding(4)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#if DEBUG
struct TextEditorWrapper_Previews: PreviewProvider {
    @State static var text = ""

    static var previews: some View {
        TextEditorWrapper(placeholder: "Type here...", text: $text)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
