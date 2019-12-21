//
//  FSApplicationsService.swift
//  iOSFilesUtils
//
//  Created by Ashish Awasthi on 21/12/19.
//  Copyright © 2019 Ashish Awasthi. All rights reserved.
//

import Foundation
import UIKit

@objc public final class FSApplicationsService: NSObject {
    
    private struct Constants {
        static let applicationsOrderedList:[FSApplication] = [.ignite, .sprint, .nissan, .audi, .rogers, .aha, .mapUpdate, .ota,.binaryProtocal, .shared]

         struct Url {
             
             static let host = "x-callback-url"
             static let path = "/launch"
             
             struct Parameter {
                 static let source = "x-source"
                 static let result = "RESULT"
             }
         }
     }
    
    private var source:FSApplication
    
    @objc public init(sourceApplication:FSApplication) {
        self.source = sourceApplication
        super.init()
    }
    
    public func availableApplications() -> [FSApplication] {
        return Constants.applicationsOrderedList.filter { $0 == self.source || $0.isAppInstalled() }
    }

    @objc public func goToApplication(_ app: FSApplication) -> Bool {
        return self.goToApplication(app, paramResult: nil)
    }

    // MARK: Utilities
    private func goToApplication(_ app: FSApplication, paramResult: Bool?) -> Bool {
        guard app.isAppInstalled() else { return false }
        let result = FSMainThreadHelper.runSyncOnMainThread { () -> (Bool?) in
            if let url = self.urlForLaunchApplication(app, paramResult: paramResult) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return true
            }
            return false
        }

        return result ?? false
    }

    // Internal for Test Unit
    internal func urlForLaunchApplication(_ app: FSApplication, paramResult: Bool? = nil) -> URL? {

        var components = URLComponents()
        components.scheme = app.urlSchemeName()
        components.host = Constants.Url.host
        components.path = Constants.Url.path

        // Build parameters of URL
        
        var parameters: [URLQueryItem] = []
        parameters.append(URLQueryItem(name: Constants.Url.Parameter.source, value: source.urlSchemeName()))
        
        if let result = paramResult {
            parameters.append(URLQueryItem(name: Constants.Url.Parameter.result, value: result ? "OK" : "KO"))
        }
        
        components.queryItems = parameters

        return components.url
    }
     
}
