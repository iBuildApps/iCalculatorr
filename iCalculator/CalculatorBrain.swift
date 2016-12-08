//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sherlock on 7/30/16.
//  Copyright © 2016 Joseph Kubaivanove. All rights reserved.
//

import Foundation
import UIKit

class CalculatorBrain
{
    private var accumulator = 0.0
    
    var memory = 0.0
    
    var c = false

    var iternalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        operand - floor(operand) == 0 ? (description.description += String(operand).replacingOccurrences(of: ".0", with: "")) : (description.description += String(operand))
        iternalProgram.append(operand as AnyObject)
    }
    
    func setVariable(name: String) {
        accumulator = memory
        description.description += name
        description.pendingVar = true
        iternalProgram.append(name as AnyObject)
    }
    
    private var description = CalculatorBrainDescription()
    
    func getDescription() -> String {
        description.format()
        return description.description
    }
    
    func clear() {
        description.clear()
        accumulator = 0.0
        pending = nil
        iternalProgram.removeAll()
    }
    
    private var operations: Dictionary<String,Operation> = [
    // Constants
    "π" : Operation.Constant(M_PI),
    "e" : Operation.Constant(M_E),
    // Power functions
    "2ˣ" : Operation.UnaryOperation( { pow(2, $0) }),
    "xʸ" : Operation.BinaryOperation( { pow($0, $1) } ),
    "x²" : Operation.UnaryOperation( { pow($0, 2) } ),
    "x³" : Operation.UnaryOperation( { pow($0, 3) } ),
    "eˣ" : Operation.UnaryOperation( { exp($0) } ),
    "10ˣ" : Operation.UnaryOperation( { pow(10, $0) } ),
    "x⁻¹" : Operation.UnaryOperation( { pow($0, -1) } ),
    "√x" : Operation.UnaryOperation(sqrt),
    "³√x" : Operation.UnaryOperation( { pow($0, 1/3) } ),
    "ʸ√x" : Operation.BinaryOperation( { pow($1, 1/$0) } ),
    // Logratmic functions
    "log₁₀(x)" : Operation.UnaryOperation( { log10($0) }),
    "ln(x)" : Operation.UnaryOperation( { log($0) } ),
    // Factorial
    "x!" : Operation.UnaryOperation(factorial),
    // Random 
    "Rand" : Operation.Constant(Double(arc4random())),
    //Trigonomatric functions
    "cos(x)" : Operation.UnaryOperation(cos),
    "sin(x)" : Operation.UnaryOperation(sin),
    "tan(x)" : Operation.UnaryOperation(tan),
    "cosh(x)" : Operation.UnaryOperation(cosh),
    "sinh(x)" : Operation.UnaryOperation(sinh),
    "tanh(x)" : Operation.UnaryOperation(tanh),
    // Basic functions
    "±" : Operation.UnaryOperation({ -$0 }),
    "﹪" : Operation.UnaryOperation({ $0 / 100 }),
    "×" : Operation.BinaryOperation({ $0 * $1 }),
    "÷" : Operation.BinaryOperation({ $0 / $1 }),
    "+" : Operation.BinaryOperation({ $0 + $1 }),
    "−" : Operation.BinaryOperation({ $0 - $1 }),
    "＝" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            description.description += symbol
            iternalProgram.append(symbol as AnyObject)
            switch operation {
            case .Constant(let value):
                accumulator  = value
            case .UnaryOperation(let function):
                description.accumulatorBeforeOperation = String(accumulator).replacingOccurrences(of: ".0", with: "")
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                if symbol ==  "ʸ√x" || symbol == "xʸ" {
                    description.accumulatorBeforeOperation = String(accumulator).replacingOccurrences(of: ".0", with: "")
                }
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo? { didSet { description.pending = isPending() } }
    
    func isPending() -> Bool {
        if (pending != nil) {
            return true
        }
        return false
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get{
            return iternalProgram as PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        if operation == "M" {
                            setVariable(name: "M")
                        } else {
                            performOperation(symbol: operation)
                        }
                    }
                }
            }
        }
    }
    
    var result: Double{
        get {
            return accumulator
        }
    }
}

private func factorial(i: Double) -> Double {
    var k: Double = 1
    var counter: Double  = 1
    while counter <= floor(i) {
        k *= counter
        counter += 1
    }
    return k
}



