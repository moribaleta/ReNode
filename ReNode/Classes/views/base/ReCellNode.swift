//
//  ReCellNode.swift
//  
//
//  Created by Gabriel Mori Baleta on 12/22/21.
//

import Foundation
import AsyncDisplayKit
import RxSwift


// TODO: do something here with reactivity?
open class ReCellNode : ASCellNode {
    
    public var disposedBag = DisposeBag()
    
    public override init(){
        super.init()
        self.automaticallyManagesSubnodes = true
    }
    
}


public class ReTextCellNode : ASTextCellNode {
    
}

