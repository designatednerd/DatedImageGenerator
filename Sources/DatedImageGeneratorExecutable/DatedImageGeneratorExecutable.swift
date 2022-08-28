//
//  File.swift
//  
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation
import DatedImageGeneratorLib
import XcodeIssueReporting

@main
struct DatedImageGeneratorExecutable {
    
    static func main() throws {
        let invocation = try JSONDecoder().decode(PluginInvocation.self, from: Data(ProcessInfo.processInfo.arguments[1].utf8))
        
        guard !invocation.catalogPaths.isEmpty else {
            XcodeIssue.report(XcodeIssue.warning("No asset catalogs were provided, code will not be generated"))
            return
        }
        
        let content: String = try DatedImageGeneratorLib.fileContent(for: invocation.catalogPaths)
        
        let exists = FileManager.default.fileExists(atPath: invocation.outputPath)
        
        if !exists {
            let parentPath = (invocation.outputPath as NSString).deletingLastPathComponent
            print("Creating folder at parent path \(parentPath)")
            try? FileManager.default.createDirectory(at: URL(string: parentPath)!, withIntermediateDirectories: true)
        }
        
        try content.write(toFile: invocation.outputPath,
                          atomically: true,
                          encoding: .utf8)
    }
}
