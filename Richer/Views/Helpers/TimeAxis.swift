//
//  TimeAxis.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/22.
//

import SwiftUI

struct TimeAxis: View {
    @Binding var chartProps: ChartProperty
    @State private var dragPoint: CGPoint = CGPoint.zero
    private let MinimunUnits: Double = 2
    private let TimeSpan: Double = 30

    var body: some View {
        Canvas { context, size in
            let candleSpan = chartProps.candleWidth + 1
            let tsUnit: Int32 = Int32(chartProps.timeFrame * 60)
            let gridUnit = candleSpan * 12
            
            let anchorOffset: Int32 = chartProps.anchorTS % (tsUnit * 12)
            var baseTime = chartProps.anchorTS - anchorOffset
            
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            df.timeZone = TimeZone(identifier: "Asia/Taipei")

            for t in stride(from: 0, to: size.width, by: gridUnit) {
                let mark = Text(df.string(from: Date(timeIntervalSince1970: TimeInterval(baseTime))))
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.white)

                context.draw(mark, at: CGPoint(x: t - Double(anchorOffset / tsUnit) * candleSpan - chartProps.pointOffset, y: 20))

                baseTime += (tsUnit * 12)
            }
        }
        .drawingGroup()
        .background(Color.black)
        .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
                    .onChanged { v in
                    if dragPoint == CGPoint.zero {
                        dragPoint = v.location
                    }
                    else {
                        let o = Double(v.location.x - dragPoint.x) / (chartProps.zoomSpeed * 3)

                        if MinimunUnits > chartProps.candleWidth + o {
                            chartProps.candleWidth = MinimunUnits
                        }
                        else {
                            chartProps.candleWidth += o
                        }

                        dragPoint = v.location
                    }
                }
                .onEnded { v in
                    dragPoint = CGPoint.zero
                }
        )
        .frame(height: 40)
    }
}

struct TimeAxis_Previews: PreviewProvider {
    static var previews: some View {
        TimeAxis(
            chartProps: .constant(ChartProperty(
                anchorPrice: 1780.0,
                anchorTS: 1637940600,
                dollarUnits: 30.0)
            ))
            .previewLayout(.fixed(width: 600, height: 40))
    }
}
