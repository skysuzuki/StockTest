//
//  Line.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

import Charts

struct Line: UIViewRepresentable {
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
    //@Binding var chartData: LineChartData

    //@Binding var lineChartView: LineChartView

    //Bar chart accepts data as array of BarChartDataEntry objects
    var entries : [ChartDataEntry]
    //@Binding var prices : [Double]
    //var p: [Price]?
//    @Binding var ppp: [Double]
//    @Binding var oP: NSOrderedSet?
//    @Binding var interval: String
    // this func is required to conform to UIViewRepresentable protocol

//    class Coordinator: NSObject, ChartViewDelegate {
//        // Chart Value Selected
//    }


    func makeUIView(context: Context) -> LineChartView {
        //crate new chart
        let chart = LineChartView()
        //it is convenient to form chart data in a separate func
        chart.xAxis.drawLabelsEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        chart.legend.enabled = false
        chart.leftAxis.drawLabelsEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.rightAxis.drawLabelsEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawAxisLineEnabled = false
        chart.animate(xAxisDuration: 2.0)
        chart.fitScreen()
        chart.data = addData()


        return chart
    }

    // this func is required to conform to UIViewRepresentable protocol
    func updateUIView(_ uiView: LineChartView, context: Context) {
        //when data changes chartd.data update is required

        uiView.data = addData()
        //uiView.data = chartData
        //uiView.notifyDataSetChanged()
    }

    func addData() -> LineChartData {
        let data = LineChartData()
        //BarChartDataSet is an object that contains information about your data, styling and more
//        var entries = [ChartDataEntry]()
//        if let p = oP {
//            entries = pricesForInterval(intervalPrices: p)
////            for i in 0..<prices.count {
////                entries.append(ChartDataEntry(x: Double(i), y: prices[i]))
////            }
//        }
        let dataSet = LineChartDataSet(entries: entries)
        // change bars color to green
        dataSet.colors = [NSUIColor.green]
        //change data label
        dataSet.label = ""

        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        data.addDataSet(dataSet)
        return data
    }

    //typealias UIViewType = LineChartView

    private func pricesForInterval(intervalPrices: NSOrderedSet) -> [ChartDataEntry] {
        var prices = [ChartDataEntry]()

        var index = 0
        for price in intervalPrices {
            if let price = price as? Price {
                prices.append(ChartDataEntry(x: Double(index), y: price.price))
                index += 1
                //prices.append(price.price)
            }
        }
//        if let pri = p {
//
//            for pr in pri {
//                prices.append(ChartDataEntry(x: Double(index), y: pr.price))
//                print("line:\(pr.price)")
//                index += 1
//            }
//        }
        return prices
    }

}

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        Line(entries: [
            ChartDataEntry(x: 1, y: 10),
            ChartDataEntry(x: 2, y: 5),
            ChartDataEntry(x: 3, y: 20)
        ])
    }
}
