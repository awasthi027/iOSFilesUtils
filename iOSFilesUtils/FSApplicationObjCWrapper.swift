//
//  FSApplicationObjCWrapper.swift
//  iOSFilesUtils
//
//  Created by Ashish Awasthi on 21/12/19.
//  Copyright © 2019 Ashish Awasthi. All rights reserved.
//

import Foundation

@objc public class FSApplicationObjCWrapper: NSObject {

    @objc public static func urlScheme(for application: FSApplication) ->String? {
        return application.urlSchemeName()
    }
    
    @objc public static func isAppInstalled(_ application: FSApplication) ->Bool {
        return application.isAppInstalled()
    }
}
