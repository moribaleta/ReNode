//
//  SampleDropdown.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 2/23/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReNode
import RxSwift


class VCSampleDropdown : ASDKViewController<SampleDatedown> {
    static func spawn() -> VCSampleDropdown {
        return tell( VCSampleDropdown.init(node: .init()) ) {
            $0.title = "Dropdown"
        }
    }
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        
        self.node.dropdownPeg = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.node.dropNode.dropdownPeg      = self
        //self.node.dropNode.dropdownItems = (0...10).map({ $0.description })
        self.node
            .dropNode
            .reactiveBind(
                obx: .just(
                    ((0...10).map({$0.description}),
                     Int.random(in: (0...10)).description
                    )
                    
                )
            )
        self.node.dropNode.rxSelection
            .subscribe(onNext: { selection in
                print("dropdown selection: [\(selection?.string ?? "")]")
            }).disposed(by: disposeBag)
        
        

        self.node
            .customNode
            .reactiveBind(
                obx: .just(
                    ((0...10).map{_ in
                        SampleDropdownEntryType()
                    })
                )
            )
        
        
        
        self.node
            .dateNode
            .dropdownPeg = self
        
        self.node
            .timeNode
            .dropdownPeg = self
        
        
        
        
        
        let list =  ["one", "two", "three"] + (0...10).map({ $0.description })
        self.node.rudder.dropdownPeg = self
        self.node.rudder.bind(items: .just(list))
        self.node.rudder.set(selected: [list[0], list[2]])
        self.node.rudder.onSearch = { query -> [String] in
            let trimmed = query?.trim() ?? ""
            
            if trimmed.isEmpty {
                return list
            } else {
                let filtered = list.filter({ $0.contains(trimmed) })
                return filtered
            }
        }
        self.node.rudder.rxRemoved
            .subscribe(onNext: { item in
                print("rudder removed: [\(item.string)]")
            }).disposed(by: disposeBag)
        self.node.rudder.rxAdded
            .subscribe(onNext: { item in
                print("rudder added: [\(item.string)]")
            }).disposed(by: disposeBag)
        self.node.rudder.rxSelections
            .subscribe(onNext: { list in
                print("rudder selections: [\(list.map{ $0.string })]")
            }).disposed(by: disposeBag)
    }
}


struct DropdownOptionEntries : Hashable {
    var option1 : ReOptionActionType?
    var option2 : ReOptionActionItem?
    var option3 : ReOptionActionItem?
    
    var customOptions : [ReOptionActionItem] = [
        .init(title: "Arctic Monkeys"),
        .init(title: "Real Estate"),
        .init(title: "Current Joys")
    ]
}

class SampleDatedown : ReactiveNode<Any> {
    
    var dropNode    : ReDropdownTextNode<String>!
    var customNode  : ReDropdownNode<SampleDropdownEntryType>!
    var dateNode    : ReDatedown!
    var timeNode    : ReTimedown!
    var rudder      : ReRudder<String>!
    
    var basicOptionButton   : ReEntry<ReOptionButton>!
    var customOptionButton  : ReEntry<ReOptionButtonCustom>!
    var pillOptionButton    : ReEntry<ReOptionButtonPill>!
    var clearButton         : ReButton!
    
    var scrollNode  : ReScrollNode!
    
    var labelOption     : ReEntry<ReTextNode>!
    
    
    
    weak var dropdownPeg : UIViewController? {
        didSet {
            self.dropNode.dropdownPeg = self.dropdownPeg
            self.customNode.dropdownPeg = self.dropdownPeg
            self.dateNode.dropdownPeg = self.dropdownPeg
            self.timeNode.dropdownPeg = self.dropdownPeg
            self.rudder.dropdownPeg = self.dropdownPeg
            self.basicOptionButton.display.dropdownPeg = self.dropdownPeg
            self.customOptionButton.display.dropdownPeg = self.dropdownPeg
            self.pillOptionButton.display.dropdownPeg = self.dropdownPeg
        }
    }
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        
        self.dropNode   = .init(placeholder: "Select")
        
        self.dateNode   = .init(
            placeholder: "Start Date",
            isClearable : true
        )
        
        self.timeNode   = .init(
            placeholder: "Time Start",
            isClearable : true
        )
        
