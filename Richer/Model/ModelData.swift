//
//  ModelData.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/19.
//

import Foundation

var ohlci_m1: [OHLCI] = load("OHLC-M1.json")
var ohlci_m5: [OHLCI] = load("OHLC-M5.json")
var ohlci_m15: [OHLCI] = load("OHLC-M15.json")
var ohlci_h1: [OHLCI] = load("OHLC-H1.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Coundn't load \(filename) from main bundle: \n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Coundn't parse \(filename) as \(T.self): \n\(error)")
    }
}

struct IndexData {
    var ts: ULONG
    var value: Double
}

struct ChartProperty {
    var anchorPrice: Double
    var anchorTS: Int32
    var pointOffset: Double = 0
    var timeFrame: UInt = 15
    var candleWidth: Double = 3
    var dollarUnits: Double = 50

    var zoomSpeed: Double = 2
    var cursorPrice: Double = 0
    var cursorTime: Double = 0
}
