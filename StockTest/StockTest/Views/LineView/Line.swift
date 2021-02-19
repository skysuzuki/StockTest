//
//  Line.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

import Charts

struct Line: UIViewRepresentable {

    var entries : [ChartDataEntry]

    @Binding var chartValue: String
    @State var isSelectingValue = false

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $chartValue, selectingValue: $isSelectingValue)
    }

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
        //chart.animate(xAxisDuration: 2.0)
        chart.fitScreen()
        chart.delegate = context.coordinator
        chart.data = addData()

        return chart
    }

    // this func is required to conform to UIViewRepresentable protocol
    func updateUIView(_ uiView: LineChartView, context: Context) {
        //when data changes chartd.data update is required
        uiView.data = addData()
        if !isSelectingValue {
            uiView.animate(xAxisDuration: 2.0)
        }
    }

    func addData() -> LineChartData {
        let data = LineChartData()
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

    class Coordinator: NSObject, ChartViewDelegate {

        @Binding var chartValue: String
        @Binding var isSelectingValue: Bool

        init(value: Binding<String>, selectingValue: Binding<Bool>) {
            _chartValue = value
            _isSelectingValue = selectingValue
        }

        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            chartValue = String(entry.y)
            isSelectingValue = true
        }
    }

    //typealias UIViewType = LineChartView
}

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        Line(entries: [
            ChartDataEntry(x: 1, y: 10),
            ChartDataEntry(x: 2, y: 5),
            ChartDataEntry(x: 3, y: 20)
        ],
        chartValue: .constant("Test") )
    }
}
