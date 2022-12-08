//
//  File.swift
//  
//
//  Created by Ellen Shapiro on 12/8/22.
//

import Foundation
//import DatedImage
import PackagePlugin

struct DatedImageGeneratorCommand: CommandPlugin {
    
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
         
        let tool = try context.tool(named: "DatedImageGeneratorExecutable")
        let toolURL = URL(fileURLWithPath: tool.path.string)
        
        let assetCatalogPaths = try FileManager.default.contentsOfDirectory(atPath: context.package.directory.string)
            .filter({ $0.hasSuffix("xcassets")})
            .map { $0 }

        let outputPath = context.pluginWorkDirectory
            .appending(["DatedImages.swift"])
        
        let invocation = PluginInvocation(catalogPaths: assetCatalogPaths, outputPath: outputPath.string, isForSwiftModule: false)
        
        let invocationData = try JSONEncoder().encode(invocation)
        guard let invocationString = String(data: invocationData, encoding: .utf8) else {
            throw ImageGenError.couldNotConvertInvocationDataToString
        }
                        
        let process = try Process.run(toolURL, arguments: [invocationString])
        process.waitUntilExit()
    }
}
