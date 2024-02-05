//
//  ProductValidation.swift
//  
//
//  Created by Dong on 2024/2/3.
//

import Foundation

struct ProductValidation {
    
    var hasNameError = false
    var hasPriceError = false
    
    var nameErrorDescription = ""
    var priceErrorDescription = ""
    
    
    mutating func validateName(input name: String) -> Bool {
        if(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            hasNameError = true
            nameErrorDescription = "This field is required."
            return false
        } else {
            hasNameError = false
            nameErrorDescription = ""
            return true
        }
    }
    
    mutating func validatePrice(input price: Float) -> Bool {
        if(price.isEqual(to: 0)) {
            hasPriceError = true
            priceErrorDescription = "0 is not acceptable for price."
            return false
        } else {
            hasPriceError = false
            priceErrorDescription = ""
            return true
        }
    }
}
