//
//  File.swift
//  
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation
import XcodeIssueReporting
import ImageIO

@main
struct DatedImageGeneratorExecutable {
    
    static func main() throws {
        let invocation = try JSONDecoder().decode(PluginInvocation.self, from: Data(ProcessInfo.processInfo.arguments[1].utf8))
        
        guard !invocation.catalogPaths.isEmpty else {
            XcodeIssue.report(XcodeIssue.warning("No asset catalogs were provided, code will not be generated"))
            return
        }
        
        let content: String = try self.fileContent(for: invocation.catalogPaths)
        
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
    
    public enum Error: LocalizedError {
        case noImagesToCheck
        case notImplemented
    }
    
    static func readMetadata(fromImageSet imageSet: URL) throws -> NSDictionary? {
        let contents = try self.contentsOfFolderAtPath((imageSet as NSURL).path!)
        let notJSONContents = contents.filter { !$0.lastPathComponent.hasSuffix("json")}
        
        guard let firstNonJSON = notJSONContents.first else {
            throw Error.noImagesToCheck
        }
        
        if
            let source = CGImageSourceCreateWithURL(firstNonJSON as CFURL, nil),
            let metadata: NSDictionary = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) {
            return metadata
        }
        return nil
    }
    
    static func fileContent(for catalogPaths: [String]) throws -> String {
        let allImageNamesAndDates = try catalogPaths.flatMap { try imageNamesAndDatesForCatalog(at: $0) }
        
        var content = String()
        
        let header =
"""
/// This file auto-generated by Dated Image Generator. Do not edit manually.

import DatedImage
import SwiftUI

public struct AssetCatalogImages {

"""
        content.append(header)
        
        let sortedInfo = allImageNamesAndDates.sorted { tuple1, tuple2 in
            return tuple1.0 < tuple2.0
        }
        
        let images = sortedInfo.map { (imageName, dateTakenString) in
            return
"""
  public static let \(imageName) = DatedImage(imageName: "\(imageName)", dateTakenString: "\(dateTakenString)")
"""
        }
        
        content.append(images.joined(separator: "\n\n"))
        
        let footer =
"""

}

public extension DatedImage {
  var image: Image {
    Image(self.imageName, bundle: .module)
  }
}
"""
        content.append(footer)
        return content
    }

    
    static func imageNamesAndDatesForCatalog(at path: String) throws  -> [(String, String)] {
        let contents = try contentsOfFolderAtPath(path)
        
        let imageSets = contents
            .filter { $0.lastPathComponent.hasSuffix(".imageset") }
        let imageNames = imageSets.map { ($0.lastPathComponent as NSString).deletingPathExtension }
        let imageMetadata = try imageSets.map { try readMetadata(fromImageSet: $0) }
        let dateTakens: [String] = imageMetadata.map { dictionary in
            let exifDict = dictionary?.value(forKey: "{Exif}") as? [String: Any]
            return exifDict?["DateTimeOriginal"] as? String ?? ""
        }
        
        var tuples = [(String, String)]()
        for index in 0..<imageNames.count {
            tuples.append((imageNames[index], dateTakens[index]))
        }
        
        return tuples
    }

    
    private static func contentsOfFolderAtPath(_ path: String) throws -> [URL] {
        let escapedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let url = URL(string: escapedPath)!
        
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey] , options: .skipsHiddenFiles)
        
        return contents
    }
}

// This should be identical between the plugin and its lib
public struct PluginInvocation: Codable {
    public let catalogPaths: [String]
    public let outputPath: String

    public func encodedString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}

