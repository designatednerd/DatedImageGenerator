//
//  DatedImageGenerator.swift
//  DatedImageGenerator
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation
import PackagePlugin

enum ImageGenError: LocalizedError  {
    case notASourceModule
    case noImagesToGenerate
    case couldNotConvertInvocationDataToString
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
        
        let invocation = PluginInvocation(catalogPaths: assetCatalogPaths, outputPath: outputPath.string, isForSwiftModule: true)
        
        return [
            .buildCommand(
                displayName: "Generate Dated Images",
                executable: try context.tool(named: "DatedImageGeneratorExecutable").path,
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
    let isForSwiftModule: Bool

    func encodedString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}

// Wrap so projects not using Xcode don't barf
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension DatedImageGenerator: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [PackagePlugin.Command] {
        let assetCatalogPaths = context.xcodeProject.filePaths
            .filter({ $0.string.hasSuffix("xcassets")})
            .map { $0.string }

        let outputPath = context.pluginWorkDirectory
            .appending(["DatedImages.swift"])
        
        let invocation = PluginInvocation(catalogPaths: assetCatalogPaths, outputPath: outputPath.string, isForSwiftModule: false)
        
        return [
            .buildCommand(
                displayName: "Generate Dated Images",
                executable: try context.tool(named: "DatedImageGeneratorExecutable").path,
                arguments: [try invocation.encodedString()],
                outputFiles: [outputPath]
            )
        ]
    }
}
#endif
