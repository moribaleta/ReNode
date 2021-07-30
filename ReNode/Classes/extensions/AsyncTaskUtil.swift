//
//  AsyncTaskUtil.swift
//  SampleApp
//
//  Created by Gabriel Mori Baleta on 7/30/21.
//

import Foundation
import Foundation
import RxSwift

public class AsyncTaskUtil {
    
    private static let  app_domain  = "com.renode.renode"
    
    public static let background  = DispatchQueue(label: app_domain, attributes: [ ])
    
    public static let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: AsyncTaskUtil.background)
}
