//
//  DatedImageGeneratorCommand.swift
//  DatedImageGenerator
//
//  Created by Ellen Shapiro on 8/29/22.
//

import Foundation
import PackagePlugin

@main
struct DatedImageGeneratorCommand: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "DatedImageGeneratorExecutable")
        let toolUrl = URL(fileURLWithPath: tool.path.string)


        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            
            let assetCatalogPaths = target.sourceFiles(withSuffix: "xcassets").compactMap { assetCatalog in
                return assetCatalog.path.string
            }
            
            guard !assetCatalogPaths.isEmpty else {
                // Nothing to generate for this target
                continue
            }
            

            let outputPath = context.pluginWorkDirectory
                .appending(["DatedImages.swift"])
            
            let invocation = PluginInvocation(catalogPaths: assetCatalogPaths, outputPath: outputPath.string)
            let invocationString = try invocation.encodedString()
            
            let process = Process()
            process.executableURL = toolUrl
            process.arguments = [
                invocationString
            ]
            
            try process.run()
            process.waitUntilExit()
            
            if process.terminationReason == .exit && process.terminationStatus == 0 {
               // Success!
            } else {
                let problem = "\nreason: \(process.terminationReason)\nstatus \(process.terminationStatus)"
                Diagnostics.error("Could not run DatedImageGenerator: \(problem)")
            }
        }
    }
}

public struct PluginInvocation: Codable {
    public let catalogPaths: [String]
    public let outputPath: String

    public func encodedString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
