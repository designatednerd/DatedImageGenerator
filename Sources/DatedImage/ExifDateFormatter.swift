//
//  ExifDateFormatter.swift
//  DatedImageGeneratorLib
//
//  Created by Ellen Shapiro on 8/28/22.
//

import Foundation

public class ExifDateFormatter {
    public static let shared: DateFormatter = {
        var formatter = DateFormatter()
        // 2017:09:20 16:57:11
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter
    }()
    
    public static func date(from string: String) -> Date {
        guard let date = self.shared.date(from: string) else {
            return .distantPast
        }
          
        return date
    }
}
