//
//  HomeChartView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/26.
//

import UIKit
import Charts
import BetterSegmentedControl
import SwiftDate
import RealmSwift

class HomeChartView: UIView {
    let realm = try! Realm()
    var currentDevice: UserAndCarModel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.layer.cornerRadius = 10
        self.backgroundColor = kWhiteColor
        
        self.addSubview(segment)
        self.addSubview(fuelChartView)
        updateChartAxis()

        segment.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kMargin/2)
            make.left.equalToSuperview().offset(kMargin*2)
            make.right.equalToSuperview().offset(-kMargin*2)
            make.height.equalTo(30)
        }
        
        fuelChartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kMargin/2)
            make.bottom.equalToSuperview().offset(-kMargin/2)
            make.right.equalToSuperview().offset(-kMargin/2)
            make.top.equalTo(segment.snp.bottom)
        }
        
    }
    
    func updateCurrentDevice(model: UserAndCarModel) {
        currentDevice = model
        segment.setIndex(0, animated: true, shouldSendValueChangedEvent: true)
    }
    
    // MARK: - Action handlers
    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0{
            let startDate = getDataRegion().dateAt(.startOfDay).date
            let endDate = getDataRegion().dateAt(.endOfDay).date
            let fuelLeverDataSource = realm.objects(BaseFuelDataModel.self).filter("rTime BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, currentDevice!.deviceID).sorted(byKeyPath: "rTime")
            
            let start = startDate.timeIntervalSince1970
            let end = endDate.timeIntervalSince1970
            let xAxis = fuelChartView.xAxis
            xAxis.axisMinimum = start
            xAxis.axisMaximum = end
            xAxis.setLabelCount(6, force: true)
            xAxis.valueFormatter = DayDateValueFormatter()
            
            updateChartData(data: Array(fuelLeverDataSource))
            
        }else if sender.index == 1{
            let startDate = getDataRegion().dateAt(.startOfWeek).date
            let endDate = getDataRegion().dateAt(.endOfWeek).date
            let fuelLeverDataSource = realm.objects(BaseFuelDataModel.self).filter("rTime BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, currentDevice!.deviceID).sorted(byKeyPath: "rTime")

            let start = startDate.timeIntervalSince1970
            let end = endDate.timeIntervalSince1970
            let xAxis = fuelChartView.xAxis
            xAxis.axisMinimum = start
            xAxis.axisMaximum = end
            xAxis.valueFormatter = WeekValueFormatter()
            xAxis.setLabelCount(7, force: true)
            updateChartData(data: Array(fuelLeverDataSource))
        }else {
            let startDate = getDataRegion().dateAt(.startOfMonth).date
            let endDate = getDataRegion().dateAt(.endOfMonth).dateAt(.startOfDay).date
            let fuelLeverDataSource = realm.objects(BaseFuelDataModel.self).filter("rTime BETWEEN {%@, %@} and deviceID == %@", startDate, endDate, currentDevice!.deviceID).sorted(byKeyPath: "rTime")
            let start = startDate.timeIntervalSince1970
            let end = endDate.timeIntervalSince1970
            let xAxis = fuelChartView.xAxis
            xAxis.axisMinimum = start
            xAxis.axisMaximum = end
            xAxis.valueFormatter = MonthValueFormatter()
            updateChartData(data: Array(fuelLeverDataSource))
        }
      
        
    }
    
    func updateChartData(data: [BaseFuelDataModel]) {
        setDataCount(data)
//        for item in data {
//            logger.info("\(item.rTime)")
//            logger.info("\(item.fuelLevel)")
//        }
    }
    
    func updateChartAxis() {
        let xAxis = fuelChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = k12Font
        xAxis.labelTextColor = kSecondBlackColor
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 3600
        
        let leftAxis = fuelChartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = k12Font
//        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = kLightGaryFontColor
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 170
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = kSecondBlackColor
        
    }
    
    func setDataCount(_ dataSource: [BaseFuelDataModel]) {

        let values = dataSource.map { (model) -> ChartDataEntry in
            return ChartDataEntry.init(x: model.rTime.timeIntervalSince1970 , y: model.fuelLevel.double)
        }
        
        let set1 = LineChartDataSet(entries: values, label: "Current Fuel")
        set1.axisDependency = .left
        set1.setColor(kThemeGreenColor)
        set1.lineWidth = 1.0
        set1.mode = .cubicBezier
        set1.drawValuesEnabled = true
        set1.fillAlpha = 0.1
        set1.fillColor = kThemeGreenColor
        set1.drawFilledEnabled = true
        set1.drawCirclesEnabled = true
        set1.drawCircleHoleEnabled = false
        set1.setCircleColor(kGreenFontColor)
        set1.circleRadius = 2
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(kThemeGreenColor)
        data.setValueFont(k12Font)

        fuelChartView.data = data
    }
    
    lazy var segment: BetterSegmentedControl = {
        let segmentedControl = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: ["Day", "Week"],
                                            normalTextColor: kSecondBlackColor,
                                            selectedTextColor: kWhiteColor),
            options:[.backgroundColor(kBackgroundColor),
                     .indicatorViewBackgroundColor(kThemeGreenColor),
                     .cornerRadius(5.0),
                     .animationSpringDamping(1.0)])
        segmentedControl.addTarget(self,action: #selector(segmentedControlValueChanged(_:)),for: .valueChanged)
        segmentedControl.alwaysAnnouncesValue = true
        return segmentedControl
    }()
    
    lazy var fuelChartView: LineChartView = {
        let chartView = LineChartView.init()
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.rightAxis.enabled = false
        chartView.backgroundColor = .white
        chartView.legend.enabled = true
        chartView.legend.textColor = kThemeGreenColor
        chartView.drawGridBackgroundEnabled = false
//        chartView.animate(xAxisDuration: 1.5)
        return chartView
    }()

}

extension HomeChartView: ChartViewDelegate{
    
}
