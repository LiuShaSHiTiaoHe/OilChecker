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
    var currentDevice: UserAndCarModel?
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
        self.addSubview(emptyImageView)
        updateChartAxis()
        
        fuelChartView.isHidden = true
        emptyImageView.isHidden = false
        
        segment.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kMargin)
            make.left.equalToSuperview().offset(kMargin*2)
            make.right.equalToSuperview().offset(-kMargin*2)
            make.height.equalTo(30)
        }
        
        emptyImageView.snp.makeConstraints { make  in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
            make.centerY.equalToSuperview().offset(kMargin)
        }
        
        fuelChartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kMargin/2)
            make.right.equalToSuperview()
            make.top.equalTo(segment.snp.bottom)
        }
        
        
        
    }
    
    func updateCurrentDevice(model: UserAndCarModel) {
        currentDevice = model
        segment.setIndex(0, animated: true, shouldSendValueChangedEvent: true)
    }
    
    func updateChartData(data: Array<BaseFuelDataModel>) {
        if data.count == 0 {
            fuelChartView.isHidden = true
            emptyImageView.isHidden = false
            
        }else {
            emptyImageView.isHidden = true
            fuelChartView.isHidden = false
            setDataCount(data)
        }

    }
    
    // MARK: - Action handlers
    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        guard currentDevice != nil else {
            return
        }
        prepareData(sender.index+1)
    }
    
    func prepareData(_ index: Int) {
        
        let dataSource = realm.objects(BaseFuelDataModel.self).sorted(byKeyPath: "recordIDFromDevice").suffix(index*20)

        let fuelLeverDataSource = Array(dataSource)

        updateChartData(data: Array(fuelLeverDataSource) )
    }
    
    func setDataCount(_ dataSource: [BaseFuelDataModel]) {

        var values: [ChartDataEntry] = []
        for index in 0 ... dataSource.count - 1 {
            if index < dataSource.count - 2 {
                let netxData = dataSource[index + 1]
                let data = dataSource[index]
                if data.fuelLevel - netxData.fuelLevel > warningFuelChangedValue {
                    values.append(ChartDataEntry(x: index.double, y: data.fuelLevel, icon: NSUIImage.init(named: "icon_warning")))
                }else{
                    values.append(ChartDataEntry(x: index.double, y: data.fuelLevel))
                }
            }else{
                values.append(ChartDataEntry(x: index.double, y: dataSource[index].fuelLevel))
            }
        }
        
        
        let set1 = LineChartDataSet(entries: values, label: "Current Fuel".localized())
        set1.axisDependency = .left
        set1.setColor(kThemeGreenColor)
        set1.lineWidth = 1.0
        set1.mode = .horizontalBezier
        set1.fillAlpha = 0.1
        set1.fillColor = kThemeGreenColor
        set1.drawFilledEnabled = true
        set1.drawCirclesEnabled = true
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
            segments: LabelSegment.segments(withTitles: ["Day".localized(), "Week".localized()],
                                            normalTextColor: kWhiteColor,
                                            selectedTextColor: kThemeGreenColor),
            options:[.backgroundColor(kThemeGreenColor),
                     .indicatorViewBackgroundColor(kWhiteColor),
                     .cornerRadius(15.0),
                     .animationSpringDamping(1.0)])
        segmentedControl.addTarget(self,action: #selector(segmentedControlValueChanged(_:)),for: .valueChanged)
        segmentedControl.alwaysAnnouncesValue = true
        return segmentedControl
    }()
    
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "em_charts")
        return imageView
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
        return chartView
    }()

    func updateChartAxis() {
        let xAxis = fuelChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = k12Font
        xAxis.labelTextColor = kSecondBlackColor
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = true
        
        let leftAxis = fuelChartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = k12Font
        leftAxis.gridColor = kLightGaryFontColor
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = kSecondBlackColor
        
    }
}

extension HomeChartView: ChartViewDelegate{
    
}
