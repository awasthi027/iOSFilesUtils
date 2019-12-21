//
//  FilesUtils.swift
//  iOSFilesUtils
//
//  Created by Ashish Awasthi on 01/10/19.
//  Copyright © 2019 Ashish Awasthi. All rights reserved.
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
