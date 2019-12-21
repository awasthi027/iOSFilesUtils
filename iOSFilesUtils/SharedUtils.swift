//
//  SharedUtils.swift
//  iOSFilesUtils
//
//  Created by Ashish Awasthi on 21/12/19.
//  Copyright © 2019 Tanuja Awasthi. All rights reserved.
//

import Foundation

extension FSApplication {
    
    func subdirectoryForShared() -> String? {
        switch self {
        case .aha: return "aha"
        case .mapUpdate: return "mapupdate"
        case .binaryProtocal: return "binaryProtocal"
        case .ota: return "ota"
        default: return nil
        }
    }
}

@objc public class EFFUtils: NSObject {
    
    private struct Constants {
        static let directoryForSharedReportsWithShared = "shared"
        static let delayPurgeFilesInDays = 90
    }

    // MARK: - Public functions
    @objc public static func duplicateReportForEFF(report path: String, application: FSApplication) -> Bool {
        
        guard FSApplication.shared.isAppInstalled() else { return false }
        
        let sourceUrl  = URL.init(fileURLWithPath: path)
        let reportFileName = sourceUrl.lastPathComponent
        if var destUrl = self.sharedAppGroupEffDirectoryURL(application: application) {
            destUrl = destUrl.appendingPathComponent(reportFileName)
            return FSFilesUtils.copyfile(from: sourceUrl, to: destUrl)
        }
        
        return false
    }
    
    @objc public static func removeObsoleteEffReports(application: FSApplication) {

        guard let path = sharedAppGroupEffDirectoryURL(application: application) else { return }
        
        FSFilesUtils.deleteOldFiles(
            directory: path.absoluteString,
            days: Constants.delayPurgeFilesInDays,
            skipDirectoryAndContent: "",
            deleteEmptyDirectories: true)
    }
    
    // MARK: - Internal functions
    internal static func sharedAppGroupEffDirectoryURL(application: FSApplication) -> URL? {
        
        guard
            let fullPathAppGroupUrl = FSFilesUtils.appGroupDirectoryUrl(),
            let subdirectoryForEff = application.subdirectoryForShared()
            else {
                return nil
        }
        
        let effSharedDirUrl = fullPathAppGroupUrl.appendingPathComponent(Constants.directoryForSharedReportsWithShared)

        let applicationDirUrl = effSharedDirUrl.appendingPathComponent(subdirectoryForEff)

        let isCreated = FSFilesUtils.createDirectory(atPath: applicationDirUrl.path)
        
        FSLogInfo("sharedAppGroupEffDirectoryURL(\(application.prettyName())) => \(applicationDirUrl.path) \n status:- \(isCreated)")

        return applicationDirUrl
    }
}
