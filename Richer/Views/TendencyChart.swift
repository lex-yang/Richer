//
//  TendencyChart.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/19.
//

import CoreGraphics
import SwiftUI

struct TendencyChart: View {
    @Binding var chartProps: ChartProperty
    
    @State private var dragPoint: CGPoint = CGPoint.zero

    @State private var _anchorIndex: Int
    @State private var followingChange = true

    @State private var pointLifter: Double = 0
    
    var indices: [IndexData]
    var levels: [ChartLevel]

    init(chartProps: Binding<ChartProperty>, indices: [IndexData], levels: [ChartLevel]) {
        _chartProps = chartProps
        self.indices = indices
        self.levels = levels
        
        var startIndex = 0
        let anchorTS = _chartProps.anchorTS.wrappedValue
        
        for i in 0 ..< indices.count {
            if indices[i].ts < anchorTS {
                startIndex = i
            }
        }
        
        _anchorIndex = startIndex - 1
    }
    
    var body: some View {
        Canvas { context, size in
            let candleSpan = chartProps.candleWidth + 1

            var visibleCount: Int = Int(floor(size.width / candleSpan) + 1)
            
            if _anchorIndex + visibleCount > indices.count {
                visibleCount = indices.count - _anchorIndex
            }
            
            if visibleCount == 0 {
                return
            }

            var path = Path()

            path.move(
                to: CGPoint(
                    x: -chartProps.pointOffset,
                    y: size.height * (100 - indices[_anchorIndex].value) * 0.01 - pointLifter
                )
            )

            for c in 1 ..< visibleCount {
                let x = Double(c) * candleSpan - chartProps.pointOffset
                let y = size.height * (100 - indices[_anchorIndex + c].value) * 0.01 - pointLifter
                
                path.addLine(
                    to: CGPoint(
                        x: x,
                        y: y
                    )
                )
            }
            context.stroke(path, with: .color(.yellow), lineWidth: 1)
            
            levels.forEach { level in
                var path = Path()
                let y = size.height * (100 - level.level) * 0.01 - pointLifter
                path.move(
                    to: CGPoint(
                        x: 0,
                        y: y)
                )
                path.addLine(
                    to: CGPoint(
                        x: size.width,
                        y: y)
                )
                
                context.stroke(path, with: .color(.gray), lineWidth: level.lineWidth)
            }
        }
        .background(Color.black)
        .drawingGroup()
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { v in
                    if dragPoint == CGPoint.zero {
                        dragPoint = v.location
                        followingChange = false
                    }
                    else {
                        let newOffset = chartProps.pointOffset - Double(v.location.x - dragPoint.x)
                        pointLifter = pointLifter - Double(v.location.y - dragPoint.y)
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
                //print("TendencyChart => anchorTS: \(newState - chartProps.anchorTS), \(newState)")
            }
        }
    }
}

struct TendencyChart_Previews: PreviewProvider {
    static var previews: some View {
        TendencyChart(
            chartProps: .constant(ChartProperty(
                anchorPrice: 1780,
                anchorTS: 1637940600
            )),
            indices: ohlci_h1.map { IndexData(ts: $0.ts, value: $0.rsi) },
            levels: [halfLevel]
        )
    }
}
