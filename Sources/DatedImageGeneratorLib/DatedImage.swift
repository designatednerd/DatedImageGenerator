//
//  DatedImage.swift
//  DatedImageGeneratorLib
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation
import SwiftUI

// The type we're using to generate code
public struct DatedImage {
    public let imageName: String
    public let dateTaken: Date
    
    public init(imageName: String,
                dateTaken: Date) {
        self.imageName = imageName
        self.dateTaken = dateTaken
    }    
}
