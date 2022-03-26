//
//  ReRudder.swift
//  DateTools
//
//  Created by Mini on 3/22/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

struct RudderConfig {
    var color           : UIColor = Common.color.textbody.uicolor
    var backgroundColor : UIColor = .white
    var borderColor     : UIColor = Common.baseColor.darkgray.uicolor
}

public class ReRudder<T> : ResizeableNode where T : ReDropdownEntryType {
    
    class Tag<T> : ASDisplayNode where T : ReDropdownEntryType {
        let label = ReTextNode()
        let remove = ReButton()
        
        var value : T!
        
        init(value: T, theme: RudderConfig = .init()) {
            super.init()
            
            self.value = value
            
            label.maximumNumberOfLines = 1
            automaticallyManagesSubnodes = true
            
            label.setText(value.string, attribute: .label)
            remove.set(icon: Icon.actionClose.rawValue, text: "", config: .ICON30_CLEAR)
            
            self.border(radius: Common.text_corner_radius, color: theme.borderColor.cgColor)
            self.backgroundColor = theme.backgroundColor
        }
        
        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            ASLayoutSpec
                .hStackSpec {
                    self.label
                        .insetSpec(.zero)
                        .flex(grow: 1, shrink: 1)
                    self.remove
                }
                .spacing(1)
                .align(.center)
                .insetSpec(.topInset(2).leftInset(6))
        }
    }
    
    
    var list : [T] = []
    var tags: [Tag<T>] = []
    
    var disposeBag = DisposeBag()
    
   
    
    public weak var dropdownPeg : UIViewController?
    public var maxSelection    : Int? = nil
    public var placeholder     : ASTextNode?
    public var onSearch        : CallBack.typeCall<String?, [T]>? = nil
    
    public var rxAdded = PublishSubject<T>()
    public var rxRemoved = PublishSubject<T>()
    public var rxSelections = PublishSubject<[T]>()
    
    
    public var willRemove : ((T) -> Bool)?
    
    public convenience init(placeholder: String? = nil) {
        self.init()
        
        /*
        if let placeholder = placeholder {
            self.placeholder = .init(placeholder, attribute: .sublabel)
        }*/
        
        
        self.backgroundColor = Common.baseColor.green.uicolor
        self.automaticallyManagesSubnodes = true
    }
    
    
    public override func didLoad() {
        super.didLoad()
        let tapper = UITapGestureRecognizer(target: self, action: #selector(showPopup))
        self.view.addGestureRecognizer(tapper)
        
        self.border(radius: Common.text_corner_radius)
        
        self.style.minHeight = .init(unit: .points, value: 44)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASLayoutSpec.hStackSpec(spacing: 4, align: .center) {
            if let placeholder = self.placeholder, tags.isEmpty {
                placeholder
                    .insetSpec(horizontal: 10, vertical: 0)
                    .flex()
            } else {
                ASLayoutSpec.hStackSpec(spacing: 4, wrap: .wrap) {
                    tags.map { $0.frame(maxWidth: asyncTraitCollection().horizontalSizeClass == .compact ? 250 : 350)}
                }
                .lineSpacing(4)
                .insetSpec(6)
                .flex(grow: 1, shrink: 1)
                .selfAlign(.stretch)
            }
            
        }.flex(grow: 1, shrink: 1)
    }
    
    
    public func bind(items: Observable<[T]>) {
        // TODO:
        items.subscribe(onNext: {
            self.list = $0
        }).disposed(by: disposeBag)
    }
    
    public func set(selected: [T]) {
        
        self.tags = selected.map { [unowned self] item in
            
            let tag = Tag<T>(value: item)
            
            _ = tag.remove.rxTap.subscribe(onNext: { [unowned self] tap in
                if self.willRemove?(item) ?? true {
                    self.remove(tag: tag)
                    self.rxRemoved.onNext(item)
                    self.rxSelections.onNext(self.tags.map({ $0.value }))
                    self.setNeedsLayout()
                }
            }).disposed(by: disposeBag)
            return tag
        }
        
        self.setNeedsLayout()
    }
    
    private func remove(tag: Tag<T>) {
        if let index = self.tags.firstIndex(where: { $0 === tag }) {
            self.tags.remove(at: index)
        }
    }
    
    private func add(item: T) {
        
        let tag = Tag<T>(value: item)
        tag.remove.rxTap.subscribe(onNext: { [unowned self] tap in
            if self.willRemove?(item) ?? true {
                self.remove(tag: tag)
                self.rxRemoved.onNext(item)
                self.rxSelections.onNext(self.tags.map({ $0.value }))
                self.setNeedsLayout()
            }
        }).disposed(by: disposeBag)
        
        self.tags.append(tag)
        self.setNeedsLayout()
    }
    
    
    
    @objc func showPopup() {
        
        guard let presenter = self.dropdownPeg else {
            print("dropdownPeg not provided")
            return
        }
        
        
        let renderEntryCell : ((T, ASTableNode, ReCellProperties) -> ASCellNode) = {
            [weak self] element, _,_ -> ASCellNode in
            
            return tell(ASTextCellNode()) {
                guard let this = self else { return }
                
                if this.isSelected(item: element) {
                    // disable text
                    $0.textNode.attributedText = Common.attributedString(element.string, color: Common.color.disabled_text_default.uicolor)
                } else {
                    $0.textNode.attributedText = Common.attributedString(element.string)
                }
            }
        }
        
        let willSelect : CallBack.typeCall<T, Bool> = { [unowned self] element -> Bool in
            
            guard maxSelection == nil || tags.count < maxSelection! else {
                return false
            }
            
            return !self.isSelected(item: element)
        }
        
        let didSelect : CallBack.typeCall<(T, IndexPath, ASTableNode), Void> = { (arg) -> Void in
            
            let (element, index, table) = arg
            
            self.add(item: element)
            
            table.reloadRows(at: [index], with: .automatic)
        }
        
        ReDropdownPopover<T>
            .prompt(presenter   : presenter,
                    peg         : self.view,
                    list        : self.list,
                    onSearch    : self.onSearch,
                    willSelect  : willSelect,
                    didSelect   : didSelect,
                    renderCell  : renderEntryCell
            )
            .bind (onNext: { [weak self] selection in
                // self?.emitSelection.accept(selection.item)
                
                // self?.add(item: selection.item)
            }).disposed(by: disposeBag)
    }
    
    func isSelected(item: T) -> Bool {
        return tags.contains { tag in
            tag.value.string == item.string
        }
    }
}


