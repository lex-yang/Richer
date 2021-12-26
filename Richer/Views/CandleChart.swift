//
//  TendencyChart.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/19.
//

import CoreGraphics
import SwiftUI

struct CandleChart: View {
    @Binding var chartProps: ChartProperty

    @State private var dragPoint: CGPoint = CGPoint.zero

    @State private var _anchorIndex: Int
    @State private var followingChange = true
    
    private var _candles: [OHLCI]
    private var _levels: [ChartLevel]

    private var _candleShapes: [CandleShape] = []

    init(chartProps: Binding<ChartProperty>, candles: [OHLCI], levels: [ChartLevel]) {
        _chartProps = chartProps

        _candles = candles
        _levels = levels

        var candleIndex = 0
        let anchorTS = _chartProps.anchorTS.wrappedValue
        
        for index in 0..<_candles.count {
            let candle = _candles[index]
            _candleShapes.append(CandleShape(ohlc: candle))
            
            if candle.ts < anchorTS {
                candleIndex = index
            }
        }
        
        _anchorIndex = candleIndex - 1
    }
    
    var body: some View {
        Canvas { context, size in
            let candleSpan = chartProps.candleWidth + 1
            //let tsUnit: ULONG = ULONG(chartProps.timeFrame * 60)

            var visibleCandleCount: Int = Int(floor(size.width / candleSpan) + 1)
            
            if _anchorIndex + visibleCandleCount > _candles.count {
                visibleCandleCount = _candles.count - _anchorIndex
            }
            
            if visibleCandleCount == 0 {
                return
            }

            let t = CGAffineTransform.identity
            let scale = CGAffineTransform.init(scaleX: chartProps.candleWidth, y: chartProps.dollarUnits)

            var index = _anchorIndex
            for c in 0 ..< visibleCandleCount {
                let x = Double(c) * candleSpan - chartProps.pointOffset
                var y = _candles[index].c
                y = (y - chartProps.anchorPrice) * chartProps.dollarUnits
                y = size.height - y
                
                let candle = _candles[index]
                
                let path = _candleShapes[index].path.applying(scale)
                    .applying(
                        t.translatedBy(
                            x: x,
                            y: y
                        ))

                context.fill(
                    path,
                    with: candle.o > candle.c ? .color(.red) : .color(.green))

                context.stroke(
                    path,
                    with: candle.o > candle.c ? .color(.red) : .color(.green),
                    lineWidth: 1)
                
                index += 1
            }
            
            _levels.forEach { level in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height * level.level - chartProps.anchorPrice))
                path.addLine(to: CGPoint(x: size.width, y: size.height * level.level - chartProps.anchorPrice))
                
                context.stroke(path, with: .color(.gray), lineWidth: level.lineWidth)
            }
        }
        .background(Color.black)
        .drawingGroup()
        .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
                    .onChanged { v in
                    if dragPoint == CGPoint.zero {
                        dragPoint = v.location
                        followingChange = false
                    }
                    else {
                        
                        let newOffset = chartProps.pointOffset - Double(v.location.x - dragPoint.x)
                        chartProps.anchorPrice = chartProps.anchorPrice + Double(v.location.y - dragPoint.y) / chartProps.dollarUnits
                        
                        dragPoint = v.location
                        
                        let candleSpan = chartProps.candleWidth + 1
                        
                        if abs(newOffset) >= candleSpan {
                            let candleCount = floor(newOffset / candleSpan)
                            let tsAdjust = (Int32(candleCount) * Int32(chartProps.timeFrame) * 60)
                            
                            _anchorIndex += Int(candleCount)
                            chartProps.anchorTS += tsAdjust
                            chartProps.pointOffset = newOffset - (candleCount * candleSpan)
//                            print("candleCount: \(candleCount)")
//                            print("tsAdjust: \(tsAdjust)")
//                            print("newOffset: \(newOffset)")
//                            print("pointOffset: \(chartProps.pointOffset)")
                        }
                        else {
                            chartProps.pointOffset = newOffset
                        }
                    }
                    
                }
                .onEnded { v in
                    dragPoint = CGPoint.zero
                    followingChange = true
                }
        )
        .onChange(of: chartProps.anchorTS) { [chartProps] newState in
            if followingChange {
                _anchorIndex = _anchorIndex + Int(newState - chartProps.anchorTS) / Int(chartProps.timeFrame * 60)
                //print("CandleChart => anchorTS: \(newState - chartProps.anchorTS), \(newState)")
            }
        }
    }
}

struct CandleChart_Previews: PreviewProvider {
    static var previews: some View {
        CandleChart(
            chartProps: .constant(ChartProperty(
                anchorPrice: 1780.0,
                anchorTS: 1637940600,
                dollarUnits: 50.0)),
            candles: ohlci_m15,
            levels: [halfLevel]
        )
    }
}
