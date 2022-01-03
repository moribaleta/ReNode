//
//  FunctionalizedLayout.swift
//  SMDModuleUtility
//
//  Created by Michael Ong on 7/9/21.
//  Copyright © 2021 Leapfroggr Inc. All rights reserved.
//

import AsyncDisplayKit

@resultBuilder
public struct LayoutBuilder {
    public static func buildExpression<Node: ASDisplayNode>(_ expression: Node?) -> ASLayoutElement? {
        expression
    }
    
    public static func buildExpression(_ expression: ASLayoutElement) -> [ASLayoutElement] {
        [ expression ]
    }
    
    public static func buildExpression(_ expression: ASLayoutElement?) -> [ASLayoutElement] {
        if let expression = expression {
            return [ expression ]
        } else {
            return []
        }
    }
    
    public static func buildExpression(_ expression: [ASLayoutElement]) -> [ASLayoutElement] {
        expression
    }
    
    public static func buildEither(first component: [ASLayoutElement]) -> [ASLayoutElement] {
        component
    }
    
    public static func buildEither(second component: [ASLayoutElement]) -> [ASLayoutElement] {
        component
    }
    
    public static func buildOptional(_ component: [ASLayoutElement]?) -> [ASLayoutElement] {
        component ?? []
    }
    
    public static func buildBlock(_ components: [ASLayoutElement]...) -> [ASLayoutElement] {
        components.flatMap { $0 }
    }
    
    public static func buildBlock(_ components: ASLayoutElement?...) -> [ASLayoutElement] {
        components.compactMap { $0 }
    }
    
}

public typealias LayoutElement = (() -> ASLayoutElement)

extension ASDisplayNode {
    public static func Group(@LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASDisplayNode {
        
        let items = children()
        
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { node, size in
            ASWrapperLayoutSpec(layoutElements: items)
        }
        
        return node
    }
    
    public convenience init(@LayoutBuilder _ children: @escaping () -> [ASLayoutElement]) {
        self.init()
        
        automaticallyManagesSubnodes = true
        
        layoutSpecBlock = { node, size in
            ASWrapperLayoutSpec(layoutElements: children())
        }
    }
    
    @discardableResult public func enabled(_ value: Bool) -> Self {
        if value {
            isUserInteractionEnabled = true
            alpha = 1
        } else {
            isUserInteractionEnabled = false
            alpha = 0.5
        }
        
        return self
    }
}

extension ASScrollNode {
    
    public convenience init(@LayoutBuilder scrollContent children: @escaping () -> [ASLayoutElement]) {
        self.init()
        
        automaticallyManagesSubnodes = true
        automaticallyManagesContentSize = true
        
        layoutSpecBlock = { node, size in
            ASWrapperLayoutSpec(layoutElements: children())
        }
    }
}

extension ASWrapperLayoutSpec {
    public convenience init(@LayoutBuilder _ children: () -> [ASLayoutElement]) {
        self.init(layoutElements: children())
    }
}

//MARK: ASStackLayoutSpec attributes
extension ASStackLayoutSpec {
    
    public func spacing(_ spacing: CGFloat = 10) -> Self {
        self.spacing = spacing
        return self
    }
    
    public func justify(_ justify: ASStackLayoutJustifyContent = .start) -> Self {
        self.justifyContent = justify
        return self
    }
    
    public func align(_ align: ASStackLayoutAlignItems = .stretch) -> Self {
        self.alignItems = align
        return self
    }
    
    public func alignContent(_ align: ASStackLayoutAlignContent = .start) -> Self {
        self.alignContent = align
        return self
    }
    
    public func wrap(_ wrap: ASStackLayoutFlexWrap = .wrap) -> Self {
        self.flexWrap = wrap
        return self
    }
    
    public func linespacing(_ linespacing: CGFloat = 10) -> Self {
        self.lineSpacing = linespacing
        return self
    }
    
    public func children(@LayoutBuilder _ children: () -> [ASLayoutElement]) -> Self {
        self.children = children()
        return self
    }
    
    @available(*, deprecated, message: "ASStackLayoutDirection cant be changed after the object was created")
    public func stackDirection(_ direction: ASStackLayoutDirection) -> Self {
        self.direction = direction
        return self
    }
    
    @available(*, deprecated, renamed: "hStackSpec")
    public static func horizontal  (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .horizontal, spacing: spacing, justifyContent: justify, alignItems: align, children: children())) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
    
    @available(*, deprecated, renamed: "vStackSpec")
    public static func vertical    (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .vertical, spacing: spacing, justifyContent: justify, alignItems: align, children: children())) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
    
    @available(*, deprecated, renamed: "hStackSpec")
    public static func horizontal  (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, _ children: [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .horizontal, spacing: spacing, justifyContent: justify, alignItems: align, children: children)) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
    
    @available(*, deprecated, renamed: "vStackSpec")
    public static func vertical    (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, _ children: [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .vertical, spacing: spacing, justifyContent: justify, alignItems: align, children: children)) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
}


