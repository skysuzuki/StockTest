//
//  Line.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

import Charts

struct Line: UIViewRepresentable {

    //Bar chart accepts data as array of BarChartDataEntry objects
    //var entries : [ChartDataEntry]
    var prices : [Double]
    // this func is required to conform to UIViewRepresentable protocol
    func makeUIView(context: Context) -> LineChartView {
        //crate new chart
        let chart = LineChartView()
        //it is convenient to form chart data in a separate func
        chart.xAxis.drawLabelsEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        chart.leftAxis.drawLabelsEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.rightAxis.drawLabelsEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawAxisLineEnabled = false
        chart.data = addData()
        return chart
    }

    // this func is required to conform to UIViewRepresentable protocol
    func updateUIView(_ uiView: LineChartView, context: Context) {
        //when data changes chartd.data update is required
        uiView.data = addData()
    }

    func addData() -> LineChartData{
        let data = LineChartData()
        //BarChartDataSet is an object that contains information about your data, styling and more
        var entries = [ChartDataEntry]()
        for i in 0..<prices.count {
            entries.append(ChartDataEntry(x: Double(i), y: prices[i]))
        }
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

    typealias UIViewType = LineChartView

}

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        Line(prices: [0.1, 22.1, 10.2] )
    }
}
