//
//  DatedImage.swift
//  DatedImageGeneratorLib
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation
import SwiftUI

// The type we're using to generate code
public struct DatedImage: Hashable {
    public let imageName: String
    public let dateTakenString: String
    
    public init(imageName: String,
                dateTakenString: String) {
        self.imageName = imageName
        self.dateTakenString = dateTakenString
    }
    
    public var dateTaken: Date {
        ExifDateFormatter.date(from: self.dateTakenString)
    }
}