/**
 * enum used for additional stack direction features for ASStackLayoutSpec
 */
public enum ASLayoutSpecStackDirection {
    case vertical
    case horizontal
    case verticalReverse
    case horizontalReverse
    
    var stackDirection : ASStackLayoutDirection {
        switch self {
        case .vertical, .verticalReverse :
            return .vertical
        case .horizontal, .horizontalReverse :
            return .horizontal
        }
    }
    
    var isReversed : Bool {
        switch self {
        case .verticalReverse, .horizontalReverse:
            return true
        default:
            return false
        }
    }
}

extension ASLayoutSpec {
    
    /**
     * returns an empty layout with a specified frame
     */
    @available(*, deprecated, renamed: "ASSpacing")
    public static func empty(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
        return .init().frame(width: width, height: height)
    }//empty
    
    /**
     * returns the layout from the specified condition
     * - Parameters:
     *      - logic: conditional statement used to determine which layout to use
     *      - true  : layout block returned if true
     *      - false: layout block returned if false - optional returns empty if `nil`
     * ```
     * ASLayoutSpec.conditional(value == "string") {
     *  //Sample returned value if true
     *  ASLayoutSpec.vStackSpec
     * } false : {
     *  //Sample returned value
     *  ASLayoutSpec.hStackSpec
     * }
     * ```
     */
    public static func conditional(_ logic: Bool, true: LayoutElement?, false: LayoutElement? = nil) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            if (logic)  {
                return [`true`?() ?? ASSpacing()]
            } else {
                return [`false`?() ?? ASSpacing()]
            }
        }
    }//conditional
    
    
    /**
     * creates an empty stack layout spec
     */
    public static func stackSpec (direction: ASLayoutSpecStackDirection, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        ASStackLayoutSpec(
            direction       : direction.stackDirection,
            spacing         : 10,
            justifyContent  : .start,
            alignItems      : .stretch,
            children        : [])
            .children(
                {
                    () -> [ASLayoutElement] in
                    direction.isReversed ?
                        children().reversed() :
                        children()
                }
            )
    }//stackSpec
    
    /**
     * creates a layour spec from ASStackLayoutSpec.horizontal
     */
    public static func hStackSpec (@LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        return .hStackSpec(spacing: 10, children)
    }//hStackSpec
    
    /**
     * creates a layour spec from ASStackLayoutSpec.vertical
     */
    public static func hStackSpec (spacing: CGFloat = 10, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 10, alignContent: ASStackLayoutAlignContent = .start, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        return  ASStackLayoutSpec(
            direction       : .horizontal,
            spacing         : spacing,
            justifyContent  : justify,
            alignItems      : align,
            flexWrap        : wrap,
            alignContent    : alignContent,
            lineSpacing     : lineSpacing,
            children        : children())
    }//vStackSpec
    
    /**
     * creates a layour spec from ASStackLayoutSpec.vertical
     */
    public static func vStackSpec (@LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        return  vStackSpec(spacing: 10, children)
    }//vStackSpec
    
    /**
     * creates a layour spec from ASStackLayoutSpec.vertical
     */
    public static func vStackSpec (spacing: CGFloat = 10, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        return  ASStackLayoutSpec(
            direction       : .vertical,
            spacing         : spacing,
            justifyContent  : justify,
            alignItems      : align,
            children        : children())
    }//vStackSpec
    
}

//MARK: Relative LayoutSpec attributes
extension ASRelativeLayoutSpec {
    
    public func horizontalPosition(_ positon: ASRelativeLayoutSpecPosition = .start) -> Self {
        self.horizontalPosition = positon
        return self
    }
    
    public func verticalPosition(_ positon: ASRelativeLayoutSpecPosition = .start) -> Self {
        self.horizontalPosition = positon
        return self
    }
    
    public func sizingOption(_ sizing: ASRelativeLayoutSpecSizingOption = .minimumSize) -> Self {
        self.sizingOption = sizing
        return self
    }

}

//MARK: Inset layout specs attributes
extension ASInsetLayoutSpec {
    
    public func insets(_ insets: UIEdgeInsets) -> Self{
        self.insets = insets
        return self
    }
    
    public func child(_ child: ASLayoutElement) -> Self {
        self.child = child
        return self
    }
    
}

//MARK: layout specs
extension ASLayoutElement {
    
    public func centerSpec(_ compressionAxes: ASCenterLayoutSpecSizingOptions, _ positionAxes: ASCenterLayoutSpecCenteringOptions) -> ASLayoutSpec {
        ASCenterLayoutSpec(centeringOptions: positionAxes, sizingOptions: compressionAxes, child: self)
    }
 
    
 
