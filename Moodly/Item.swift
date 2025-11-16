//
//  Item.swift
//  Moodly
//
//  Created by Reed Rawlings on 11/15/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
