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

extension ASWrapperLayoutSpec {
    public convenience init(@LayoutBuilder _ children: () -> [ASLayoutElement]) {
        self.init(layoutElements: children())
    }
}

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
    
    
    
    
    
    public static func horizontal  (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .horizontal, spacing: spacing, justifyContent: justify, alignItems: align, children: children())) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
    public static func vertical    (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, @LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .vertical, spacing: spacing, justifyContent: justify, alignItems: align, children: children())) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
    
    public static func horizontal  (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, _ children: [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .horizontal, spacing: spacing, justifyContent: justify, alignItems: align, children: children)) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
    public static func vertical    (spacing: CGFloat, justify: ASStackLayoutJustifyContent = .start, align: ASStackLayoutAlignItems = .start, wrap: ASStackLayoutFlexWrap = .noWrap, lineSpacing: CGFloat = 0, _ children: [ASLayoutElement]) -> ASStackLayoutSpec {
        tell(ASStackLayoutSpec(direction: .vertical, spacing: spacing, justifyContent: justify, alignItems: align, children: children)) {
            $0.flexWrap = wrap
            $0.lineSpacing = lineSpacing
        }
    }
}

extension ASDisplayNode {
    public convenience init(@LayoutBuilder _ children: @escaping () -> [ASLayoutElement]) {
        self.init()
        
        automaticallyManagesSubnodes = true
        
        layoutSpecBlock = { node, size in
            ASWrapperLayoutSpec(layoutElements: children())
        }
    }
    
    public func enabled(_ value: Bool) -> Self {
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

extension ASLayoutSpec {
    
    public static var empty : ASLayoutSpec {
        return .init()
    }
    
    public static func conditional(_ logic: Bool, true: LayoutElement?, false: LayoutElement? = nil) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            if (logic)  {
                return [`true`?() ?? ASLayoutSpec.empty]
            } else {
                return [`false`?() ?? ASStackLayoutSpec.empty]
            }
        }
    }
    
}

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

extension ASLayoutElement {
    
    public static func hStackSpec (@LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        return ASStackLayoutSpec.horizontal(spacing: 10, children)
    }
    
    public static func vStackSpec (@LayoutBuilder _ children: () -> [ASLayoutElement]) -> ASStackLayoutSpec {
        return ASStackLayoutSpec.vertical(spacing: 10, children)
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
    
    @available(*, deprecated, renamed: "insets")
    public func inset(edges: UIEdgeInsets) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: edges, child: self)
    }
    
    public func insets(_ edges: UIEdgeInsets) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: edges, child: self)
    }
    
    public func centered(_ compressionAxes: ASCenterLayoutSpecSizingOptions, _ positionAxes: ASCenterLayoutSpecCenteringOptions) -> ASLayoutSpec {
        ASCenterLayoutSpec(centeringOptions: positionAxes, sizingOptions: compressionAxes, child: self)
    }
    
    public func flex(grow: CGFloat = 1, shrink: CGFloat = 0) -> Self {
        style.flexGrow = grow
        style.flexShrink = shrink
        return self
    }
    
    public func selfAlign(_ align: ASStackLayoutAlignSelf) -> Self {
        style.alignSelf = align
        return self
    }
    
    public func frameProportional(minWidth: CGFloat? = nil, width: CGFloat? = nil, maxWidth: CGFloat? = nil,
                                  minHeight: CGFloat? = nil, height: CGFloat? = nil, maxHeight: CGFloat? = nil) -> Self {
        
        if let value = minWidth {
            style.minWidth = .init(unit: .fraction, value: value)
        }
        
        if let value = width {
            style.width = .init(unit: .fraction, value: value)
        }
        
        if let value = maxWidth {
            style.maxWidth = .init(unit: .fraction, value: value)
        }
        
        if let value = minHeight {
            style.minHeight = .init(unit: .fraction, value: value)
        }
        
        if let value = height {
            style.height = .init(unit: .fraction, value: value)
        }
        
        if let value = maxHeight {
            style.maxHeight = .init(unit: .fraction, value: value)
        }
        
        return self
    }
    
    public func frame(minWidth: CGFloat? = nil, width: CGFloat? = nil, maxWidth: CGFloat? = nil,
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
}
