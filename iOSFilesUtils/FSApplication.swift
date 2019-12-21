//
//  FSApplication.swift
//  iOSFilesUtils
//
//  Created by Ashish Awasthi on 21/12/19.
//  Copyright © 2019 Ashish Awasthi. All rights reserved.
//

import Foundation
import UIKit

@objc public enum FSApplication: Int {
    case ignite = 0     // Ignite Base App
    case sprint = 1         // Sprint App
    case nissan = 2        // Nissan App
    case audi = 3        // Audi India
    case rogers = 4        // Rogers Canda
    case aha = 5        // Aha US
    case mapUpdate = 6        // MOTA
    case ota = 7        // Over the air Update
    case binaryProtocal = 8        // Data Share
    case shared = 9 //Shared
}

extension FSApplication: CaseIterable {
    
}

extension FSApplication {
    
    public func urlSchemeName() -> String {
          guard
              let infoDict = Bundle.main.infoDictionary,
              let schemeValue = infoDict[schemeKey()] as? String,
              schemeValue.count > 0
              else {
                  let defaultValue = defaultScheme()
                  FSLogWarning("No custom scheme: $\(schemeKey()) defined !!! Use the default value: \(defaultValue)")
                  return defaultValue
          }
          FSLogInfo("Custom scheme: $\(schemeKey()) = \(schemeValue)")
          return schemeValue
      }
 
    internal func schemeKey() -> String {
           switch self {
           case .ignite:     return "FS_SCHEME_Ignite"
           case .sprint:     return "FS_SCHEME_Sprint"
           case .nissan:      return "FS_SCHEME_Nissan"
           case .audi:     return "FS_SCHEME_Audi"
           case .rogers:      return "FS_SCHEME_Rogers"
           case .aha:     return "FS_SCHEME_Aha"
           case .mapUpdate:  return "FS_SCHEME_Mapupdate"
           case .ota:      return "FS_SCHEME_ota"
           case .binaryProtocal: return "FS_SCHEME_BinaryProtocal"
           case .shared:  return "FS_Shared"
           }
       }

       internal func defaultScheme() -> String {
           switch self {
           case .ignite:     return "hmigniteIOT"
           case .sprint:     return "hmsprintIOT"
           case .nissan:      return "hmnissanIOT"
           case .audi:     return "hmaudiIOT"
           case .rogers:      return "hmrogersIOT"
           case .aha:     return "hmahaRadio"
           case .mapUpdate:  return "hmmapUpdate"
           case .ota:      return "hmoverairUpdate"
           case .binaryProtocal: return "binaryDataShare"
           case .shared: return "shared"
           }
    }
    public func prettyName() -> String {
           switch self {
           case .ignite:     return "Harman Ignite"
           case .sprint:     return "Sprint Drive"
           case .nissan:      return "Nissan Global"
           case .audi:     return "myAudiConnect"
           case .rogers:      return "Rogers Communication"
           case .aha:     return "Aha Radio"
           case .mapUpdate:  return "Map Update"
           case .ota:      return "Over Air Update"
           case .binaryProtocal:      return "Binary Protocal"
           case .shared:   return "Shared Data Report"
           }
       }
    static public func app(scheme: String) -> FSApplication? {
           return FSApplication.allCases.first { (curr) -> Bool in
               curr.urlSchemeName() == scheme
           }
       }

       public func isAppInstalled() -> Bool {
           
           let appScheme = urlSchemeName()
           
           guard let url = URL(string: "\(appScheme)://") else {
               FSLogInfo("\(appScheme) Application is not installed on device")
               return false
           }
                
           let result = FSMainThreadHelper.runSyncOnMainThread { () -> (Bool?) in
               let canOpen = UIApplication.shared.canOpenURL(url)
               return canOpen
           }
                        
           return result ?? false
       }
}
