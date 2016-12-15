//
//  GraphViewController.swift
//  iCalculator
//
//  Created by Sherlock on 11/13/16.
//  Copyright © 2016 Joseph Kubaivanove. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDelegate {
    
    private let calculatorBrain = CalculatorBrain()
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self.graphView, action: #selector(graphView.panGestureDetected(recognizer:))))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self.graphView, action: #selector(graphView.pinchGestureDetected(recognizer:))))
            graphView.delegate = self
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.hidesBarsOnTap = true

        if savedProgram != nil {
            calculatorBrain.program = savedProgram!
            self.graphView.drawGraph = true
        } 
    }

    // GraphView Delegate
    func getY(x: Double) -> Double {
        calculatorBrain.memory = x
        calculatorBrain.program = savedProgram!
        return calculatorBrain.result
    }
}
