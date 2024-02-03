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
    
    
    mutating func validateName(input name: String) {
        if(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            hasNameError = true
            nameErrorDescription = "This field is required."
        } else {
            hasNameError = false
            nameErrorDescription = ""
        }
    }
    
    mutating func validatePrice(input price: Float?) {
        if(price == nil) {
            hasPriceError = true
            priceErrorDescription = "This field is required."
        } else {
            hasPriceError = false
            priceErrorDescription = ""
        }
    }
}
