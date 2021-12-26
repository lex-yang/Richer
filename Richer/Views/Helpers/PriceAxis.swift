//
//  PriceAxis.swift
//  Richer
//
//  Created by Lex Yang on 2021/12/22.
//

import SwiftUI

struct PriceAxis: View {
    @Binding var chartProps: ChartProperty
    @State private var dragPoint: CGPoint = CGPoint.zero
    private let MinimunUnits: Double = 5
    private let PriceSpan: Double = 30

    var body: some View {
        Canvas { context, size in
            var basePrice = floor(chartProps.anchorPrice)
            let anchorOffset = (chartProps.anchorPrice - basePrice) * chartProps.dollarUnits
            
            for p in stride(from: size.height, to: -chartProps.dollarUnits, by: -chartProps.dollarUnits) {
                let t = Text(String(format: "%0.3f", basePrice))
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.white)

                context.draw(t, at: CGPoint(x: 40, y: p + anchorOffset))

                basePrice += 1.0
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
                        let o = Double(v.location.y - dragPoint.y) / chartProps.zoomSpeed

                        if MinimunUnits > chartProps.dollarUnits - o {
                            chartProps.dollarUnits = MinimunUnits
                        }
                        else {
                            chartProps.dollarUnits -= o
                        }

                        dragPoint = v.location
                    }
                }
                .onEnded { v in
                    dragPoint = CGPoint.zero
                }
        )
        .frame(width: 80)
    }
}

struct PriceAxis_Previews: PreviewProvider {
    static var previews: some View {
        PriceAxis(
            chartProps: .constant(ChartProperty(
                anchorPrice: 1780.0,
                anchorTS: 1637940600,
                dollarUnits: 30.0)
            ))
            .previewLayout(.fixed(width: 80, height: 600))
    }
}
