//
//  Error.swift
//  Example
//
//  Created by Adam Waite on 29/10/2016.
//  Copyright © 2016 adamjwaite.co.uk. All rights reserved.
//

import Foundation
import Validator

struct ValidationError: Error {
    
    public let message: String
    
    public init(message m: String) {
        message = m
    }
}

class ValidationObj {
    var error:ValidationError?
    var isValid:Bool = false
    init(isValid:Bool, error:ValidationError?){
        self.isValid = isValid
        self.error = error
    }
    func message() -> String? {
        return self.error?.message
    }
}

class ValidValidationObj: ValidationObj {
    convenience init() {
        self.init(isValid: true, error: nil)
    }
}
class InvalidValidationObj: ValidationObj {
    convenience init(_ error:ValidationError?) {
        self.init(isValid: false, error: error)
    }
}


enum ValidationErrors: String {
    case emailInvalid = "Invalid email"
    case emailRequired = "Email is required"
    case firstNameRequired = "First name is required"
    case lastNameRequired = "Last name is required"
    case passwordInvalid = "Password is invalid"
    case passwordRequired = "Password is required"
    case passwordMatch = "Password do not match"
    case passwordRequirement = "Min 8 characters with 1 number"
    case min8Chars = "8 Chars"
    case min1Digit = "1 Digi"
    case min1Cap = "1 Cap Letter"
    case min1SpecialChar = "1 Special Char"
    case required = "Required"
    case digits = "Digits"
    
    func message() -> ValidationError {
        return ValidationError(message: self.rawValue)
    }
}

public struct ContainsSpecialCharacterValidationPattern: ValidationPattern {
    
    public init() {
        
    }
    
    public var pattern: String {
        return ".*[^A-Za-z0-9].*"
    }
}

public struct MyValidationRuleRequired<T>: ValidationRule {
    
    public typealias InputType = T
    
    public let error: Error
    
    /**
     
     Initializes a `ValidationRuleComparison` with an error describing a failed
     validation.
     
     - Parameters:
     - error: An error describing a failed validation.
     
     */
    public init(error: Error) {
        self.error = error
    }
    
    /**
     
     Validates the input.
     
     - Parameters:
     - input: Input to validate.
     
     - Returns:
     true if non-nil.
     
     */
    public func validate(input: T?) -> Bool {
        if input != nil, let value = input as? String {
            return !value.isEmpty
        }else{
            return false
        }
    }
    
}