    public func relativeSpec(horizontalPosition: ASRelativeLayoutSpecPosition = .start, verticalPosition: ASRelativeLayoutSpecPosition = .start, sizingOption: ASRelativeLayoutSpecSizingOption = .minimumSize) -> ASRelativeLayoutSpec {
        ASRelativeLayoutSpec(
            horizontalPosition  : horizontalPosition,
            verticalPosition    : verticalPosition,
            sizingOption        : sizingOption,
            child               : self)
    }
    
    public func overlaySpec(_ overlay: () -> ASLayoutElement) -> ASOverlayLayoutSpec {
        ASOverlayLayoutSpec(
            child   : self,
            overlay : overlay())
    }
    
    public func backgroundSpec(_ background: () -> ASLayoutElement) -> ASBackgroundLayoutSpec {
        ASBackgroundLayoutSpec(
            child   : self,
            background : background())
    }
    
    @available(*, deprecated, renamed: "insetSpec")
    public func inset(edges: UIEdgeInsets) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: edges, child: self)
    }
    
    @available(*, deprecated, renamed: "centerSpec")
    public func centered(_ compressionAxes: ASCenterLayoutSpecSizingOptions, _ positionAxes: ASCenterLayoutSpecCenteringOptions) -> ASLayoutSpec {
        ASCenterLayoutSpec(centeringOptions: positionAxes, sizingOptions: compressionAxes, child: self)
    }
}

//MARK: Inset Specs
extension ASLayoutElement {
    
    public func insetSpec(_ edges: UIEdgeInsets) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: edges, child: self)
    }
    
    public func insetSpec(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> ASLayoutSpec {
        ASInsetLayoutSpec(
            insets  : .init(horizontal: horizontal, vertical: vertical),
            child   : self)
    }
    
    public func insetSpec(top: CGFloat = 0, sides: CGFloat = 0, bottom: CGFloat = 0) -> ASLayoutSpec {
        ASInsetLayoutSpec(
            insets  : .init(top: top, sides: sides, bottom: bottom),
            child   : self)
    }
    
    public func insetSpec(_ all: CGFloat) -> ASLayoutSpec {
        ASInsetLayoutSpec(
            insets  : .init(all: all),
            child   : self)
    }
    
}

//MARK: sizing attributes
extension ASLayoutElement {
    
    @discardableResult public func flex(grow: CGFloat = 1, shrink: CGFloat = 0) -> Self {
        style.flexGrow = grow
        style.flexShrink = shrink
        return self
    }
    
    @discardableResult public func flexBasis(unit: ASDimensionUnit, value: CGFloat) -> Self {
        style.flexBasis = .init(unit: unit, value: value)
        return self
    }
    
    @discardableResult public func selfAlign(_ align: ASStackLayoutAlignSelf) -> Self {
        style.alignSelf = align
        return self
    }
    
    @discardableResult public func frame(minWidth: CGFloat? = nil, width: CGFloat? = nil, maxWidth: CGFloat? = nil,
                      minHeight: CGFloat? = nil, height: CGFloat? = nil, maxHeight: CGFloat? = nil) -> Self {
        
        if let value = minWidth {
            style.minWidth = .init(unit: .points, value: value)
        }
        
        if let value = width {
            style.width = .init(unit: .points, value: value)
        }
        
        if let value = maxWidth {
            style.maxWidth = .init(unit: .points, value: value)
        }
        
        if let value = minHeight {
            style.minHeight = .init(unit: .points, value: value)
        }
        
        if let value = height {
            style.height = .init(unit: .points, value: value)
        }
        
        if let value = maxHeight {
            style.maxHeight = .init(unit: .points, value: value)
        }
        
        return self
    }
    
    /**
     * styles the layout into equal height and width
     */
    @discardableResult public func frame(equal: CGFloat) -> Self {
        self.frame(width: equal, height: equal)
        return self
    }//frame
    
    /**
     * sets the height or width of the element
     */
    @discardableResult public func fraction(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        if let value = width {
            style.width = .init(unit: .fraction, value: value)
        }
        
        if let value = height {
            style.height = .init(unit: .fraction, value: value)
        }
        return self
    }
}


/**
 * class extends ASLayoutSpec
 * used for spacing purposes
 */
open class ASSpacing : ASLayoutSpec {
    
    public convenience init(equal value: CGFloat = 0) {
        self.init()
        self.frame(width: value, height: value)
    }
    
    public convenience init(width: CGFloat = 0, height: CGFloat = 0) {
        self.init()
        self.frame(width: width, height: height)
    }
    
    public func width(_ width: CGFloat = 0) -> Self {
        self.frame(width: width)
        return self
    }
    
    public func height(_ height: CGFloat = 0) -> Self {
        self.frame(height: height)
        return self
    }
}
