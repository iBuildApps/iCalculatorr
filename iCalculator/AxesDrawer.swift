//
//  AxesDrawer.swift
//  Calculator
//
//  Created by Sherlock on 7/30/16.
//  Copyright © 2016 Joseph Kubaivanove. All rights reserved.
//

import UIKit

class AxesDrawer
{
    private struct Constants {
        static let HashmarkSize: CGFloat = 6
    }
    
    private var realOrigin: CGPoint!
    
    var color = UIColor.blue
    var minimumPointsPerHashmark: CGFloat = 40
    var contentScaleFactor: CGFloat = 1 // set this from UIView's contentScaleFactor to position axes with maximum accuracy
    
    convenience init(color: UIColor, contentScaleFactor: CGFloat) {
        self.init()
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.contentScaleFactor = contentScaleFactor
    }
    
    // this method is the heart of the AxesDrawer
    // it draws in the current graphic context's coordinate system
    // therefore origin and bounds must be in the current graphics context's coordinate system
    // pointsPerUnit is essentially the "scale" of the axes
    // e.g. if you wanted there to be 100 points along an axis between -1 and 1,
    //    you'd set pointsPerUnit to 50
    
    func drawAxesInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        UIGraphicsGetCurrentContext()!.saveGState()
        color.set()
        let path = UIBezierPath()
        var visableOrigin = origin
        realOrigin = origin
        if origin.x > bounds.maxX  {
            visableOrigin = CGPoint(x: bounds.maxX-1, y: visableOrigin.y)
        } else if origin.x < bounds.minX {
            visableOrigin = CGPoint(x: bounds.minX+1, y: visableOrigin.y)
        }
        if origin.y > bounds.maxY {
            visableOrigin = CGPoint(x: visableOrigin.x, y: bounds.maxY - 1)
        } else if origin.y < bounds.minY {
            visableOrigin = CGPoint(x: visableOrigin.x, y: bounds.minY + 1)
        }
        path.move(to: CGPoint(x: align(coordinate: visableOrigin.x), y: bounds.minY))
        path.addLine(to: CGPoint(x: align(coordinate: visableOrigin.x), y: bounds.maxY))
        path.move(to: CGPoint(x: bounds.minX, y: align(coordinate: visableOrigin.y)))
        path.addLine(to: CGPoint(x: bounds.maxX, y: align(coordinate: visableOrigin.y)))
        path.stroke()
        drawHashmarksInRect(bounds: bounds, origin: visableOrigin, pointsPerUnit: abs(pointsPerUnit))
        UIGraphicsGetCurrentContext()!.restoreGState()
    }
    
    // the rest of this class is private
    
    private func drawHashmarksInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {

        if ((origin.x >= bounds.minX) && (origin.x <= bounds.maxX)) || ((origin.y >= bounds.minY) && (origin.y <= bounds.maxY))
        {
            // figure out how many units each hashmark must represent
            // to respect both pointsPerUnit and minimumPointsPerHashmark
            var unitsPerHashmark = minimumPointsPerHashmark / pointsPerUnit
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            
            let pointsPerHashmark = pointsPerUnit * unitsPerHashmark
            
            // figure out which is the closest set of hashmarks (radiating out from the origin) that are in bounds
            var startingHashmarkRadius: CGFloat = 1
            if !bounds.contains(origin) {
                let leftx = max(origin.x - bounds.maxX, 0)
                let rightx = max(bounds.minX - origin.x, 0)
                let downy = max(origin.y - bounds.minY, 0)
                let upy = max(bounds.maxY - origin.y, 0)
                startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
            }
            
            // now create a bounding box inside whose edges those four hashmarks lie
            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: realOrigin!, size: CGSize(width: bboxSize, height: bboxSize))
            
            // formatter for the hashmark labels
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = Int(-log10(Double(unitsPerHashmark)))
            formatter.minimumIntegerDigits = 1
            
            // radiate the bbox out until the hashmarks are further out than the bounds
            while !bbox.contains(bounds)
            {
                let x: Double!, y:Double!
                if realOrigin!.x < bounds.minX {
                    x = abs(Double((realOrigin!.x-bbox.maxX) / pointsPerUnit))
                } else {
                    x = abs(Double((realOrigin!.x-bbox.minX) / pointsPerUnit))
                }
                if realOrigin!.y < bounds.minY {
                    y = abs(Double((realOrigin!.y-bbox.maxY) / pointsPerUnit))
                } else {
                    y = abs(Double((realOrigin!.y-bbox.minY) / pointsPerUnit))
                }

                if let xLabel = formatter.string(from: NSNumber(value: x)) {
                    if let leftHashmarkPoint = alignedPoint(x: bbox.minX, y: origin.y, insideBounds:bounds) {
                        if realOrigin!.y > bounds.maxY {
                            drawHashmarkAtLocation(location: leftHashmarkPoint, .Bottom("-\(xLabel)"))
                        } else {
                            drawHashmarkAtLocation(location: leftHashmarkPoint, .Top("-\(xLabel)"))
                        }
                    }
                    if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origin.y, insideBounds:bounds) {
                        if realOrigin!.y > bounds.maxY {
                            drawHashmarkAtLocation(location: rightHashmarkPoint, .Bottom(xLabel))
                        } else {
                            drawHashmarkAtLocation(location: rightHashmarkPoint, .Top(xLabel))
                        }
                    }
                }
                if let yLabel = formatter.string(from: NSNumber(value: y)) {
                    if let topHashmarkPoint = alignedPoint(x: origin.x, y: bbox.minY, insideBounds:bounds) {
                        if realOrigin!.x > bounds.maxX {
                            drawHashmarkAtLocation(location: topHashmarkPoint, .Right(yLabel))
                        } else {
                            drawHashmarkAtLocation(location: topHashmarkPoint, .Left(yLabel))
                        }
                    }
                    if let bottomHashmarkPoint = alignedPoint(x: origin.x, y: bbox.maxY, insideBounds:bounds) {
                        if realOrigin!.x > bounds.maxX {
                            drawHashmarkAtLocation(location: bottomHashmarkPoint, .Right("-\(yLabel)"))
                        } else {
                            drawHashmarkAtLocation(location: bottomHashmarkPoint, .Left("-\(yLabel)"))
                        }
                    }
                }
                bbox = bbox.insetBy(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            }
        }
    }
    
    private func drawHashmarkAtLocation(location: CGPoint, _ text: AnchoredText)
    {
        var dx: CGFloat = 0, dy: CGFloat = 0
        switch text {
        case .Left: dx = Constants.HashmarkSize / 2
        case .Right: dx = Constants.HashmarkSize / 2
        case .Top: dy = Constants.HashmarkSize / 2
        case .Bottom: dy = Constants.HashmarkSize / 2
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: location.x-dx, y: location.y-dy))
        path.addLine(to: CGPoint(x: location.x+dx, y: location.y+dy))
        path.stroke()
        text.drawAnchoredToPoint(location: location, color: color)
    }
    
    private enum AnchoredText
    {
        case Left(String)
        case Right(String)
        case Top(String)
        case Bottom(String)
        
        static let VerticalOffset: CGFloat = 3
        static let HorizontalOffset: CGFloat = 6
        
        func drawAnchoredToPoint(location: CGPoint, color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.size(attributes: attributes))
            switch self {
            case .Top: textRect.origin.y += textRect.size.height / 2 + AnchoredText.VerticalOffset
            case .Left: textRect.origin.x += textRect.size.width / 2 + AnchoredText.HorizontalOffset
            case .Bottom: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.VerticalOffset
            case .Right: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.HorizontalOffset
            }
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        var text: String {
            switch self {
            case .Left(let text): return text
            case .Right(let text): return text
            case .Top(let text): return text
            case .Bottom(let text): return text
            }
        }
    }
    
    // we want the axes and hashmarks to be exactly on pixel boundaries so they look sharp
    // setting contentScaleFactor properly will enable us to put things on the closest pixel boundary
    // if contentScaleFactor is left to its default (1), then things will be on the nearest "point" boundary instead
    // the lines will still be sharp in that case, but might be a pixel (or more theoretically) off of where they should be
    
    private func alignedPoint(x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(coordinate: x), y: align(coordinate: y))
        if let permissibleBounds = insideBounds,
            !permissibleBounds.contains(point) {
            return nil
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}
