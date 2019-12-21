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

private struct Constants {
    static let FS_APP_GROUP_ID: String = "FS_APP_GROUP_ID"
    static let DefaultAppGroupIdentifier: String = "group.airbus.report"
}

@objc public enum FileStatus: Int {
    case failed
    case created
    case alreadyExist
}

private struct FileInfo {
    var url: URL
    var createdDaysAgo: Int = 0
    var isDirectory: Bool = false
    init(with url: URL, createdDaysAgo: Int, isDirectory: Bool = false) {
        self.url = url
        self.createdDaysAgo = createdDaysAgo
        self.isDirectory = isDirectory
    }
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

@objc public class FSFilesUtils: NSObject {
 
    static let fileManager = FileManager.default
    
    @objc public static func documentDirectoryPath() ->String? {
        let docDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).last
        return docDirPath
    }
    
    @objc public static func appGroupDirectoryUrl() -> URL? {
           var appGroupId = Constants.DefaultAppGroupIdentifier
           if let infoDict = Bundle.main.infoDictionary, let appGroupIdItem = infoDict[Constants.FS_APP_GROUP_ID] as? String, appGroupId.count > 0 {
               appGroupId = appGroupIdItem
           }
           
           return fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
       }
    @objc public static func appGroupUrlPath() ->String? {
        var appGroupId = Constants.DefaultAppGroupIdentifier
        if let infoDict = Bundle.main.infoDictionary, let appGroupIdItem = infoDict[Constants.FS_APP_GROUP_ID] as? String, appGroupId.count > 0 {
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
             default:
                break
            }
            if let dirUrlItem = applicationDirPath {
                let isCreated = self.createDirectory(atPath: dirUrlItem.absoluteString)
                FSLogInfo("Director created at path: \(dirUrlItem.absoluteString) \n status:- \(isCreated.rawValue)")
               applicationDirPath = URL.init(fileURLWithPath: dirUrlItem.absoluteString)
            }
        }
        return applicationDirPath
    }

    @objc public static func createDirectory(atPath directoryPath: String) ->FileStatus {
        var directory: ObjCBool = ObjCBool(false)
        var fileCreateStatus = FileStatus.failed
        let fileExist = fileManager.fileExists(atPath: directoryPath, isDirectory: &directory)
        if fileExist == false {
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                fileCreateStatus = .created
            } catch {
               // FSLogError(error.localizedDescription);
            }
        }else {
            fileCreateStatus = .alreadyExist
        }
        return fileCreateStatus
    }
    
    @objc public static func copyfile(from sourceURL: URL, to destURL: URL) ->Bool {
        /* Copy report from compuation folder and paste into eff  */
        var isFileCopiedSuccess = false
        do {
          try fileManager.copyItem(at: sourceURL, to: destURL)
          isFileCopiedSuccess = true
        }
        catch let error {
            FSLogError("Faced while copying Error:-\n\(error)")
        }
       // FSLogInfo("File copied \nfrom: \(sourceURL.path)\nto: \(destURL.path) \nSuccessfully:-\(isFileCopiedSuccess)")
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
         FSLogInfo("\(appScheme) application is not installed on device")
         return false
         }
        let result = FSMainThreadHelper.runSyncOnMainThread { () -> (Bool?) in
            let canOpen = UIApplication.shared.canOpenURL(url)
           return canOpen
          }
         return result ?? false
      }
    
  @objc public static func deleteOldFiles(directory: String, days: Int, skipDirectoryAndContent directoryName: String = "", deleteEmptyDirectories: Bool = true) {
      if let directoryURL = URL.init(string: directory) {
          let resourceKeys = Set<URLResourceKey>([.creationDateKey, .nameKey, .isDirectoryKey])
          let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: Array(resourceKeys),options: .skipsHiddenFiles)!
          var fileURLs: [FileInfo] = []
          var directoryURLs: [FileInfo] = []
          let calendar = Calendar.current
          let todayDateStartDay = calendar.startOfDay(for: Date())
          for case let fileURL as URL in enumerator {
              guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let name = resourceValues.name, let createdDate = resourceValues.creationDate
                  else { continue }
              let createdDateStartDay = calendar.startOfDay(for: createdDate)
              let components = calendar.dateComponents([.day], from: createdDateStartDay , to: todayDateStartDay)
              guard let createdDaysAgo = components.day else { continue }
              let fileInfo = FileInfo.init(with: fileURL, createdDaysAgo: createdDaysAgo, isDirectory: isDirectory)
              if fileInfo.isDirectory {
                  if name == directoryName {
                      enumerator.skipDescendants()
                  }else {
                      directoryURLs.append(fileInfo)
                  }
              }else {
                  fileURLs.append(fileInfo)
              }
          }
          // Delete files
          for item in fileURLs {
              if item.createdDaysAgo > days {
                  do {
                      try fileManager.removeItem(at: item.url) }
                  catch let error {
                      FSLogError("Error while deleting report after days: \(item.createdDaysAgo) fromPath: \(item.url.path) Error : \(error)")
                  }
              }else {
                  FSLogInfo("directory still valid created days ago: \(item.createdDaysAgo)")
              }
          }
          // Delete empty Directories
          if deleteEmptyDirectories {
              for item in directoryURLs {
                  let listOfFiles = try? fileManager.contentsOfDirectory(atPath: item.url.path)
                  if item.createdDaysAgo > days && listOfFiles?.count == 0 {
                      do {
                          try fileManager.removeItem(at: URL.init(fileURLWithPath: item.url.path)) }
                      catch let error {
                          FSLogError("error while deleting diretory after days:\(item.createdDaysAgo) fromPath: \(item.url.path) Error: \(error)")
                      }
                  }else {
                      FSLogInfo("Directory still valid created days ago: \(item.createdDaysAgo)")
                  }
              }
          }
      }
  }
    @objc public func donwloadImage() {
        let storge = DiskStorage()
        storge.pruneStorage()
    }
}
