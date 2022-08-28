//
//  File.swift
//  
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation
import PackagePlugin

enum ImageGenError: LocalizedError  {
    case notASourceModule
    case noImagesToGenerate
}

@main
struct DatedImageGenerator: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else {
            throw ImageGenError.notASourceModule
        }
        
        let assetCatalogPaths = target.sourceFiles(withSuffix: "xcassets").compactMap { assetCatalog in
            return assetCatalog.path.string
        }

        let outputPath = context.pluginWorkDirectory
            .appending(["DatedImages.swift"])
        
        let invocation = PluginInvocation(catalogPaths: assetCatalogPaths, outputPath: outputPath.string)
        
        return [
            .buildCommand(
                displayName: "Generate Dated Images",
                executable: try context.tool(named: "DatedImageGeneratorLib").path,
                arguments: [try invocation.encodedString()],
                outputFiles: [outputPath]
            )
        ]
    }
}

// This should be identical between the plugin and its lib
struct PluginInvocation: Codable {
    let catalogPaths: [String]
    let outputPath: String

    func encodedString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
