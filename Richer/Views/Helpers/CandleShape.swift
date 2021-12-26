//
//  CandleShape.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/20.
//

import Foundation
import CoreGraphics
import SwiftUI

struct CandleShape {
    var _ohlc: OHLCI

    private var _path: Path
    
    init(ohlc: OHLCI) {
        _ohlc = ohlc
        
        _path = Path()

        //let c = 0
        let o = ohlc.c - ohlc.o
        let h = ohlc.c - ohlc.h
        let l = ohlc.c - ohlc.l

        _path.addRect(CGRect(origin: .zero, size: CGSize(width: 1, height: o)))
        _path.move(to: CGPoint(x: 0.5, y: h))
        _path.addLine(to: CGPoint(x: 0.5, y: l))
    }
    
    var path: Path {
        return _path
    }
}
