import XCTest
@testable import DatedImageGeneratorExecutable

final class DatedImageGeneratorTests: XCTestCase {
    
    var pathToTestAssetCatalog: String {
        let currentFilePath = #filePath
        let folder = (currentFilePath as NSString).deletingLastPathComponent
        let pathToCatalog = (folder as NSString).appendingPathComponent("Media.xcassets")
        return pathToCatalog
    }
    
    func testGettingNamesOfImageSets() throws {
        let namesAndDates = try DatedImageGeneratorExecutable.imageNamesAndDatesForCatalog(at: self.pathToTestAssetCatalog)
        let sorted = namesAndDates.sorted { t1, t2 in
            t1.0 < t2.0
        }
        
        XCTAssertEqual(sorted.map { $0.0 }, [
            "hank_case",
            "klausje",
        ])
    }
    
    func testContentForCatalog() throws {
        let content = try DatedImageGeneratorExecutable.fileContent(for: [self.pathToTestAssetCatalog], isForSwiftModule: true)
        
        XCTAssertEqual(content,
"""
/// This file auto-generated by Dated Image Generator. Do not edit manually.

import DatedImage
import SwiftUI

public struct AssetCatalogImages {
  public static let hank_case = DatedImage(imageName: "hank_case", dateTakenString: "2022:07:26 12:12:27")

  public static let klausje = DatedImage(imageName: "klausje", dateTakenString: "2017:09:20 16:57:11")
}

public extension DatedImage {
  var image: Image {
    Image(self.imageName, bundle: .module)
  }
}
""")
    }
}
