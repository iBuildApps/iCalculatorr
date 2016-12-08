//
//  CalculatorBrainDescription.swift
//  iCalculator
//
//  Created by Sherlock on 11/22/16.
//  Copyright © 2016 Joseph Kubaivanove. All rights reserved.
//

import Foundation

class CalculatorBrainDescription
{
    var description: String = ""
    
    var accumulatorBeforeOperation: String?
    
    var pending: Bool = false
    
    var pendingVar = false
    
    func clear() {
        description = ""
        accumulatorBeforeOperation = nil
        pending = false
    }
    
    private let arrayOfOperations = ["sin(x)","cos(x)","tan(x)","sinh(x)","cosh(x)","tanh(x)","ln(x)","log₁₀(x)"]
    
    func format()
    {
        if let range = description.range(of: "＝") {
            if description.endIndex != range.upperBound {
                description = description.replacingOccurrences(of: "＝", with: "")
            }
        }

        description = description.replacingOccurrences(of: "x!", with: "!")
        
        formatSignOperation()
        formatBinaryOperation()
        formatExponentOperation()
        formatRootOperation()
        formatPowerOperation()
        formatOperations()
        if pendingVar {
            pendingVar = false
        }
    }
    
    private func formatBinaryOperation() {
        var stringsSeparated = description.components(separatedBy: ["×", "÷"])
        if pending && stringsSeparated.count > 1 {
            if let range = stringsSeparated[stringsSeparated.count-2].rangeOfCharacter(from: ["+","−"], options: .backwards) {
                if description[description.index(after:range.upperBound)] != ")" && stringsSeparated.last?.characters.last != "+" && stringsSeparated.last?.characters.last != "−" {
                    description.insert("(", at: description.startIndex)
                    description.insert(")", at: description.index(before: description.endIndex))
                }
            }
            description = description.replacingOccurrences(of: ")ˣ", with: "ˣ)")
            if description.range(of: "x)") != nil && (arrayOfOperations.map { string in description.range(of:string) }.flatMap {$0}).first == nil {
                description.remove(at: description.startIndex)
                description = description.replacingOccurrences(of: "x)ʸ", with: "xʸ")
                description = description.replacingOccurrences(of: "x)", with: "")
                
            }
        }
    }
    
    private func unaryOperationIsPartOfBinaryOperatin() {
        if let range = description.rangeOfCharacter(from: ["×","÷","+","−"], options: .backwards, range: nil) {
            description.removeSubrange(range.upperBound..<description.endIndex)
        }
    }
    
    private func formatExponentOperation() {
        if let range = description.range(of: "2ˣ") ?? description.range(of: "eˣ") ?? description.range(of:"10ˣ") {
            let mathSymbol = description.substring(with: range.lowerBound..<description.index(before: range.upperBound))
            if !pending {
                pendingVar ? description = mathSymbol + "ᴹ" : (description = mathSymbol + exponentize(str: accumulatorBeforeOperation!))
            } else {
                unaryOperationIsPartOfBinaryOperatin()
                pendingVar ? (description = description +  mathSymbol + "ᴹ") : (description = description +  mathSymbol + exponentize(str: accumulatorBeforeOperation!))
            }
        }
    }
    
    private func formatSignOperation() {
        if description.range(of: "±") != nil {
            if !pending {
                description =  "\(-Double(accumulatorBeforeOperation!)!)"
            } else {
                unaryOperationIsPartOfBinaryOperatin()
                description = description +  "\(-Double(accumulatorBeforeOperation!)!)"
            }
        }
    }
    
    private func formatRootOperation() {
        if description.range(of:"ʸ√x") != nil {
            pendingVar ? description = "ᴹ√" : (description = exponentize(str: accumulatorBeforeOperation!) + "√")
        }
        
        if let range = description.range(of:"√x") ?? description.range(of:"³√x") {
            let mathSymbol = description.substring(with: range.lowerBound..<description.index(before: range.upperBound))
            if !pending {
                pendingVar ? (description = mathSymbol + "M") : checkVar(range: range, mathSymbol: mathSymbol, after: false)
            } else {
                unaryOperationIsPartOfBinaryOperatin()
                pendingVar ? (description = description + mathSymbol + "M") : (description = description + mathSymbol + accumulatorBeforeOperation!)
            }
        }
    }
    
    private func formatPowerOperation() {
        if let range = description.range(of:"x²") ?? description.range(of:"x³") ?? description.range(of:"x⁻¹") {
            let mathSymbol =  description.substring(with: range).replacingOccurrences(of: "x", with: "")
            if !pending {
                pendingVar ? description = "M" + mathSymbol : checkVar(range: range, mathSymbol: mathSymbol, after: true)
            } else {
                unaryOperationIsPartOfBinaryOperatin()
                pendingVar ? (description = description + "M" + mathSymbol) : (description = description + accumulatorBeforeOperation! + mathSymbol)
            }
        }
        
        if description.range(of:"xʸ") != nil {
            pendingVar ? (description = "M" + " ") : (description = accumulatorBeforeOperation! + " ")
        }
        
        if description.range(of: " ") != nil {
            let stringsSeparated = description.components(separatedBy: " ")
            if stringsSeparated[1] != "" {
                pendingVar ? (description = stringsSeparated[0] + "ᴹ") : (description = stringsSeparated[0] + exponentize(str: stringsSeparated[1]))
            }
        }
    }
    
    private func formatOperations() {
        let map = arrayOfOperations.map { string in description.range(of:string) }.flatMap {$0}
        if let range = map.first {
            let mathSymbol = description.substring(with: range).replacingOccurrences(of: "(x)", with: "")
            if !pending {
                pendingVar ? (description = mathSymbol + "(" + "M" + ")") : checkVar(range: range, mathSymbol: mathSymbol, after: false)
            } else {
                unaryOperationIsPartOfBinaryOperatin()
                pendingVar ? (description = description + mathSymbol + "(" + "M" + ")") : (description = description + mathSymbol + "(" + accumulatorBeforeOperation! + ")")
            }
        }
    }

    private func exponentize(str: String) -> String {
        let supers = [
            "0": "\u{2070}",
            "1": "\u{00B9}",
            "2": "\u{00B2}",
            "3": "\u{00B3}",
            "4": "\u{2074}",
            "5": "\u{2075}",
            "6": "\u{2076}",
            "7": "\u{2077}",
            "8": "\u{2078}",
            "9": "\u{2079}",
            ".": "'"
        ]
        var newStr = ""
        for char in str.characters {
            let key = String(char)
            if supers.keys.contains(key) {
                newStr.append(Character(supers[key]!))
            } else {
                newStr.append(char)
            }
        }
        return newStr
    }
    
    private func checkVar(range: Range<String.Index>, mathSymbol: String, after: Bool) {
        if description.range(of: "M") != nil {
            after ? (description = "(" + description.substring(to: range.lowerBound) + ")" + mathSymbol) : (description = mathSymbol + "(" + description.substring(to: range.lowerBound) + ")")
        } else {
            after ? (description = accumulatorBeforeOperation! + mathSymbol) : (description = mathSymbol + "(" + accumulatorBeforeOperation! + ")")
        }
    }
}

