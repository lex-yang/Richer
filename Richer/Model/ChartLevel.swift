//
//  ChartLevel.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/20.
//

import Foundation
import SwiftUI

let halfLevel = ChartLevel(levelColor: Color.gray, lineWidth: 1, level: 50)

struct ChartLevel {
    let levelColor: Color
    let lineWidth: CGFloat
    let level: CGFloat
}
