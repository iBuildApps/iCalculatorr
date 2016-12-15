//
//  CalculatorViewController.swift
//  iCalculator
//
//  Created by Sherlock on 11/14/16.
//  Copyright © 2016 Joseph Kubaivanove. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.hidesBarsOnTap = false
    }
    
    override var prefersStatusBarHidden: Bool { return true } 

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false {
        willSet {
            if !userIsInTheMiddleOfTyping { descriptionLabel.text = descriptionLabel.text! + "..." }
        }
    }
    
    @IBAction private func clearButtonPressed(_ sender: UIButton) {
        calculatorBrain.clear()
        descriptionLabel.text = ""
        userIsInTheMiddleOfTyping = false
        display.text = "0"
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            if digit == "0" {
                display.text = "0."
            } else {
                display.text = digit
            }
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue:Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction private func touchDecimalPoint(_ sender: UIButton) {
        display.text =  (display.text?.range(of: ".") == nil) ? (display.text! + ".") : display.text
    }

    private var calculatorBrain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            calculatorBrain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            calculatorBrain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = calculatorBrain.result
        descriptionLabel.text = calculatorBrain.getDescription()
    }
    
    @IBAction private func scientificNotation (sender: UIButton) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.scientific
        numberFormatter.positiveFormat = "0.###E+0"
        numberFormatter.exponentSymbol = "e"
        if let stringFromNumber = numberFormatter.string(from: (NSNumber(value: displayValue))){
            display.text = stringFromNumber
        }
    }
    
    @IBAction func setMemory(_ sender: UIButton) {
        calculatorBrain.memory = displayValue
    }
    
    @IBAction func getMemory(_ sender: UIButton) {
        displayValue = calculatorBrain.memory
        calculatorBrain.setVariable(name: "M")
    }
    
    @IBAction func clearMemory(_ sender: UIButton) {
        calculatorBrain.memory = 0.0
    }
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
    private func save() {
        savedProgram = calculatorBrain.program
    }
    
    private func restore() {
        if savedProgram != nil {
            calculatorBrain.program = savedProgram!
            displayValue = calculatorBrain.result
            descriptionLabel.text = calculatorBrain.getDescription()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        if let destinationvc = destinationvc as? GraphViewController {
            save()
            destinationvc.savedProgram = savedProgram
        }
    }
}
