//
//  GraphView.swift
//  iCalculator
//
//  Created by Sherlock on 11/13/16.
//  Copyright © 2016 Joseph Kubaivanove. All rights reserved.
//

import UIKit

protocol GraphViewDelegate: class {
    func getY(x: Double) -> Double
}

@IBDesignable
class GraphView: UIView
{
    @IBInspectable
    var pointsPerUnit: CGFloat = 50 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    @IBInspectable
    var graphOrigin: CGPoint? { didSet { origin = graphOrigin!; setNeedsDisplay() } }
    
    var drawGraph: Bool = false { didSet { setNeedsDisplay() } }
    
    weak var delegate: GraphViewDelegate?
    
    lazy var origin: CGPoint = { return CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2) }()

    override func draw(_ rect: CGRect)
    {
        let axesDrawer = AxesDrawer()
        axesDrawer.color = color
        axesDrawer.drawAxesInRect(bounds: rect, origin: origin, pointsPerUnit: pointsPerUnit)
        if drawGraph {
            color.set()
            pathForGraph().stroke()
        }
    }

    func panGestureDetected(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .ended {
            graphOrigin = CGPoint(x: origin.x + recognizer.translation(in: self).x, y: origin.y + recognizer.translation(in: self).y)
            recognizer.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    func pinchGestureDetected(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            pointsPerUnit = pointsPerUnit * recognizer.scale
        case .ended:
            recognizer.scale = 0
        default:
            return
        }
    }
    
    private func convertPointToViewAxes(_ point: CGPoint) -> (CGPoint) {
        let checkedPoint = point.y.isNaN ? CGPoint(x:point.x, y: 0) : point
        return CGPoint(x: checkedPoint.x*pointsPerUnit + origin.x, y:origin.y - checkedPoint.y*pointsPerUnit)
    }
    
    private func pathForGraph() -> UIBezierPath {
        let path = UIBezierPath()
        var startingX: CGFloat?
        var endX: CGFloat?
        if origin.x < bounds.minX {
            startingX = 0
            endX = (bounds.maxX - origin.x) / pointsPerUnit
        }
        else if origin.x > bounds.maxX {
            startingX = -(origin.x - bounds.minX) / pointsPerUnit
            endX = 0
        }
        else {
            startingX = -(origin.x - bounds.minX) / pointsPerUnit
            endX = (bounds.maxX - origin.x) / pointsPerUnit
        }
        path.move(to: convertPointToViewAxes(CGPoint(x: Double(startingX!), y: delegate!.getY(x: Double(startingX!)))))
        while startingX! < endX!{
            startingX! = startingX! + (2 / pointsPerUnit)
            path.addLine(to: convertPointToViewAxes(CGPoint(x: Double(startingX!), y: delegate!.getY(x: Double(startingX!)))))
        }
        return path
    }
}
