//
//  FSMainThreadHelper.swift
//  iOS_FS_Commons
//
//  Created by Herve Peroteau on 28/10/2019.
//  Copyright © 2019 NavBlue. All rights reserved.
//

import Foundation

class FSMainThreadHelper {
    
    public static func runSyncOnMainThread<T>(block: ()->(T?)) -> T? {
        
        // Check if already in MainThread
        if Thread.isMainThread {
            return block()
        }
        
        // Force to run block in MainThread
        let result = DispatchQueue.main.sync(execute: {
            return block()
        })
        
        return result
    }    
}
