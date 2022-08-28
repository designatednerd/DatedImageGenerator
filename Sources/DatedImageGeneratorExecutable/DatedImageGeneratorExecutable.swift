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
        
        do {
            try DatedImageGeneratorLib.generateCode(for: invocation)
        } catch {
            XcodeIssue.report(.error("Generation failed: \(error.localizedDescription)"))
        }
    }
}
