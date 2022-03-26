//
//  ReDatedownPopover.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import RxSwift
import AsyncDisplayKit

public class ReDatedownPopover : ASDKViewController<UIReDatedownPopover>{
    
    var date        : Date?         = nil
    var isClearable : Bool          = false
    var disposeBag  : DisposeBag    = DisposeBag()
    
    var emitDate        : PublishSubject<Date?> = .init()
    var datePickerMode  : UIDatePicker.Mode = .date
    
    static func prompt(
        _ date          : Date?,
        refVC           : UIViewController,
        peg             : UIView,
        isClearable     : Bool = false,
        datePickerMode  : UIDatePicker.Mode = .date
    ) -> Observable<Date?> {
        let vc = tell(self.spawn(date, isClearable: isClearable)) {
            $0.preferredContentSize = .init(width: 320, height: 250)
            $0.datePickerMode       = datePickerMode
        }
        
        refVC.presentPopup(vc: vc, peg: peg)
        return vc.emitDate
    }
    
    static func spawn(_ date: Date?, isClearable: Bool = false) -> ReDatedownPopover {
        tell(.init(node: .init(isClearable))) {
            $0.date         = date
            $0.isClearable  = isClearable
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.emitDate.onNext(self.date)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.node.datePicker.date           = self.date ?? Date()
        self.node.isClearable               = self.isClearable
        
        self.node.datePicker.datePickerMode = self.datePickerMode
        
        self.node.datePicker.rx.date
            .bind { [unowned self] in
                self.date = $0
            }.disposed(by: self.disposeBag)
        
        self.node.clearNode
            .rxTap
            .filter { [unowned self] in
                self.isClearable
            }
            .bind {
                [unowned self] in
                self.date = nil
                self.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
}//ReDatedownPopover


public class UIReDatedownPopover : ResizeableNode {
    
    var pickerNode : ResizeableNode!
    var clearNode  : ReButton!
    
    var datePicker : UIDatePicker {
        self.pickerNode.view as! UIDatePicker
    }
    
    var isClearable : Bool = false
    
    init(_ isClearable: Bool = false) {
        super.init()
        
        self.pickerNode = .init(viewBlock: {
            UIDatePicker()
        })
        
        self.datePicker.datePickerMode  = .date
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.clearNode  = tell(.init()) {
            $0?.set(icon: "", text: "Clear", config: .LINK)
        }
        self.backgroundColor = .white
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.pickerNode
                    .flex()
                
                if self.isClearable {
                    self.clearNode
                }
            }
            .align()
            .insetSpec(10)
    }
    
}//UIReDatedownPopover
