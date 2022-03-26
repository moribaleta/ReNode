//
//  ReColorPicker.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/**
 * ui component to display option to select a color
 * extends from ReEntry<ReColorPicker> to display label
 */
public final class ReColorPickerEntry : ReEntry<ReColorPicker> {
    
    public convenience init(label: String? = nil, required: Bool = false, colors: [String] = ReColorPicker.DEFAULT_COLORS) {
        self.init(display: .init(colors: colors))
        
        if let label = label {
            tell(ReTextNode()) {
                $0.attributedText = Common
                    .attributedString(
                        label,
                        attribute: .sublabel)
                self.label = $0
            }
        }
    }
    
}//ReColorPickerEntry


/**
 * ui component to display option to select a color
 */
open class ReColorPicker : ResizeableNode {
    
    public var colorEntries    = [ReColorEntry]()
    
    public var selectedIndex : Int? {
        didSet{
            self.setHighlight(index: self.selectedIndex)
        }
    }
    
    public var selectedColor : String? {
        self.colorEntries[self.selectedIndex ?? 0].hexString
    }
    
    public static let DEFAULT_COLORS = ["#00c3f9","#0090f5","#4157ae","#00d680","#00af43","#96c72c",
                                       "#ff9c3a","#ff653a","#ff7897","#f05071","#b22d83","#7d7d7d"]
    
    private var emitSelectedColor = PublishSubject<UIColor?>()
    
    public var rxColor : Observable<UIColor?> {
        emitSelectedColor.asObservable()
    }
    
    private var disposeBag = DisposeBag()
    
    private override init() {
        super.init()
    }
    
    public convenience init(colors: [String] = DEFAULT_COLORS) {
        self.init()
        
        self.colorEntries = colors.map {
            .init(color: $0)
        }
    }
    
    open override func didLoad() {
        super.didLoad()
        
        let obx = self.colorEntries.enumerated().map { (offset, item) -> Observable<Int> in
            return item.rxTap.map({offset})
        }
        
        Observable.merge(obx).subscribe(onNext: {
            [unowned self] index in
            
            if self.selectedIndex != index {
                self.selectedIndex = index
                self.emitSelectedColor.onNext(self.colorEntries[index].color)
            } else {
                self.selectedIndex = nil
                self.emitSelectedColor.onNext(nil)
            }
        }).disposed(by: self.disposeBag)
    }
    
    open func setHighlight(index selected : Int?) {
        self.colorEntries.enumerated().forEach { (index, item) in
            if selected == index {
                item.borderWidth = 2
            } else {
                item.borderWidth = 0
            }
        }
    }
    
    @discardableResult open func setHiglight(where: (String?) -> Bool) -> Int? {
        let index = self.colorEntries.firstIndex { color in
            `where`(color.toHex)
        }
        self.setHighlight(index: index)
        return index
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .hStackSpec {
                self.colorEntries
            }
            .align()
            .wrap()
            .lineSpacing()
    }
    
}//CommonColorSwitch


/**
 each color shown inside ReColorPicker
 */
public class ReColorEntry : ReButton {
    
    public let color        : UIColor
    public let hexString    : String
    
    var toHex : String? {
        self.color.toHexString()
    }
    
    public init(color hexString: String) {
        self.hexString  = hexString
        self.color      = .init(hexString: hexString)
        
        super.init()
        
        self.backgroundColor = self.color
        self.cornerRadius = 5
        self.set(
            config: .init(
                shape           : .rect,
                backgroundColor : self.color,
                borderColor     : Common.baseColor.green.uicolor
            ))
        self.borderWidth = 0
    }

}//ReColorEntry