        self.scrollNode = tell(.init()) {
            $0?.layoutSpecBlock = {
                [unowned self] _,_ in
                self.layoutContent()
            }
        }
        
        
        self.customNode = tell(.init(placeholder: "Custom Select")){
            $0?.renderDisplay = {
                entry in
                tell(ReTextNode(entry?.string ?? "", color: .white)) {
                    $0.textContainerInset = .topInset(5)
                    $0.backgroundColor = entry?.isAvailable ?? false ? .blue : .red
                }
            }
            
            $0?.renderEntryCell = {
                entry in
                tell(ReCellNode()) {
                    let textNode        = ReTextNode(entry.string)
                    let availableNode   = ReTextNode(entry.isAvailable ? "available" : "not available", attribute: .sublabel)
                    $0.layoutSpecBlock = {
                        _,_ in
                        ASLayoutSpec
                            .hStackSpec {
                                textNode
                                availableNode
                            }
                            .align(.center)
                            .justify(.spaceAround)
                            .insetSpec(10)
                    }
                }
            }
        }
        
        
        self.rudder = .init()
        
        
    
        var emitOption = RePropRelay<DropdownOptionEntries>(value: .init())
        
        self.labelOption = .init(display: .init())
        
        self.basicOptionButton   = tell(ReEntry<ReOptionButton>(
            label: "ReOptionButton",
            display: .init())) {
                $0.display.reactiveBind(obx: .just(ReOptionActionType.CRUD_ACTIONS))
                $0.display
                    .rxOption
                    .bind { val in
                        emitOption.update(key: \.option1, value: val)
                    }.disposed(by: self.disposeBag)
        }
        
        
        self.customOptionButton  = tell(ReEntry<ReOptionButtonCustom>(
            label: "ReOptionButtonCustom",
            display: .init())) {
                $0.display.reactiveBind(obx: emitOption.rx.map{$0!.customOptions})
                $0.display
                    .rxOption
                    .bind { val in
                        emitOption.update(key: \.option2, value: val)
                    }.disposed(by: self.disposeBag)
        }
        
        
        
        self.pillOptionButton    = tell(ReEntry<ReOptionButtonPill>(
            label: "ReOptionButtonPill",
            display: .init())) {
                $0.display.reactiveBind(
                    obx: emitOption
                        .rx
                        .map{
                            ($0!.customOptions, $0!.option3)
                        })
                $0.display
                    .rxSelection
                    .bind { val in
                        emitOption.update(key: \.option3, value: val)
                    }.disposed(by: self.disposeBag)
        }
        
        self.clearButton = .create(text: "CLEAR", config: .ADD, callback: {
            emitOption.update { entries in
                return .init()
            }
        })
        
        
        
        emitOption
            .rx
            .unwrap()
            .bind (onNext: {
                [unowned self] val in
                let val = [
                    val.option1?.title,
                    val.option2?.title,
                    val.option3?.title
                ].map {
                    $0 ?? " - "
                }.joined(separator: ", ")

                self.labelOption.display.setText(val)
            })
            .disposed(by: self.disposeBag)
    }
    
    
    func layoutContent() -> ASLayoutSpec {
        ASStackLayoutSpec.vStackSpec {
            
            self.dropNode
                .flexBasis(unit: .fraction, value: 0.48)
            
            self.customNode
                .flexBasis(unit: .fraction, value: 0.48)
            
            ASLayoutSpec
                .hStackSpec {
                    self.dateNode
                        .flexBasis(unit: .fraction, value: 0.48)
                    self.timeNode
                        .flexBasis(unit: .fraction, value: 0.48)
                }
            
            
            self.rudder
            
            self.basicOptionButton
            self.customOptionButton
            self.pillOptionButton
            
            ASLayoutSpec
                .vStackSpec {
                    self.labelOption
                    self.clearButton
                }
                .align()
            
        }
        .align()
        .insetSpec(.init(horizontal: 20, vertical: 10))
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.scrollNode
        }
    }
    
    override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }
}


/**
 sample struct that implements ReDropdownEntryType
 */
struct SampleDropdownEntryType: ReDropdownEntryType {
    var string      : String {
        return value.description
    }
    
    var value           : Int
    var isAvailable     : Bool
    
    init() {
        self.value          = Int.random(in: (0...10))
        self.isAvailable    = value.isMultiple(of: 2)
    }
}
