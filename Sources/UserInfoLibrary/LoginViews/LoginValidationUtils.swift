//
//  File.swift
//  UserInfoLibrary
//
//  Created by Byron Smith on 1/27/25.
//

import Foundation


public struct LoginValidationUtils {
    public static func isPasswordValid(_ password : String) -> Bool {
        
      //  let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^.{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    public static func isPasswordSimple(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^.*(?=.{6,}).*$")
        return passwordTest.evaluate(with: password)
    }
    
    public static func isEmailValid(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    public static func isPhoneNumberValid(phoneNumber:String) -> Bool {
        let phoneNumberRegEx = "^\\d{3}-?\\d{3}-?\\d{4}$"

        let phoneNumberPred = NSPredicate(format:"SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberPred.evaluate(with: phoneNumber)
    }
    
    public static func isNameValid(_ name: String) -> Bool {
        let regex = "^(?=.{2,20}$)[A-Za-z0-9#$&]+(?: [A-Za-z0-9#$&]+)*$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: name)
    }
    
    public static func isStringValid(_ input: String) -> Bool {
        // This regex ensures the string is 4 to 20 characters long, contains only letters, numbers, or #$&, and may include spaces in the middle
        let regex = "^(?=.{2,20}$)[A-Za-z0-9#$&]+(?: [A-Za-z0-9#$&]+)*$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: input)
    }
}
