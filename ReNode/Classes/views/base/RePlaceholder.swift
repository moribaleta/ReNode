//
//  RePlaceholder.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

//
//  SULEmptyView.swift
//  SMDModuleUtility
//
//  Created by Gabriel on 23/08/2019.
//  Copyright © 2019 Leapfroggr Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
/**
    ui view for displaying in empty state
    - the message is centered in a dash line border box
    - NOTE:
        - default message is "choose from the list"
 */
open class RePlaceholderDisplay : ResizeableNode {
    
    public var     title    = ASTextNode()
    
    var isBordered : Bool   = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var dashedBorder        = ASDisplayNode()
    
    public var dashColor    : UIColor = Common.color.border_line.uicolor
    
    public var maxHeight    : CGFloat = 200 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var rxTap : Observable<Void>{
        return emitTap.asObservable()
    }
    
    var emitTap = PublishSubject<Void>()
    
    public override init() {
        super.init()
        title.attributedText    = Common.attributedString("choose from the list", attribute: .placeholder,
                                                          color: Common.color.empty_text.uicolor)
        self.cornerRadius       = 6
        self.clipsToBounds      = true
    }
    
    public func setMessage(message      : String,
                           italic       : Bool = true,
                           upper        : Bool = false,
                           isBordered   : Bool = true,
                           color        : UIColor = Common.color.empty_text.uicolor,
                           dashColor    : UIColor = Common.color.border_line.uicolor) {
        self.isBordered         = isBordered
        title.attributedText    = Common.attributedString(
                upper ? message.uppercased() : message,
                attribute   : .placeholder,
                color       : color,
                isItalic    : italic)
                    .aligned(.center)
        self.dashColor       = dashColor
    }
    
    public convenience init(message     : String,
                            italic      : Bool = true,
                            upper       : Bool = false,
                            isBordered  : Bool = true,
                            color       : UIColor = Common.color.empty_text.uicolor,
                            dashColor   : UIColor = Common.color.border_line.uicolor) {
        self.init()
        self.setMessage(
            message     : message,
            italic      : italic,
            upper       : upper,
            isBordered  : isBordered,
            color       : color,
            dashColor   : dashColor)
    }
    
    open override func didLoad() {
        super.didLoad()

        let tapper = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view.addGestureRecognizer(tapper)
    }
    
    deinit {
        self.emitTap.dispose()
    }
    
    @objc func onTap(){
        self.emitTap.onNext(())
    }
    
    open override func onLayoutSizeDidChange(prev: CGSize?, current: CGSize) {
        if self.isBordered {
            DispatchQueue.main.async {
                self.dashedBorder.view
                    .addDashLineBorderNew(self.dashColor)
                self.dashedBorder.cornerRadius = 6
                self.setNeedsLayout()
            }
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.style.width        = .init(unit: .fraction, value: 1)
        self.style.maxHeight    = .init(unit: .points, value: maxHeight)
        
        let center              = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.title)
        let inset               = ASInsetLayoutSpec(insets: .init(all: 10), child: center)
        
        if self.isBordered {
            return ASBackgroundLayoutSpec(child: inset, background: self.dashedBorder)
        }
        return inset
    }
    
}//RePlaceholderDisplay


/**
 * component to display RePlaceholderDisplay inside a constraint display
 */
open class RePlaceholder : ResizeableNode {
    
    public var emptyNode    = RePlaceholderDisplay()
    
    public var height       : CGFloat = 200
    
    public var rxTap        : Observable<Void> {
        return emptyNode.rxTap
    }
    
    public override init() {
        super.init()
        self.emptyNode.style.height      = .init(unit: .points, value: 200)
    }
    
    public convenience init(message: String,  italic: Bool = true, upper: Bool = false, isBordered: Bool = true,
                            color : UIColor = Common.color.empty_text.uicolor, backgroundColor: UIColor = .clear, height: CGFloat = 200) {
        self.init()
        self.setMessage(
            message         : message,
            italic          : italic,
            upper           : upper,
            isBordered      : isBordered,
            color           : color,
            backgroundColor : backgroundColor,
            height          : height)
    }
    
    public func setMessage(message: String,  italic: Bool = true, upper: Bool = false, isBordered: Bool = true,
                           color : UIColor = Common.color.empty_text.uicolor, backgroundColor: UIColor = .clear, height: CGFloat = 200) {
        
        self.emptyNode.setMessage(
            message     : message,
            italic      : italic,
            upper       : upper,
            isBordered  : isBordered,
            color       : color)
        self.emptyNode.backgroundColor  = backgroundColor
        self.height = height
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        self.style.width                = .init(unit: .fraction, value: 1)
//        self.emptyNode.style.height     = .init(unit: .points, value: height)
        
        make(ASLayoutSpec
            .vStackSpec {
                self.emptyNode
                    .frame(
                        height: self.height
                    )
            }
            .spacing(0)) {
                self.fraction(width: 1)
            }
    }
    
}//RePlaceholder


fileprivate extension UIView{
    func addDashedLineBorder() {
        if !(self.layer.sublayers?.isEmpty ?? true) {
            self.layer.sublayers?.removeLast()
        }
        let color   = Common.baseColor.lightgray.uicolor.cgColor //UIColor.lightGray.cgColor
        let rect    = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let layer   = CAShapeLayer.init()
        let path    = UIBezierPath(roundedRect: rect, cornerRadius: 6)
        layer.path  = path.cgPath;
        layer.strokeColor = color;
        layer.lineDashPattern = [3,3];
        layer.backgroundColor = UIColor.clear.cgColor;
        layer.fillColor = UIColor.clear.cgColor;
        self.layer.addSublayer(layer);
    }
    
    func addDashLineBorderNew(_ color           : UIColor       = Common.color.border_line.uicolor,
                              withWidth width   : CGFloat       = 2,
                              cornerRadius      : CGFloat       = Common.div_corner_radius,
                              dashPattern       : [NSNumber]    = [3,3]) {
        
        if !(self.layer.sublayers?.isEmpty ?? true) {
            self.layer.sublayers?.removeLast()
        }
        
        let shapeLayer              = CAShapeLayer()
        
        shapeLayer.bounds           = bounds
        shapeLayer.position         = CGPoint(x: bounds.width/2, y: bounds.height/2)
        shapeLayer.fillColor        = nil
        shapeLayer.strokeColor      = color.cgColor
        shapeLayer.lineWidth        = width
        shapeLayer.lineJoin         = CAShapeLayerLineJoin.round // Updated in swift 4.2
        shapeLayer.lineDashPattern  = dashPattern
        shapeLayer.path             = UIBezierPath(roundedRect  : bounds,
                                                   cornerRadius : cornerRadius)
                                                    .cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}

