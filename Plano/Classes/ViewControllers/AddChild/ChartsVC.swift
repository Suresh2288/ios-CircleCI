//
//  ChartsVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ChartsVC: UIViewController{
    
    var chartsTitle : String = ""
    var yearsData : [String] = []
    var isOverView : Bool = false
    var isPresented : Bool = false
    
    var monthsData : [String] = ["Mar","Jun","Sep","Dec"]
    var leftEyeData : [Double] = []
    var rightEyeData : [Double] = []
    var averageLeftEyeData : [Double] = []
    var averageMonthForLeftEye : [Double] = []
    var averageRightEyeData : [Double] = []
    var averageMonthForRightEye : [Double] = []
    var myopiaProgressList : Results<MyopiaProgressList>!
    var myopiaSummaryList : Results<MyopiaProgressSummary>!
    
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var lineChartView : LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView.delegate = self
        
        if isOverView{
            
            // First we hide chartData for overview
            chartView.data = nil
            chartView.isHidden = true
            
            // LineChart with no data
            lineChartView.noDataText = "Please add myopia progress to see overview"
            lineChartView.noDataFont =  FontBook.Light.of(size: 15.0)
            
            // Configuration for LineChart
            lineChartView.chartDescription?.enabled = false
            lineChartView.leftAxis.enabled = true
            lineChartView.rightAxis.enabled = false
            lineChartView.drawGridBackgroundEnabled = false
            lineChartView.drawBordersEnabled = false
            lineChartView.pinchZoomEnabled = false
            lineChartView.dragEnabled = false
            lineChartView.doubleTapToZoomEnabled = false
            
            // Legend
            let legend : Legend = lineChartView.legend
            legend.font = FontBook.Light.of(size: 10.0)
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
            legend.drawInside = false
            
            // XAxis
            let xaxis = lineChartView.xAxis
            xaxis.labelFont = FontBook.Light.of(size: 10.0)
            xaxis.drawGridLinesEnabled = false
            xaxis.labelPosition = .bottom
            xaxis.centerAxisLabelsEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: yearsData)
            xaxis.granularity = 1
            
            //LeftAxis [yAxis] Formatter
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.maximumFractionDigits = 1
            
            // YAxis
            let yaxis = lineChartView.leftAxis
            yaxis.spaceTop = 0.35
            yaxis.drawGridLinesEnabled = true
            yaxis.drawAxisLineEnabled = false
            yaxis.labelFont = FontBook.Light.of(size: 10.0)
            yaxis.axisMinimum = 0
            
            setUpChartOverViewRecords()
            
        }else{
            
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            var months = [String]()
//            
//            var dateObject = [Date]()
//
//            for i in 0..<months.count{
//                dateObject.append(dateFormatter.date(from: months[i])!)
//            }
//            
//            dateFormatter.dateFormat = "MMM"
//            
//            for i in 0..<dateObject.count{
//                monthsData.append(dateFormatter.string(from: dateObject[i]))
//            }
            
            // Initial State for Chart View
            
            // Setting description and no data text
            chartView.noDataText = "Please add myopia progress to see the records"
            chartView.noDataFont = FontBook.Light.of(size: 15.0)
            chartView.chartDescription?.text = ""
            chartView.rightAxis.enabled = false
            chartView.backgroundColor = UIColor.white
            chartView.dragEnabled = false
            chartView.highlightFullBarEnabled = false
            chartView.doubleTapToZoomEnabled = false
            chartView.pinchZoomEnabled = false
            
            // Legend
            let legend = chartView.legend
            legend.font = FontBook.Light.of(size: 10.0)
            legend.enabled = true
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .vertical
            legend.drawInside = true
            legend.yOffset = 10.0;
            legend.xOffset = 10.0;
            legend.yEntrySpace = 0.0;
            
            // XAxis
            let xaxis = chartView.xAxis
            xaxis.labelFont = FontBook.Light.of(size: 10.0)
            xaxis.drawGridLinesEnabled = false
            xaxis.centerAxisLabelsEnabled = true
            xaxis.labelPosition = .bottom
            xaxis.valueFormatter = IndexAxisValueFormatter(values: monthsData)
            xaxis.granularity = 1
            
            //LeftAxis [yAxis] Formatter
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.maximumFractionDigits = 1
            
            let yaxis = chartView.leftAxis
            yaxis.spaceTop = 0.35
            yaxis.drawGridLinesEnabled = true
            yaxis.drawAxisLineEnabled = false
            yaxis.labelFont = FontBook.Light.of(size: 10.0)
            yaxis.axisMinimum = 0
            
            // Enable this if the data is large scale
            //yaxis.valueFormatter = LargeValueFormatter()
            
            setUpChartViewForYearlyRecords()
        }
    }
    
    func setUpChartOverViewRecords(){
        lineChartView.noDataText = "No Records"
        
        // Require data for overview calculation
//        var leftEyeTotal : Double = 0
//        var rightEyeTotal : Double = 0
//        var totalLeftEyeData : [Double] = []
//        var totalRightEyeData : [Double] = []
//        var leftMonthsList : Results<MyopiaProgressList>!
//        var rightMonthsList : Results<MyopiaProgressList>!
        
        // Overview Calculation
            
        myopiaSummaryList = MyopiaProgressSummary.getMyopiaProgressByYearWithSort()
        
        print("Myopia Summary : \(myopiaSummaryList)")
        
//            myopiaProgressList = MyopiaProgressList.getMyopiaProgressByYearWithSort(year: chartsTitle)
        
        for i in 0..<myopiaSummaryList.count{
            leftEyeData.append(Double(myopiaSummaryList[i].leftEyeValue)!)
            rightEyeData.append(Double(myopiaSummaryList[i].rightEyeValue)!)
            //months.append(myopiaProgressList[i].date.substring(from: 0, to: 9))
        }
        
        var dataEntries: [ChartDataEntry] = []
        var dataEntries1: [ChartDataEntry] = []
        
        for i in 0..<self.leftEyeData.count {
            
            let dataEntry = ChartDataEntry(x: Double(i) , y: self.leftEyeData[i])
            dataEntries.append(dataEntry)
            
            let dataEntry1 = ChartDataEntry(x: Double(i) , y: self.rightEyeData[i])
            dataEntries1.append(dataEntry1)
        }
//            leftMonthsList =  MyopiaProgressList.getNoOfMonthsLeftEyeIncluded(year: yearsData[i])
//            rightMonthsList =  MyopiaProgressList.getNoOfMonthsRightEyeIncluded(year: yearsData[i])
//            
//            if leftMonthsList.count == 1{
//                averageMonthForLeftEye.append(3)
//            }else if leftMonthsList.count == 2{
//                averageMonthForLeftEye.append(6)
//            }else if leftMonthsList.count == 3{
//                averageMonthForLeftEye.append(9)
//            }else{
//                averageMonthForLeftEye.append(12)
//            }
//            
//            if rightMonthsList.count == 1{
//                averageMonthForRightEye.append(3)
//            }else if rightMonthsList.count == 2{
//                averageMonthForRightEye.append(6)
//            }else if rightMonthsList.count == 3{
//                averageMonthForRightEye.append(9)
//            }else {
//                averageMonthForRightEye.append(12)
//            }
//            
//            for j in 0..<myopiaProgressList.count{
//                leftEyeTotal += Double(myopiaProgressList[j].leftEyeValue)!
//                rightEyeTotal += Double(myopiaProgressList[j].rightEyeValue)!
//            }
//            
//            totalLeftEyeData.append(leftEyeTotal)
//            leftEyeTotal = 0
//            totalRightEyeData.append(rightEyeTotal)
//            rightEyeTotal = 0
//            
//        }
//        
//        // Average Data
//        for i in 0...4{
//            averageLeftEyeData.append((totalLeftEyeData[i]/averageMonthForLeftEye[i])*3)
//            averageRightEyeData.append((totalRightEyeData[i]/averageMonthForRightEye[i])*3)
//        }
//        
//        var dataEntries: [ChartDataEntry] = []
//        var dataEntries1: [ChartDataEntry] = []
//        
//        for i in 0..<self.yearsData.count {
//            
//            let dataEntry = ChartDataEntry(x: Double(i) , y: self.averageLeftEyeData[i])
//            dataEntries.append(dataEntry)
//            
//            let dataEntry1 = ChartDataEntry(x: Double(i) , y: self.averageRightEyeData[i])
//            dataEntries1.append(dataEntry1)
//        }
        
        let averageLeftEyeDataSet = LineChartDataSet(values: dataEntries, label: "Left Eye")
        let averageRightEyeDataSet = LineChartDataSet(values: dataEntries1, label: "Right Eye")
        averageLeftEyeDataSet.colors = [Color.Cyan.instance()]
        averageLeftEyeDataSet.lineWidth = 1.5
        averageLeftEyeDataSet.circleRadius = 4.0
        averageLeftEyeDataSet.circleHoleRadius = 2.0
        averageLeftEyeDataSet.circleColors = [Color.Cyan.instance()]
        
        averageRightEyeDataSet.circleColors = [Color.FlatOrange.instance()]
        averageRightEyeDataSet.lineWidth = 1.5
        averageRightEyeDataSet.circleRadius = 4.0
        averageRightEyeDataSet.circleHoleRadius = 2.0
        averageRightEyeDataSet.colors = [Color.FlatOrange.instance()]
        
        
        let dataSets : [LineChartDataSet] = [averageLeftEyeDataSet,averageRightEyeDataSet]
        
        let lineChartData = LineChartData(dataSets: dataSets)
        lineChartData.setValueFont(FontBook.Light.of(size: 10.0))
        lineChartData.setValueFormatter(LargeValueFormatter())
        
        lineChartView.data = lineChartData
        lineChartView.notifyDataSetChanged()
        lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOption: .linear)
        
    }

    func setUpChartViewForYearlyRecords(){
        lineChartView.noDataText = "No Records"
        
        myopiaProgressList = MyopiaProgressList.getMyopiaProgressByYearWithSort(year: chartsTitle)
        
        for i in 0..<myopiaProgressList.count{
            leftEyeData.append(Double(myopiaProgressList[i].leftEyeValue)!)
            rightEyeData.append(Double(myopiaProgressList[i].rightEyeValue)!)
            //months.append(myopiaProgressList[i].date.substring(from: 0, to: 9))
        }
        
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        
        for i in 0..<self.monthsData.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i) , y: self.leftEyeData[i])
            dataEntries.append(dataEntry)
            
            let dataEntry1 = BarChartDataEntry(x: Double(i) , y: self.rightEyeData[i])
            dataEntries1.append(dataEntry1)
        }
        
        // Init the BarChartDataSet with data come from realm, label will be used at legend
        let leftEyeDataSet = BarChartDataSet(values: dataEntries, label: "Left Eye")
        let rightEyeDataSet = BarChartDataSet(values: dataEntries1, label: "Right Eye")
        
        // Setting the color for each BarChartDataSet
        let dataSets: [BarChartDataSet] = [leftEyeDataSet,rightEyeDataSet]
        leftEyeDataSet.colors = [Color.Cyan.instance()]
        rightEyeDataSet.colors = [Color.FlatOrange.instance()]
        
        // Setting the BarChartData which will assign to BarChartView
        let chartData = BarChartData(dataSets: dataSets)
        chartData.setValueFont(FontBook.Light.of(size: 10.0))
        chartData.setValueFormatter(LargeValueFormatter())
        
        // Spacing and Width Calcuation
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"
        
        // XAxix will be shown group chartdata on each month with the following setting
        let groupCount = monthsData.count
        let startYear = 0
        chartData.barWidth = barWidth
        chartView.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        chartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        
        chartView.data = chartData
        chartView.notifyDataSetChanged()
        chartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOption: .linear)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isOverView{
            lineChartView.notifyDataSetChanged()
            lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOption: .linear)
        }else{
            chartView.notifyDataSetChanged()
            chartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.0, easingOption: .linear)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChartsVC : ChartViewDelegate{
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Selected")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("Nothing Selected")
    }
}

extension ChartsVC : IAxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if isOverView{
            return yearsData[Int(value)]
        }else{
            return monthsData[Int(value)]
        }
    }
}
