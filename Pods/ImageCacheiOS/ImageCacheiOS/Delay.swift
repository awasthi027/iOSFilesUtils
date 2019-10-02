//
//  Delay.swift
//  ImageCacheiOS
//
//  Created by Ashish Awasthi on 28/09/19.
//  Copyright © 2019 Tanuja Awasthi. All rights reserved.
//

import Foundation

/// Delay execution by some DispatchTimeInterval. Runs on the main thread.
///
/// - Parameter by: The DispatchTimeInterval to delay execution by
/// - Parameter closure: The closure to run.
func delay(by delay: DispatchTimeInterval, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}
