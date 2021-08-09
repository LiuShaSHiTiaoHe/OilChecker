//
//  FuelConsumptionView.swift
//  OilChecker
//
//  Created by 顾桂俊 on 2021/4/25.
//

import UIKit
import Charts
import RealmSwift
import BetterSegmentedControl
import SwiftyUserDefaults

class FuelConsumptionView: UIView {
    let realm = try! Realm()
    var currentDevice: UserAndCarModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action handlers
    func updateCurrentDevice(model: UserAndCarModel) {
        currentDevice = model
//        let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}.suffix(50)
        let dataSource = RealmHelper.queryObject(objectClass: FuelConsumptionModel(), filter: "deviceID = '\(currentDevice.deviceID)' ").sorted { $0.recordIDFromDevice < $1.recordIDFromDevice}
        updateChartData(Array(dataSource))
    }
    
    func updateChartData(_ dataSource: [FuelConsumptionModel]) {
 
        if dataSource.count == 0 {
            emptyImageView.isHidden = false
            fuelChartView.isHidden = true
            return
        }else{
            emptyImageView.isHidden = true
            fuelChartView.isHidden = false
        }
        
        let values = dataSource.map { (model) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(model.recordIDFromDevice), y: model.consumption)
        }
  
        let thresholds = Defaults[\.kThresholds]
        let ll1 = ChartLimitLine(limit: thresholds, label: "Consumption Thresholds")
        ll1.lineWidth = 4
        ll1.lineDashLengths = [5, 5]
        ll1.labelPosition = .topRight
        ll1.valueFont = k12Font
        ll1.lineColor = kThemeGreenColor
        ll1.valueTextColor = kThemeGreenColor
        let leftAxis = fuelChartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        
        
        let set1 = BarChartDataSet(entries: values, label: "Consumption")
        set1.setColor(kRedAlphaColor)
        set1.highlightColor = kRedFontColor
        set1.drawValuesEnabled = true
        set1.valueTextColor = kBlackColor
        set1.axisDependency = .left
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 0.9
        fuelChartView.data = data
        fuelChartView.zoomAndCenterViewAnimated(scaleX: values.count.cgFloat/15, scaleY: 1, xValue: values.last!.x, yValue: values.last!.y, axis: .left, duration: 0.1)
    }
    
    
    func initUI() {
        self.layer.cornerRadius = 10
        self.backgroundColor = kWhiteColor
        
        self.addSubview(emptyImageView)
        self.addSubview(detailButton)
        self.addSubview(fuelChartView)
        
        emptyImageView.isHidden = false
        fuelChartView.isHidden = true
        
        detailButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kMargin)
            make.top.equalToSuperview().offset(kMargin)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        emptyImageView.snp.makeConstraints { make  in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
            make.centerY.equalToSuperview().offset(kMargin)
        }
        
        fuelChartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(detailButton.snp.bottom)
            make.bottom.equalToSuperview().offset(-kMargin/2)
        }
    }

    
    lazy var detailButton: ExpandButton = {
        let btn = ExpandButton.init(type: .custom)
        btn.setImage(UIImage(named: "btn_list_icon"), for: .normal)
        return btn
    }()
    
    lazy var lineView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: 0x515151, transparency: 0.2)
        return view
    }()
    
    lazy var fuelChartView: BarChartView = {
        let chartView = BarChartView.init()
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.rightAxis.enabled = false
        chartView.scaleYEnabled = false
        chartView.setVisibleXRangeMinimum(20)

        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        return chartView
    }()
    
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "em_charts")
        return imageView
    }()

    
}
