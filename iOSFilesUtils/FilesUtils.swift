//
//  FilesUtils.swift
//  iOSFilesUtils
//
//  Created by Ashish Awasthi on 01/10/19.
//  Copyright © 2019 Ashish Awasthi. All rights reserved.
//

import Foundation
import UIKit
import ImageCacheiOS

@objc public enum FileCreatedStatus: Int {
    case failed
    case created
    case alreadyExist
}

@objc public enum ApplicationIdentifier: Int {
    case appOne
    case appTwo
    case appThree
    case appFour
}

enum ApplicationDirectoryPath: String {
    case reportAppOne = "report/appone"
    case reportAppTwo = "report/apptwo"
    case emailReportOne = "emailReport/appone"
    case emailReportTwo = "emailReport/apptwo"
    case emailReportThree = "emailReport/appThree"
    case emailReportFour = "emailReport/appFour"
}
// public struct ConstantsVaiable {
   private let GroupIdentifier = "APP_GROUP_ID"
   private let DefaultAppGroupIdentifier = "group.ashishCompany.report"
//}

@objc public class FSFilesUtils: NSObject {
 
    static let fileManager = FileManager.default
    
    @objc public static func documentDirectoryPath() ->String? {
        let docDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).last
        return docDirPath
    }
    
    @objc public static func appGroupUrlPath() ->String? {
        var appGroupId = DefaultAppGroupIdentifier
        if let infoDict = Bundle.main.infoDictionary, let appGroupIdItem = infoDict[GroupIdentifier] as? String, appGroupId.count > 0 {
            appGroupId = appGroupIdItem
        }
        if let appGroupUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
            return appGroupUrl.path
        }
        return nil
    }
    static func sharedAppGroupEffDirectoryURL(forApplication identifier: ApplicationIdentifier) ->URL? {
        var applicationDirPath: URL? = nil
        if let docDirPath = self.appGroupUrlPath(),let dirUrl = URL.init(string: docDirPath) {
            switch identifier {
            case .appOne:
                applicationDirPath = dirUrl.appendingPathComponent(ApplicationDirectoryPath.emailReportOne.rawValue)
                break
            case .appTwo:
                applicationDirPath = dirUrl.appendingPathComponent(ApplicationDirectoryPath.emailReportTwo.rawValue)
                break
            case .appThree:
                applicationDirPath = dirUrl.appendingPathComponent(ApplicationDirectoryPath.emailReportThree.rawValue)
                break
            case .appFour:
                applicationDirPath = dirUrl.appendingPathComponent(ApplicationDirectoryPath.emailReportThree.rawValue)
                break
             //TODO::2
             default:
                break
                //end
            }
            if let dirUrlItem = applicationDirPath {
                let isCreated = self.createDirectory(atPath: dirUrlItem.absoluteString)
                FSLogDebug("Director created at path: \(dirUrlItem.absoluteString) \n status:- \(isCreated.rawValue)")
               applicationDirPath = URL.init(fileURLWithPath: dirUrlItem.absoluteString)
            }
        }
        return applicationDirPath
    }

    @objc public static func createDirectory(atPath directoryPath: String) ->FileCreatedStatus {
        var directory: ObjCBool = ObjCBool(false)
        var fileCreateStatus = FileCreatedStatus.failed
        let fileExist = fileManager.fileExists(atPath: directoryPath, isDirectory: &directory)
        if fileExist == false {
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                fileCreateStatus = .created
            } catch {
                FSLogDebug(error.localizedDescription);
            }
        }else {
            fileCreateStatus = .alreadyExist
        }
        return fileCreateStatus
    }
    
    @objc static func copyfile(from sourceURL: URL, to destURL: URL) ->Bool {
        /* Copy report from compuation folder and paste into eff  */
        var isFileCopiedSuccess = false
        do {
          try fileManager.copyItem(at: sourceURL, to: destURL)
          isFileCopiedSuccess = true
        }
        catch let error {
            FSLogDebug("Faced while copying Error:-\n\(error)")
        }
        FSLogDebug("File copied \nfrom: \(sourceURL.path)\nto: \(destURL.path) \nSuccessfully:-\(isFileCopiedSuccess)")
        return isFileCopiedSuccess
      }
    
    @objc public static func duplicateReportForEFF(report path: String, appIdentifier: ApplicationIdentifier) ->Bool {
        if !self.isAppInstalled(app: .appFour) {
          return false
        }
        let sourceUrl = URL.init(fileURLWithPath: path)
        let reportFileName = sourceUrl.lastPathComponent
        if var destUrl = self.sharedAppGroupEffDirectoryURL(forApplication: appIdentifier) {
            destUrl = destUrl.appendingPathComponent(reportFileName)
            return self.copyfile(from: sourceUrl, to: destUrl)
        }else {
            return false
        }
     }
       //TODO::4
    @objc public static func isAppInstalled(app appIdentifier: ApplicationIdentifier) ->Bool {
        var appScheme = ""
        switch appIdentifier {
        case .appOne:
             appScheme = "appOne"
            break
          case .appTwo:
            appScheme = "appTwo"
          break
         case .appThree:
            appScheme = "appThree"
          break
          case .appFour:
            appScheme = "appFour"
            break
        default:
            break
        }
        guard let url = URL(string: "\(appScheme)://app") else {
         FSLogDebug("\(appScheme) application is not installed on device")
         return false
         }
        let result = FSMainThreadHelper.runSyncOnMainThread { () -> (Bool?) in
            let canOpen = UIApplication.shared.canOpenURL(url)
           return canOpen
          }
         return result ?? false
      }
    
    @objc public func deleteOldFiles(directory: String, days: UInt, deleteEmptyDirectories: Bool = true) {
        print ("deleteOldFiles:\(directory) days:\(days) deleteEmptyDirectories:\(deleteEmptyDirectories) ...")
    }
    
    @objc public func donwloadImage() {
        let storge = DiskStorage()
        storge.pruneStorage()
    }
}
