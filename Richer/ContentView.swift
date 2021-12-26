//
//  ContentView.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/19.
//

import SwiftUI

struct ContentView: View {
    @State var chartProps: ChartProperty = ChartProperty(
        anchorPrice: 1780,
        anchorTS: 1637940600
    )

    var body: some View {
        VStack {
            HStack {
                CandleChart(
                    chartProps: $chartProps,
                    candles: ohlci_m15,
                    levels: [halfLevel]
                )
                PriceAxis(chartProps: $chartProps)
                    .frame(width: 100.0)
            }
            TendencyChart(
                chartProps: $chartProps,
                indices: ohlci_m15.map { IndexData(ts: $0.ts, value: $0.rsi) },
                levels: [halfLevel]
            )
                .frame(height: 100)
            TimeAxis(chartProps: $chartProps)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
