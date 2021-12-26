//
//  OHLCI.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/19.
//

import Foundation
import SwiftUI

// {"o":1903.634,"h":1903.634,"c":1903.634,"l":1903.634,"la":1903.636,"lb":1903.634,"ts":1609722000,"rsi":62.5,"ma21":1894.276,"ma50":1888.627,"adp":1.7,}

struct OHLCI: Codable, Hashable {
    var o: Double
    var h: Double
    var c: Double
    var l: Double
    var ts: ULONG
    var rsi: Double
    var ma21: Double
    var ma50: Double
}
